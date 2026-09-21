param(
  [Parameter(Mandatory = $true)][string]$Video,
  [int]$ExpectedWidth = 1920,
  [int]$ExpectedHeight = 1080,
  [double]$ExpectedFps = 30,
  [double]$ExpectedDuration = 0,
  [double]$DurationTolerance = 0.04,
  [string]$StillTimes = "1.5,7.4,15.4,21.4,29.5",
  [string]$StillDirectory = "",
  [string]$ApprovedStillDirectory = "",
  [double]$MinimumSsim = 0.97,
  [switch]$Publishable,
  [string]$AudioAttribution = ""
)

$ErrorActionPreference = "Stop"
$videoPath = [System.IO.Path]::GetFullPath($Video)
if (!(Test-Path -LiteralPath $videoPath)) { throw "Video does not exist: $videoPath" }

function Find-Tool([string]$Name, [string[]]$Fallbacks) {
  $command = Get-Command $Name -ErrorAction SilentlyContinue
  if ($command) { return $command.Source }
  foreach ($candidate in $Fallbacks) { if ($candidate -and (Test-Path -LiteralPath $candidate)) { return $candidate } }
  throw "Required tool not found: $Name"
}

$ffmpeg = Find-Tool "ffmpeg" @("D:\Program Files\ffmpeg\bin\ffmpeg.exe")
$ffprobe = Find-Tool "ffprobe" @("D:\Program Files\ffmpeg\bin\ffprobe.exe")
$probe = (& $ffprobe -v error -count_frames -show_entries stream=index,codec_type,codec_name,profile,width,height,r_frame_rate,pix_fmt,color_range,sample_rate,duration,nb_read_frames -show_entries format=duration,size -of json $videoPath) | ConvertFrom-Json
$videoStream = @($probe.streams | Where-Object codec_type -eq "video")[0]
$audioStream = @($probe.streams | Where-Object codec_type -eq "audio")[0]
if (!$videoStream) { throw "No video stream found" }
if (!$audioStream) { throw "No audio stream found" }

$fpsParts = $videoStream.r_frame_rate -split "/"
$actualFps = [double]$fpsParts[0] / [double]$fpsParts[1]
$duration = [double]$probe.format.duration
$failures = [System.Collections.Generic.List[string]]::new()
if ($videoStream.codec_name -ne "h264") { $failures.Add("Expected H.264 video, got $($videoStream.codec_name)") }
if ($videoStream.profile -ne "High") { $failures.Add("Expected H.264 High profile, got $($videoStream.profile)") }
if ($videoStream.width -ne $ExpectedWidth -or $videoStream.height -ne $ExpectedHeight) { $failures.Add("Expected ${ExpectedWidth}x${ExpectedHeight}, got $($videoStream.width)x$($videoStream.height)") }
if ([Math]::Abs($actualFps - $ExpectedFps) -gt 0.01) { $failures.Add("Expected $ExpectedFps FPS, got $actualFps") }
if ($videoStream.pix_fmt -ne "yuv420p") { $failures.Add("Expected yuv420p, got $($videoStream.pix_fmt)") }
if ($audioStream.codec_name -ne "aac") { $failures.Add("Expected AAC audio, got $($audioStream.codec_name)") }
if ($audioStream.sample_rate -ne "48000") { $failures.Add("Expected 48000 Hz audio, got $($audioStream.sample_rate)") }
if ($ExpectedDuration -gt 0 -and [Math]::Abs($duration - $ExpectedDuration) -gt $DurationTolerance) { $failures.Add("Expected duration $ExpectedDuration +/- $DurationTolerance, got $duration") }
$expectedFrames = [int][Math]::Ceiling($duration * $actualFps)
$actualFrames = if ($videoStream.nb_read_frames) { [int]$videoStream.nb_read_frames } else { 0 }
if ($actualFrames -ne $expectedFrames) { $failures.Add("Expected $expectedFrames readable frames, got $actualFrames") }
$videoDuration = if ($videoStream.duration) { [double]$videoStream.duration } else { $duration }
$audioDuration = if ($audioStream.duration) { [double]$audioStream.duration } else { 0 }
if ($audioDuration -le 0 -or [Math]::Abs($videoDuration - $audioDuration) -gt (1 / $actualFps + 0.01)) {
  $failures.Add("Audio/video duration mismatch: video=$videoDuration audio=$audioDuration")
}

function Find-ByteSequence([byte[]]$Bytes, [byte[]]$Needle) {
  for ($index = 0; $index -le $Bytes.Length - $Needle.Length; $index += 1) {
    $match = $true
    for ($offset = 0; $offset -lt $Needle.Length; $offset += 1) {
      if ($Bytes[$index + $offset] -ne $Needle[$offset]) { $match = $false; break }
    }
    if ($match) { return $index }
  }
  return -1
}

