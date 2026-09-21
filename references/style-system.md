# Apple-Inspired Product Film Style System

Use the visual confidence and editorial restraint associated with premium hardware/software launches without copying Apple trademarks, footage, slogans, product silhouettes, or proprietary assets.

## Composition

- Use a fixed 16:9 canvas and design for the full frame, not a webpage viewport that happens to be recorded.
- Establish one dominant signal per scene: product, statement, or interaction.
- Use asymmetry for demonstration scenes and centered symmetry for reveals/end cards.
- Keep generous negative space, but add a meaningful secondary signal when a frame feels empty: a numbered step, compact flow, product state, or restrained metadata.
- Crop intentionally. Never let the player UI, desktop chrome, or debug overlays enter the master.

## Color

- Default to neutral white/light gray demonstration scenes and a near-black end card.
- Use one brand accent for selection, progress, links, and small emphasis.
- Use functional secondary colors only when the product needs them.
- Avoid multicolor gradients, decorative glow fields, and monochrome blue-everywhere layouts.
- Keep text contrast high. Muted copy should remain readable after H.264 compression.

## Typography

- Prefer system sans-serif stacks: `Inter`, `SF Pro Display`, `PingFang SC`, `Microsoft YaHei`, `Segoe UI`, sans-serif.
- Use 70-120 px display text on 1080p, 30-48 px supporting text, and 24-32 px UI labels.
- Use weight and scale for hierarchy; keep letter spacing at zero.
- Limit each headline to two lines and use deliberate line breaks.
- For Chinese punctuation, judge optical centering from rendered frames. If needed, add one full-width space to the affected line, not ordinary HTML spaces and not repeated compensation.

## Product UI

- Recreate only the interaction needed to communicate the feature.
- Enlarge UI until the action reads at 50% playback size.
- Keep surfaces crisp, quiet, and plausible. Use 8-24 px radii based on scale; do not turn every region into a floating card.
- Explain cards should look like the product, not a generic marketing panel.
- Use real product names, labels, and states. Never invent unsupported claims.

## Motion

- Animate from a deterministic timeline.
- Favor ease-out for entrances and ease-in-out for cursor travel.
- Use 0.35-0.8 s for text/UI entrances, 0.8-1.4 s for cursor travel, and 1-2 s of settled reading time.
- Use subtle scale (`0.90-1.00`) only for popovers and compact UI.
- Avoid constant motion, elastic page motion, spinning decoration, parallax for its own sake, and simultaneous entrance of every element.
- Let music and motion share beats, but never cut faster than the user can understand the feature.

## Interaction Fidelity

- Draw the cursor with a known standard shape: upper-left tip, lower-right tail, dark fill, thin light outline.
- Place the cursor hotspot at its visible tip, not at the center of the cursor box.
- Anchor menus and cards to measured DOM rectangles.
- Clamp overlays to the scene while preserving the arrow-to-target connection.
- Keep the target visible when the card opens unless intentional occlusion is the point.
- Never show a card at the origin for one frame. Set base geometry before changing opacity.

## Audio Character

- Select restrained electronic, ambient, or minimal percussive music.
- Avoid bombastic trailer impacts, busy vocals, meme sounds, and unlicensed chart music.
- Use small tonal cues for highlight completion, menu action, card reveal, and final mark.
- Mix for clarity rather than loudness; apply fade and limiting.

## Things That Look “Apple-Like” but Usually Fail

- Huge type without a product demonstration.
- Empty white frames with tiny UI.
- Excessive blur/glow masquerading as polish.
- Copying an Apple ad shot-for-shot.
- Thin gray copy that disappears after compression.
- Random spring animation on every object.
- A beautiful HTML preview that produces a broken encoded frame.
