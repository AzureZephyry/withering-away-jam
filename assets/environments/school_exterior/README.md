# School Exterior artwork

Wayne supplied this environmental pixel-art delivery for Godot 4.7.2. The
[School Exterior](../../../docs/SCHOOL_EXTERIOR_PROTOTYPE.md) integrates the
complete map, editable collision, foreground separation and accepted Level 1
atmosphere. The existing School Interior is a separate prototype. Bedroom
departure reaches the exterior sidewalk; Scene 03 narrative, NPCs, dialogue and
objectives remain unimplemented. Original source archives remain preserved.

## Contents

- `ground/`: the delivered ground/roads/sidewalk base, including baked boundary art.
- `structures/`: separate buildings, canteen, library, guardhouse and waiting shed.
- `foliage/`: a tree and potted bush.
- `props/`: separate object/vehicle-barrier variants and one map-aligned mixed export.
- `foreground/`: the separate outer-wall strip and one aligned trees/front-lamps export.
- `vehicles/`: black, red and white car variants.
- `composite/`: the unchanged complete map and the prototype's technical occlusion
  mask, underlay and region metadata.
- [TSV catalog](../../../docs/art/school_exterior_asset_manifest.tsv): all 31 files
  in the corrected delivery, original-to-runtime mapping, dimensions and hashes.
  The redundant CSV and its accidentally imported translations were removed from
  the runtime folder after recovery backup and reference checks.

The library contains 30 delivered PNGs plus four technical mask/underlay PNGs.
Delivered PNGs retain Wayne's **original 16-bit RGBA bytes**: no resizing,
re-encoding, cropping, recoloring or interpolation. The corrected `Schoolv2.zip`
delivery replaces the original export catalog; it is the same environment.
Filenames/categories were normalized; original names remain in both archived ZIPs.
Godot import sidecars accompany these sources. Preserve the source PNGs when
tuning imports. Future Sprite2D/CanvasItem hosts should use nearest filtering for
pixel art; no project-wide rendering setting was changed for this preparation.

## Map alignment and corrected exports

The complete map and four partial exports share the original 1455 × 1467 canvas
and origin. Keep these source exports at `(0, 0)` when reviewing alignment; the
existing playable scene applies its current 1.1475× transform separately.

| Corrected export | Runtime resource | Verified content |
| --- | --- | --- |
| `layer1.png` | `ground/school_ground_paths_base.png` | Ground, roads, sidewalks and baked boundary art; unchanged |
| `layer2.png` | `props/school_placed_props_and_rear_boundary.png` | Cars, small objects, rear streetlights and boundary pieces; unchanged |
| `layer3.png` | `structures/school_buildings.png` | Corrected, positioned school buildings |
| `layer4.png` | `foreground/school_trees_and_front_lamps.png` | Trees/front lamps; byte-identical to original Layer 3 and the retained runtime file |

Only Layers 3 and 4 changed between deliveries. The complete map and every
standalone sprite are byte-identical. The building export is available for future
layer separation; it is not added over buildings already baked into the map.
Numeric layer order alone does not reproduce the complete map: an RGBA8 preview
comparison of Layers 1–4 still differs at 47,914 pixels. Ground/buildings/props/
foliage order also differs. Use the complete map as the visual authority; do not
assume these exports define a final stacking recipe.

`school.kra` remains an editable composition with 60 paint layers and 13 groups.
The corrected PNG export does not establish that this Krita source is obsolete.
Both original KRA documents, both delivered ZIPs, the packed sprite map and the
superseded original Layer 4 remain recoverable in the external art-source archive.
No source archive was overwritten.

The saved school projection and supplied full map are not pixel-identical.
Most display-precision differences are one 8-bit level; 20 pixels differ more
substantially near `(149, 699)`–`(153, 707)`. The two sprite-sheet projections also
differ at display precision. Preserve both versions until Wayne confirms the
preferred source/export revision; do not overwrite one with the other.

## Integration boundary

Individual PNGs are replaceable, independently usable resources. A missing exact
map-template match in the manifest does not mean an asset is unused: the map may
crop, occlude or modify a sprite. Preview matches are 8-bit comparisons of 16-bit
sources, not authoritative transforms or final placements.

The initial exterior uses the delivered complete map as its visual reference;
missing aligned building exports do not block this prototype. Verified sprite
silhouettes define a technical mask that separates 30 foreground regions while
sampling their original colors from the same map. No region is double rendered.
Editable collision rectangles are independent of artwork opacity. World/camera
settings and remaining baked-occlusion limitations belong to the
[prototype guide](../../../docs/SCHOOL_EXTERIOR_PROTOTYPE.md), not a final tile grid
or architectural plan. Future layer exports can refine this setup without
rebuilding Wayne's composition.

The additional `composite/school_antenna_mask.png` and
`composite/school_antenna_underlay.png` separate two exposed antenna pairs while
preserving the original mask, underlay and all delivered PNGs. Their 685 selected
pixels reuse original map colors and verified ground/rear-boundary samples;
these are technical stencils/compositing data, not replacement artwork. The
prototype guide describes their fade behavior and roof attachment limits.