$fileBytes = [System.IO.File]::ReadAllBytes($videoPath)
$moovIndex = Find-ByteSequence $fileBytes ([System.Text.Encoding]::ASCII.GetBytes("moov"))
$mdatIndex = Find-ByteSequence $fileBytes ([System.Text.Encoding]::ASCII.GetBytes("mdat"))
if ($moovIndex -lt 0 -or $mdatIndex -lt 0 -or $moovIndex -gt $mdatIndex) { $failures.Add("MP4 is missing faststart atom ordering") }

if ([string]::IsNullOrWhiteSpace($StillDirectory)) { $StillDirectory = Join-Path (Split-Path -Parent $videoPath) "final-mp4-stills" }
$stills = [System.IO.Path]::GetFullPath($StillDirectory)
New-Item -ItemType Directory -Force -Path $stills | Out-Null
$comparisonScores = [ordered]@{}
foreach ($time in $StillTimes.Split(",", [System.StringSplitOptions]::RemoveEmptyEntries)) {
  $value = [double]$time.Trim()
  $name = "frame-$($value.ToString('0.00').Replace('.', '-')).png"
  & $ffmpeg -y -ss $value -i $videoPath -frames:v 1 (Join-Path $stills $name) 2>$null
  if ($LASTEXITCODE -ne 0) { throw "Failed to extract still at $value seconds" }
  if (![string]::IsNullOrWhiteSpace($ApprovedStillDirectory)) {
    $approved = Join-Path ([System.IO.Path]::GetFullPath($ApprovedStillDirectory)) $name
    if (!(Test-Path -LiteralPath $approved)) { $failures.Add("Missing approved still: $name"); continue }
    $comparison = (& $ffmpeg -hide_banner -i $approved -i (Join-Path $stills $name) -lavfi "[0:v][1:v]ssim" -f null NUL 2>&1 | Out-String)
    $ssimMatch = [regex]::Match($comparison, 'All:([0-9.]+)')
    if (!$ssimMatch.Success) { $failures.Add("Could not calculate SSIM for $name"); continue }
    $score = [double]$ssimMatch.Groups[1].Value
    $comparisonScores[$name] = $score
    if ($score -lt $MinimumSsim) { $failures.Add("SSIM for $name was $score, below $MinimumSsim") }
  }
}

$lastFrameTime = [Math]::Max(0, $duration - (1 / $actualFps))
$lastFramePath = Join-Path $stills "frame-last.png"
& $ffmpeg -y -ss $lastFrameTime -i $videoPath -frames:v 1 $lastFramePath 2>$null
if ($LASTEXITCODE -ne 0 -or !(Test-Path -LiteralPath $lastFramePath) -or (Get-Item $lastFramePath).Length -lt 1024) { $failures.Add("Final video frame could not be decoded") }

$blackOutput = (& $ffmpeg -hide_banner -i $videoPath -vf "blackdetect=d=0.40:pix_th=0.02:pic_th=0.999" -an -f null NUL 2>&1 | Out-String)
$blackDurations = @([regex]::Matches($blackOutput, 'black_duration:([0-9.]+)') | ForEach-Object { [double]$_.Groups[1].Value })
if (@($blackDurations | Where-Object { $_ -ge 0.40 }).Count -gt 0) { $failures.Add("Detected black-frame gap(s): $($blackDurations -join ', ')") }

if ($Publishable) {
  if ([string]::IsNullOrWhiteSpace($AudioAttribution)) { $AudioAttribution = [System.IO.Path]::ChangeExtension($videoPath, ".audio.md") }
  if (!(Test-Path -LiteralPath $AudioAttribution)) { $failures.Add("Publishable render is missing audio attribution") }
  elseif ((Get-Content -LiteralPath $AudioAttribution -Raw) -match 'review cut only|not supplied or approved') { $failures.Add("Publishable render still uses review-only audio") }
}

$result = [ordered]@{
  path = $videoPath
  sha256 = (Get-FileHash -Algorithm SHA256 $videoPath).Hash
  width = $videoStream.width
  height = $videoStream.height
  fps = $actualFps
  duration = $duration
  videoCodec = $videoStream.codec_name
  videoProfile = $videoStream.profile
  pixelFormat = $videoStream.pix_fmt
  frameCount = $actualFrames
  faststart = ($moovIndex -ge 0 -and $mdatIndex -ge 0 -and $moovIndex -lt $mdatIndex)
  audioCodec = $audioStream.codec_name
  audioSampleRate = $audioStream.sample_rate
  audioDuration = $audioDuration
  stillDirectory = $stills
  approvedStillSsim = $comparisonScores
  blackFrameDurations = $blackDurations
  failures = @($failures)
}
$result | ConvertTo-Json -Depth 4
if ($failures.Count -gt 0) { throw "Video validation failed: $($failures -join '; ')" }
