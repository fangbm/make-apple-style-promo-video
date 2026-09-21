---
name: make-apple-style-promo-video
description: Create polished Apple-inspired software and product promotional videos as deterministic HTML/CSS/JavaScript scenes rendered frame-by-frame and encoded to a publishable MP4 with music, interaction animation, and visual QA. Use when Codex is asked for a 果味宣传片, 苹果风宣传片, Apple-style product video, software launch film, browser-extension promo, app feature reel, 16:9 product trailer, or when an existing promo video needs layout, cursor, popover, timing, typography, audio, or final-render repair.
---

# Make Apple-Style Promo Video

Produce the finished MP4, not only a storyboard or HTML preview. Use a fixed 1920x1080 canvas, deterministic `window.renderAt(time)`, browser screenshots for frames, and FFmpeg for delivery encoding.

## Start Here

1. Inspect the product, existing website, supplied references, logo, UI, and required claims.
2. Read [style-system.md](references/style-system.md) before designing.
3. Read [storyboard-patterns.md](references/storyboard-patterns.md) before writing the timeline.
4. Copy `assets/promo-template/` into the product workspace when no established promo source exists.
5. Replace every placeholder and rebuild scenes around the real product. Do not ship template copy or invented capabilities.
6. Use the scripts in this skill to render frames, encode MP4, capture stills, and validate the final file.
7. Read [qa-checklist.md](references/qa-checklist.md) and complete every applicable check before reporting success.

## Fast Path

On Windows, scaffold and render a first review cut with:

```powershell
$skill = "$env:USERPROFILE\.codex\skills\make-apple-style-promo-video"
& "$skill\scripts\new_promo_project.ps1" -OutputDirectory "D:\work\promo" -ProductName "YourProduct"
node "$skill\scripts\capture_stills.mjs" --source "D:\work\promo\promo.html" --output "D:\work\promo\artifacts\stills"
& "$skill\scripts\render_video.ps1" -Source "D:\work\promo\promo.html" -Output "D:\work\promo\artifacts\promo.mp4"
& "$skill\scripts\validate_video.ps1" -Video "D:\work\promo\artifacts\promo.mp4" -ExpectedDuration 31.2
```

For a publishable music track, add `-Publishable` and pass `-MusicPath`, `-MusicSourceUrl`, `-MusicLicense`, and `-MusicCredit`. The render script writes `.audio.md` attribution and `.render.json` provenance files beside the MP4. A render without `-MusicPath` is a review cut, not a licensed public release.

## Required Workflow

### 1. Establish the brief

Determine:

- product name and one literal value proposition;
- target audience and primary workflow;
- 3-5 real features that can be shown visually;
- language and exact on-screen copy;
- delivery ratio, duration, resolution, FPS, music constraints, and store/platform requirements;
- available assets and whether the user has licensed music.

Default to 16:9, 1920x1080, 30 FPS, and 25-35 seconds. Prefer one idea per scene.

### 2. Write a timed storyboard

Create a concrete timeline before implementation. A reliable 30-second structure is:

1. `0-4s`: product reveal and category statement.
2. `4-11s`: primary workflow with cursor and an anchored result.
3. `11-18s`: second workflow, selection, menu, or mode change.
4. `18-24s`: alternate surface such as PDF, mobile, desktop, or dashboard.
5. `24-27s`: compact proof or feature system.
6. `27-31s`: black end card with logo, product name, tagline, and platforms.

Record the exact event times for highlights, clicks, cards, text transitions, and audio cues. Keep visual rests between dense actions.

### 3. Build a deterministic scene renderer

Implement one fixed-size HTML document and expose:

```js
window.renderAt = (timeInSeconds) => {
  // Derive every visible property from timeInSeconds.
};
```

Do not rely on CSS transition clocks, `setTimeout`, random values, network-loaded UI, animated GIFs, or live app state. Wait for fonts and images before capture. Render text and UI in HTML/CSS so they stay crisp.

Use `phase()`, `mix()`, and restrained easing functions. Prefer opacity plus 20-100 px translation. Use overshoot only for small cards or badges, never for major typography.

### 4. Anchor interaction UI to real DOM geometry

Never position a cursor, context menu, tooltip, or explanation card by visual guessing alone.

