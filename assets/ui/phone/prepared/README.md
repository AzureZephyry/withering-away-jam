# Prepared phone placeholders

These are temporary phone UI placeholders awaiting final approved artwork.
All 16 prepared screens are integrated by `scripts/phone_conversation.gd` in the
Bedroom introduction. That controller handles progression, choices and completion;
this guide records how the temporary images were prepared, not a second gameplay
implementation.

## Sources and copies

The 16 original PNGs and their 16 import sidecars are recoverably archived in the
sibling artwork-source archive at `phone-originals/2026-10-27/`, with a hash/count
manifest. They are not runtime dependencies. Prepared copies remain in
`assets/ui/phone/prepared/`, with the same PNG basenames. Original and prepared
image bytes are unchanged by this archival relocation.

## Transparency

Only the exterior alpha mask changes before resizing. Each phone's solid
interior is protected, including white message bubbles, black interface details,
portraits, text, and the three choice rows on Screen 04.

The silhouette is traced row by row from the outer phone frame. Runs of at least
three pixels identify the frame rather than isolated canvas compression specks.
Only the central 12%-88% of each original canvas is searched; all inspected phone
artwork lies inside that region. On white sources, frame support uses a minimum
RGB channel of 224 or lower. Each row is filled between its outer frame edges;
white pixels inside that envelope stay opaque.

On black sources, frame support uses a maximum RGB channel of at least 64.
The enclosed silhouette mask is blurred at radius 5 and thresholded above 1
to retain a conservative dark rim around the colored frame. Only the mask is
processed: RGB pixels are never blurred. The final alpha is binary, 0 or 255.
This treatment applies to 06, 07, 10, 11, 13, 15, and 16. Their exact outermost
black boundary cannot be distinguished perfectly from the black source canvas;
a small dark perimeter is retained rather than risking the phone frame.

## Framing

All outputs are RGBA PNGs on a 640 x 1088 transparent canvas. The isolated mask
is scaled proportionally to 1024 pixels high, with 32 pixels of padding above
and below. Width is rounded to the nearest pixel. The mask bounds are centered
horizontally, within half a pixel. Nearest-neighbor resizing avoids introducing
interpolated artwork colors. No phone is stretched to force a common width.

The table uses source bounds `(left, top, right, bottom)`, with exclusive right
and bottom edges. Prepared bounds use the same convention. The forward mapping
is `output_x = left_padding + (source_x - crop_left) * prepared_width / crop_width`
and `output_y = 32 + (source_y - crop_top) * 1024 / crop_height`.
The implemented choice hit regions follow this prepared-image transform.

| Source and prepared basename | Source size | Source mask bounds | Prepared mask bounds |
| --- | --- | --- | --- |
| `phone_common_01_mama_greeting.png` | 1024 x 1536 | (163, 41, 862, 1492) | (73, 32, 566, 1056) |
| `phone_common_02_mama_congratulations.png` | 1024 x 1536 | (162, 41, 863, 1493) | (73, 32, 567, 1056) |
| `phone_common_03_papa_message.png` | 1086 x 1448 | (167, 25, 920, 1428) | (45, 32, 595, 1056) |
| `phone_common_04_choices.png` | 1122 x 1402 | (193, 20, 931, 1397) | (45, 32, 594, 1056) |
| `phone_branch1_05_albert_reply.png` | 1448 x 1086 | (448, 8, 1000, 1080) | (56, 32, 583, 1056) |
| `phone_branch1_06_mama_reply.png` | 1225 x 1284 | (301, 4, 923, 1246) | (63, 32, 576, 1056) |
| `phone_branch1_07_papa_reply.png` | 1448 x 1086 | (442, 0, 1011, 1086) | (51, 32, 588, 1056) |
| `phone_branch2_08_albert_reply.png` | 1086 x 1448 | (202, 25, 882, 1371) | (61, 32, 578, 1056) |
| `phone_branch2_09_mama_reply.png` | 1086 x 1448 | (208, 13, 879, 1392) | (71, 32, 569, 1056) |
| `phone_branch2_10_papa_reply.png` | 1024 x 1536 | (182, 1, 843, 1507) | (95, 32, 544, 1056) |
| `phone_branch2_11_mama_final.png` | 1024 x 1536 | (182, 1, 843, 1508) | (95, 32, 544, 1056) |
| `phone_branch3_12_albert_reply.png` | 1122 x 1402 | (198, 25, 927, 1333) | (34, 32, 605, 1056) |
| `phone_branch3_13_albert_nervous.png` | 1122 x 1402 | (231, 0, 892, 1366) | (72, 32, 568, 1056) |
| `phone_branch3_14_mama_reply.png` | 1086 x 1448 | (201, 26, 883, 1371) | (60, 32, 579, 1056) |
| `phone_branch3_15_papa_reply.png` | 1086 x 1448 | (193, 0, 897, 1448) | (71, 32, 569, 1056) |
| `phone_branch3_16_mama_final.png` | 1086 x 1448 | (191, 1, 897, 1448) | (70, 32, 570, 1056) |

## Limitations and review status

- Center and masked height are normalized, but the sources contain genuinely
  different phone proportions. Prepared widths range from 449 to 571 pixels.
  Width changes remain visible when swapping some screens. Matching width and
  height simultaneously would distort the supplied artwork and was not done.
- Screens 15 and 16 have frame detail reaching their original bottom edge.
  Existing edge truncation is preserved; missing artwork was not reconstructed.
- Black-background sources retain a conservative dark rim. Edge appearance needs
  review against the eventual Bedroom backdrop; perfect silhouette recovery is
  not asserted.
- Resizing necessarily changes raster sampling. No text was rewritten and no
  portraits, messages, decorations, or colors were repainted.
- Screen 04's placeholder wording remains unchanged, including its known
  difference from the narrative response wording. Choice behavior is implemented in the phone controller; this image is unchanged.

## Validation and Godot use

All 16 exports passed PNG/RGBA decoding, transparent-border, opaque-message-area,
canvas-size, mask-height, centering, source-to-output mapping, and sampled-RGB
comparison checks. Screen 04's complete three-row choice area stays opaque.
All exports were reviewed together over a checkerboard, with detailed checks of
Screen 04 and representative dark-source boundaries. This is not final visual
acceptance and does not establish perfectly identical phone silhouettes.

The files use lossless PNG with actual alpha. The runtime Control uses nearest texture filtering and preserves aspect ratio. Do not stretch the entire
texture to fill a viewport. The Bedroom introduction already loads all 16 exports in Godot 4.7.2. These
preparation checks are historical asset evidence; they do not by themselves
establish final artwork approval. Later phone-UI acceptance and gameplay results
belong to the project milestone guides.
