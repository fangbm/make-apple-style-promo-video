# Make Apple-Style Promo Video

[中文](README.md) | [Skill instructions](SKILL.md) | [Template](assets/promo-template/promo.html)

A Codex Skill for building polished, Apple-inspired product films from deterministic HTML, CSS, and JavaScript scenes. It renders frame by frame, encodes a publishable MP4, and validates the final encoded video rather than stopping at a browser preview.

Use it for software launches, browser-extension demos, feature reels, and product trailers. The deliverable is a finished video with audio and technical evidence, not merely a storyboard or a static mockup.

## Finished Example

[![TermPop - Explain Terms Without Leaving the Page](https://img.youtube.com/vi/JsnLDK-RdbE/hqdefault.jpg)](https://youtu.be/JsnLDK-RdbE)

**TermPop - Explain Terms Without Leaving the Page**
Click the preview to [watch on YouTube](https://youtu.be/JsnLDK-RdbE).

## What It Delivers

- Fixed-canvas, deterministic product scenes that render the same way every time.
- Cursors, menus, popovers, and arrows anchored to real UI geometry.
- H.264/AAC MP4 output with `faststart`, expected frame rate, and expected duration.
- Checkpoint stills extracted from the final MP4, plus SSIM comparison and technical probes.
- Music source, license, and credit records so a temporary track is never represented as publishable.

## Install

Clone the repository into your Codex Skills directory:

```powershell
git clone https://github.com/fangbm/make-apple-style-promo-video.git `
  "$env:USERPROFILE\.codex\skills\make-apple-style-promo-video"
```

Then ask Codex:

```text
Use $make-apple-style-promo-video to create a publishable 16:9 Apple-style promo video for this product.
```

## Quick Start

You need Node.js, FFmpeg, PowerShell, and a Chromium or Edge executable that Playwright can launch.

```powershell
$skill = "$env:USERPROFILE\.codex\skills\make-apple-style-promo-video"
& "$skill\scripts\new_promo_project.ps1" `
  -OutputDirectory "D:\work\promo" `
  -ProductName "YourProduct"

node "$skill\scripts\capture_stills.mjs" `
  --source "D:\work\promo\promo.html" `
  --output "D:\work\promo\artifacts\stills"

& "$skill\scripts\render_video.ps1" `
  -Source "D:\work\promo\promo.html" `
  -Output "D:\work\promo\artifacts\promo.mp4"

& "$skill\scripts\validate_video.ps1" `
  -Video "D:\work\promo\artifacts\promo.mp4" `
  -ExpectedDuration 31.2
```

Without approved music, the result is a review cut only. A `-Publishable` render must include the music file, source URL, license, and credit.

## Workflow

1. Establish the product, audience, verified feature claims, language, duration, and licensing constraints.
2. Write a timed storyboard covering the reveal, primary interaction, second surface, proof, and end card.
3. Make `window.renderAt(time)` the only source of visual state. Avoid network content, randomness, and uncontrolled animation clocks.
4. Measure targets with `getBoundingClientRect()` and derive every cursor, context menu, and explanation-card position from that geometry.
5. Capture and inspect stills for each meaningful interaction state before full encoding.
6. Validate the final MP4 for codecs, duration, black frames, visual checkpoints, and audio/video sync.

Read the full [SKILL.md](SKILL.md) for the exact operating contract.

## Repository Map

| Path | Purpose |
| --- | --- |
| [SKILL.md](SKILL.md) | Full Codex workflow and acceptance standard |
| [assets/promo-template](assets/promo-template) | Deterministic six-scene HTML starter |
| [scripts](scripts) | Scaffold, frame rendering, still capture, encoding, and validation |
| [references/style-system.md](references/style-system.md) | Visual, typographic, motion, and audio direction |
| [references/storyboard-patterns.md](references/storyboard-patterns.md) | Storyboarding and copy patterns |
| [references/qa-checklist.md](references/qa-checklist.md) | Final acceptance checklist and repair guide |

## Principles

- Show the real product, not an atmosphere-only concept.
- Inspect stills before full encoding.
- Anchor interaction UI to actual targets.
- Treat the encoded MP4 as the artifact to validate.
- Use only approved, attributable music in a public release.
