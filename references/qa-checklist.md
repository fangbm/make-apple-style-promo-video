# Final Promo QA Checklist

## Visual Review

- [ ] Product/logo is correct and not an obsolete draft.
- [ ] All visible product claims are true.
- [ ] Every scene has a clear focal point and enough settled reading time.
- [ ] No text clips, overlaps, or falls outside the safe frame.
- [ ] Chinese and English punctuation look optically centered.
- [ ] UI remains readable at 50% image size.
- [ ] Cursor tip points upper-left in every frame.
- [ ] Cursor hotspot lands on the intended target.
- [ ] Context menu opens near the selection.
- [ ] Tooltip/popover arrow points to the real term center.
- [ ] Overlay chooses above/below sensibly and stays inside the surface.
- [ ] No overlay appears at the upper-left origin before settling.
- [ ] End card is balanced and all lines use intentional spacing.

## Motion Review

- [ ] No element flashes twice when clicked or locked.
- [ ] No stale state survives a scene transition.
- [ ] Major text does not bounce.
- [ ] Cursor paths are smooth and not mirrored.
- [ ] Popovers open from their anchor transform origin.
- [ ] The viewer has time to understand the result before the cut.

## Audio Review

- [ ] Music is user-provided or has a documented usable license.
- [ ] Music starts and ends cleanly at the exact duration.
- [ ] Cue tones are subtle and aligned to visible events.
- [ ] No clipping; limiter is active.
- [ ] AAC audio exists in the final MP4 at 48 kHz.

## Encoded-File Review

- [ ] MP4 uses H.264 and `yuv420p`.
- [ ] Resolution and FPS match the request.
- [ ] Duration matches the timeline within one frame.
- [ ] `faststart` is enabled.
- [ ] The final MP4 plays from beginning to end.
- [ ] At least three stills are extracted from the final MP4, not only source HTML.
- [ ] Final-MP4 stills match the approved browser stills.
- [ ] No player controls, desktop taskbar, performance HUD, or debug text are baked in.

## Common Repairs

### Cursor is reversed

Replace rotated border triangles with a standard polygon/SVG cursor. Verify the visible tip is top-left and the tail is bottom-right. Recheck hover and selection scenes separately.

### Card points to the wrong word

Measure the target and card after fonts load. Center, clamp, then calculate arrow offset. Do not calculate arrow offset before clamping.

### Card flashes at the corner

Apply its final base `left/top` before the scene becomes visible. Animate with transform deltas relative to that base instead of writing temporary `(0, 0)` coordinates.

### Scene feels empty

Increase the primary UI scale, add a compact step indicator or process label, and extend the settled product state. Do not add decorative cards or random imagery.

### Chinese headline looks off-center

Use explicit line wrappers. Compare no compensation versus one `\u3000`/`&emsp;`. Keep the smaller correction and inspect the encoded frame.

### HTML looks right but MP4 is wrong

Extract the failing time directly from the MP4 with FFmpeg. Check font/image readiness and whether the render script captures before layout stabilization.