1. Measure the target and its scene container with `getBoundingClientRect()`.
2. Convert the target rectangle into container-relative coordinates.
3. Center the card on the target, clamp it inside the scene, and choose above/below based on available space.
4. Compute the arrow position from the target center after clamping.
5. Set `transform-origin` to the arrow anchor so the card opens from the correct location.
6. Re-run alignment after fonts and images load.

Use the standard cursor orientation: tip at upper-left, tail toward lower-right. Never improvise a rotated CSS triangle. Verify all cursor frames independently.

### 5. Make scenes legible at video scale

- Make the product or workflow the first signal in each demonstration scene.
- Enlarge UI 1.3-1.8x compared with a literal browser screenshot.
- Keep body copy short and readable from a video player thumbnail.
- Prefer a few decisive elements over a full application screen.
- Use cards only for actual product surfaces such as popovers or menus.
- Preserve large areas of calm negative space, but do not leave a scene semantically empty.
- Avoid decorative gradients, floating orbs, fake glass everywhere, excessive rounded cards, and generic marketing clutter.

For Chinese display copy, keep `letter-spacing: 0`. If terminal punctuation causes optical imbalance, test exactly one ideographic/full-width space (`&emsp;` or `\u3000`) per affected line. Do not stack spaces without a rendered comparison.

### 6. Add restrained audio

Use user-provided or clearly licensed music. Keep the source URL and license beside the render script. Never silently download copyrighted commercial music.

- Favor 70-110 BPM, clean transients, limited vocals, and a confident restrained bed.
- Fade in/out and trim to the exact video duration.
- Add subtle 60-100 ms interface tones at major reveal/click moments.
- Keep cue tones below the music and apply a limiter.
- Deliver AAC at 48 kHz and approximately 192 kbps.

If no approved music exists, render a review cut with the bundled deterministic placeholder bed, label it as temporary, and do not represent it as final licensed music.

### 7. Render and inspect stills before the full encode

Run the still-capture script for every interaction state: before motion, cursor at target, card opening, card settled, context menu, PDF/alternate surface, and end card. Inspect images visually.

Repair these before encoding:

- reversed cursor;
- arrow not pointing to the highlighted term;
- menu or card covering the wrong target;
- card flashing at `(0, 0)` before alignment;
- text clipping, overlap, weak hierarchy, or tiny UI;
- punctuation making centered Chinese text look displaced;
- empty scenes with no product signal.

### 8. Encode and validate the actual MP4

Use `scripts/render_video.ps1` or the project-specific equivalent. Then use `scripts/validate_video.ps1 -ApprovedStillDirectory <approved-stills>` to extract fixed visual checkpoints from the encoded MP4 and compare them with the approved pre-encode stills using SSIM. Do not validate only the HTML preview or pre-encode frames.

Minimum delivery contract:

- H.264 High profile, `yuv420p`, MP4 with `faststart`;
- 1920x1080 and 30 FPS unless requested otherwise;
- AAC audio at 48 kHz;
- correct duration and no missing final frame;
- no black-frame gaps, player chrome, debug overlays, or local paths on screen;
- visual checkpoints from the final MP4 match the approved stills.
- H.264 profile, frame count, faststart atom order, final-frame decoding, black-frame gaps, and audio/video duration all pass validation.

## Bundled Resources

- `assets/promo-template/`: deterministic six-scene HTML starter. Copy and rewrite it; do not edit the installed asset in place.
- `scripts/render_frames.mjs`: render `window.renderAt()` to numbered JPEG frames.
- `scripts/capture_stills.mjs`: capture named times and print QA geometry.
- `scripts/render_video.ps1`: render and encode with optional music and cue tones.
- `scripts/validate_video.ps1`: inspect codecs/dimensions/duration and extract final-MP4 checkpoints.
- [style-system.md](references/style-system.md): visual and motion language.
- [storyboard-patterns.md](references/storyboard-patterns.md): timeline patterns and copy strategy.
- [qa-checklist.md](references/qa-checklist.md): acceptance checklist and common failure fixes.

## Completion Standard

Do not stop at “render succeeded.” Return the final MP4, at least three representative stills extracted from that MP4, technical probe results, music/license attribution, and any remaining known limitation. If visual inspection reveals a defect, repair and rerender before delivery.
