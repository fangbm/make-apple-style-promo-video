param(
  [Parameter(Mandatory = $true)][string]$OutputDirectory,
  [Parameter(Mandatory = $true)][string]$ProductName,
  [string]$ProductInitial = "",
  [string]$TaglineLine1 = "让复杂工作，",
  [string]$TaglineLine2 = "变得简单清晰。",
  [string]$Subtitle = "轻量、克制、贴合当前任务的产品体验。",
  [string]$PrimaryTerm = "Context Engine",
  [string]$PrimaryType = "核心能力",
  [string]$PrimaryExplanation = "结合当前内容提供准确结果，让复杂信息在原位置变得容易理解。",
  [string]$SecondTerm = "the exact content that matters"
)

$ErrorActionPreference = "Stop"
$skillRoot = Split-Path -Parent $PSScriptRoot
$template = Join-Path $skillRoot "assets\promo-template\promo.html"
$output = [System.IO.Path]::GetFullPath($OutputDirectory)
if (!(Test-Path -LiteralPath $template)) { throw "Missing promo template: $template" }
if ([string]::IsNullOrWhiteSpace($ProductInitial)) { $ProductInitial = $ProductName.Substring(0, 1).ToUpperInvariant() }

New-Item -ItemType Directory -Force -Path $output | Out-Null
$html = Get-Content -LiteralPath $template -Raw -Encoding UTF8
$replacements = [ordered]@{
  "__PRODUCT_NAME__" = $ProductName
  "__PRODUCT_INITIAL__" = $ProductInitial
  "__TAGLINE_LINE_1__" = $TaglineLine1
  "__TAGLINE_LINE_2__" = $TaglineLine2
  "__SUBTITLE__" = $Subtitle
  "__PRIMARY_TERM__" = $PrimaryTerm
  "__PRIMARY_TYPE__" = $PrimaryType
  "__PRIMARY_EXPLANATION__" = $PrimaryExplanation
  "__SECOND_TERM__" = $SecondTerm
}
foreach ($entry in $replacements.GetEnumerator()) {
  $safeValue = [System.Net.WebUtility]::HtmlEncode([string]$entry.Value)
  $html = $html.Replace($entry.Key, $safeValue)
}
$destination = Join-Path $output "promo.html"
[System.IO.File]::WriteAllText($destination, $html, [System.Text.UTF8Encoding]::new($false))
New-Item -ItemType Directory -Force -Path (Join-Path $output "artifacts") | Out-Null
Write-Host "Created $destination"
