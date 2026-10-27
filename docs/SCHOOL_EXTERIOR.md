# School Exterior environment

## Status and entry

The School Exterior Level 1 environment and Bedroom-to-School handoff are
implemented, runtime-validated and manually accepted by the Project Lead.
Wayne's complete map remains the visual authority; original artwork and editable
sources are preserved. Scene 02 preparation from `b40ab47` remains intact.
Scene 03 narrative, NPCs, dialogue, objectives and new Sanity effects are not added.
The [story wrapper](../scenes/story/school_exterior_story.tscn) reuses this same
playable scene for sidewalk arrival. F5 starts Dream; open
[school_exterior_playable.tscn](../scenes/gameplay/school_exterior_playable.tscn) with F6
for independent preview.

The story wrapper still uses its `Laboratory` instance name, and the environment keeps
its `SunShadowPrototype` node name for existing preview and controller NodePaths.
Those names do not indicate duplicate or disconnected gameplay.

## Scene and world

The playable scene instances [school_exterior_room.tscn](../scenes/environments/school_exterior/school_exterior_room.tscn),
the published [Player](../scenes/player.tscn), and its unchanged
[movement controller](../scripts/player_movement.gd). World origin is the top-left
of the original 1455 × 1467 map. The environment is provisionally enlarged by
1.1475× to 1669.6125 × 1683.3825 world units, using nearest filtering without resizing
source images. Spawn is `(671.2875, 1365.525)`, transformed from `(585, 1190)` inside
the south campus. The additional 2% enlargement from 1.125× passed manual visual review.
Additional room markers identify the courtyard, north approach and south road;
they are editor aids, not transitions or a spawn-selection system.

The story wrapper adds `SchoolArrivalSpawn` at `(183.6, 1484.865)` world units,
equivalent to source-map `(160, 1294)`, on the lower-left grey sidewalk outside
the southern wall. Its 14 × 10 feet rectangle is clear of all barriers and lies
below the wall and above the curb. The wrapper places Albert and updates the
camera under an opaque overlay before revealing the scene over 0.35 seconds;
movement resumes after the fade. The standalone playable scene retains its original
inside-campus testing spawn. No map, Player or camera is duplicated.

A runtime walking check followed the sidewalk east toward `(568.0125, 1484.865)`,
then north through the existing pedestrian opening toward `(568.0125, 1365.525)`.
The route stays off the road and crosses the perimeter only through the opening.

The child Camera2D follows directly at 2× zoom, with limits `(0, 0)`–`(1669, 1683)`.
These integer limits round inward from the fractional map edges to avoid empty
space; less than one world unit at the far right/bottom is outside the camera range.
Smoothing and drag margins are off. The existing project viewport stays 1280 × 960.
Albert keeps the accepted sprite frames, animation helper, 150-unit speed,
normalized diagonals and WASD/arrow mappings. Albert inherits the shared Player's
original 2× sprite scale; the previous School-only 1.8× override was removed.
His opaque feet still end at the Player's ground origin. The environment is
larger around him; Player physics and camera zoom are unchanged.

Only this playable scene overrides the Player instance's collision to a 14 × 10 feet
rectangle at `(0, -5)`. This fits the narrow school paths without editing the
shared Player or any Bedroom instance. Review this footprint during manual testing.

## Artwork and occlusion

The full-map PNG is an unchanged copy of Wayne's delivered `fullschool.png`.
Its SHA-256 is `d62b703588406e282296ecc311ad58956be921f7a2388d61bda3c5c3977df400`.
Original 16-bit source bytes and all source archives are preserved.

Wayne's corrected delivery adds the previously missing aligned building export as
`structures/school_buildings.png`. Its Layer 4 matches the retained trees/front-lamps
export byte for byte. The complete map, standalone sprites, technical masks and
underlay are unchanged, so the running scene does not stack the new building layer
over its existing map. No scene/resource reference, collision, camera, spawn or
foreground-fading change was needed for this asset migration.

A technical 8-bit mask separates 30 foreground regions: 13 trees, 14 lamps,
two gatehouses and the reliably matching waiting-shed pixels. It contains object
IDs in alpha, not replacement artwork. `occlusion_regions.json` records each
source silhouette, rectangle, ID and unmatched-pixel count.

[school_background_mask.gdshader](../shaders/school_background_mask.gdshader)
discards those marked pixels from the background. Independent Sprite2Ds sample
the **same original map** through region rectangles and
[school_foreground_mask.gdshader](../shaders/school_foreground_mask.gdshader),
which accepts only their own mask ID. Thus no object is drawn twice and no source
color is repainted to match a separate sprite export. Region roots sit at their
lower edge and participate with Albert in built-in Y sorting.

Map/underlay sprites and each foreground sprite use the same 1.1475× visual scale.
Foreground root positions and sprite offsets are transformed by that factor so
Y-sort origins, mask regions and underlays stay aligned. Source rectangles, mask
IDs and cutoff metadata remain in original map-pixel coordinates. The controller's
inverse map transform maps world overlap checks back to those coordinates.
The map shaders use a shared screen-to-map pixel grid and nearest-texel selection,
including the underlay, so cropped foreground sprites sample the same pixels as
the full map. The calculation uses the map origin `(0, 0)` and common sprite scale;
it avoids gatehouse mask holes caused by per-region UV rounding at fractional scale. Nearest filtering keeps hard edges; this noninteger scale can still give
source pixels uneven two/three-pixel widths on the 2× camera view.

Only alpha pixels whose preview RGB matched the organized source silhouette
within one 8-bit level were lifted. Most source objects match completely; one
tree and the shed have 36 and 157 overlapping/mismatched pixels respectively.
Those pixels remain in their original background or another verified region.
Native rendered composition was compared against a direct render of the full PNG.

The scene-local [occlusion controller](../scenes/environments/school_exterior/school_exterior_occlusion.gd)
compares Albert's current animation-frame alpha pixels against the foreground ID
mask, accounting for sprite scale, flipping and Y-sort order. Actual obstruction
fades each eligible object independently to 65% over 0.20 seconds. A 0.06-second
clear delay prevents animation-edge flicker; opacity returns smoothly to 100%.
There are no competing per-object tweens. Tree bases, lamp bases and shed supports
stay opaque, and collisions never change during fading.

27 of the 30 foreground objects can fade: all 13 trees, all seven rear lamps,
six front lamps and the shed roof. The gatehouses remain opaque whole structures.
FrontLamp03 stays opaque because its overlap with the shed lacks an independently
separated underlying foreground layer. Buildings, walls, the other 15 cars and
unseparated decorations remain baked into the map; general roof removal is not
implemented. The north-facing `ParkedCar11` is a separate, opaque Y-sorted sprite.

`school_occlusion_underlay.png` fills only verified fadeable mask pixels behind
the background cutouts. It uses unchanged pixel samples from Wayne's ground,
props, upper-hall building, west-front building and outer-wall exports, at their
verified positions. The building below the eastern trees and the wall/building
behind front lamps are retained. No source PNG is repainted or overwritten.
The JSON records these layer sources, positions, exclusions and opaque-base cutoffs.
At normal opacity, the assembled room matches a single enlarged original map
rendered with the same deterministic nearest-texel sampling.

Two exposed rooftop antenna pairs are now additional foreground regions, bringing
the total to 32 regions and 29 fadeable groups. `WestRoofAntennaPair` covers source
pixels `(149, 707)`–`(164, 768)` beside the southern courtyard path;
`NorthRoofAntennaPair` covers `(682, 160)`–`(691, 195)` above the north wall.
Only their actual pole pixels are lifted; lower portions over blocked roofs stay
baked and opaque. Nearby roofs and walls never become fade targets.

The companion `composite/school_antenna_mask.png` adds IDs 31/32 without changing
the original mask. `school_antenna_underlay.png` copies only verified ground and
rear-boundary artist pixels into those 685 exposed pixel positions. Two cropped
underlay sprites share the existing map material, and the foreground sprites
sample the original full-map texture. The controller caches the supplemental
mask once and uses the same pixel-overlap, Y-sort, 65% opacity and transition
timing. The accepted shadow/fog receiver mask is unchanged. Fully opaque source
colors match the original rendering with fog disabled; the separated poles now
correctly draw above ground mist. This correction passed manual visual review.

## Session clock and atmosphere

The clock and seven-phase Level 1 atmosphere passed runtime checks and Project
Lead visual acceptance. Their artistic settings remain tunable.
[GameClock](../scripts/game_clock.gd) starts each application at 06:30,
advances one game minute per real second, and repeats every 24 hours. It
continues while idle, in dialogue or during scene changes. `set_time(hour, minute)`
accepts a valid 24-hour time and resumes normal ticking afterward. There are no
dates, saves, checkpoints, automatic story events or Sanity effects.
Existing scripted alarm text is separate from this atmospheric clock.

[school_exterior_lighting.gd](../scripts/school_exterior_lighting.gd) reads the
clock on the existing room root. Its configurable timeline has exactly seven
phases; each holds its target, then smoothly blends into the next over the final
60 game minutes of its interval. Night continues through midnight. Dawn blends
back to Morning without a discontinuity.

| Phase starts | Time | Ambient RGB | Lamp/window strength |
| --- | --- | --- | --- |
| Morning | 06:30 | `#c7d2db` | 0 |
| Noon | 12:00 | `#fff2de` | 0 |
| Afternoon | 15:00 | `#e5c69e` | 0 |
| Sunset | 18:00 | `#cd9296` | 0.25 |
| Evening | 19:30 | `#8585af` | 0.85 |
| Night | 21:00 | `#566784` | 1 |
| Dawn | 05:00 | `#a5a0bf` | 0.45 |

The existing map shaders add restrained per-phase saturation and contrast, shared
by the background, underlay and all foreground materials. Midnight stays blue
but retains more terrain and character detail; Dawn is a lighter violet and the
daytime targets separate cool Morning from warm Noon/Afternoon and pink Sunset.
Wayne's shadow strength varies smoothly from 1.10 at Noon to 0.58 at Night, keeping
darkness from obscuring the ground. The same seven-phase timeline interpolates
color, grading and illumination with zero slope and curvature at its endpoints.
The grading needs no extra rendering pass, blur, noise, bloom or texture. Cached uniform
updates skip unchanged grading values.

The room uses CanvasModulate and fourteen warm PointLight2D sources, without
dynamic cast shadows: all seven FrontLamp and seven RearLamp fixtures. Flagpoles
are not lights. Sources are centered on the actual luminous heads, rather than
the pole bases. In original map coordinates, front heads are at y1235 with x
`68.5, 266.5, 464.5, 748.5, 946.5, 1144.5, 1342.5`; rear heads are at y87 with x
`70, 268, 466, 750, 948, 1146, 1344`. All positions follow the existing 1.1475×
scale. A shared technical falloff texture gives each head a warm core and a soft
downward ground pool, with maximum energy 1.50. Its upper falloff is limited to
avoid illuminating roofs behind the lamp.

Three parked vehicles have paired nighttime headlights: black `ParkedCar02`,
red `ParkedCar04` and red `ParkedCar05`. Their source sprites match the map at
`(642, 1002)`, `(878, 1002)` and `(1356, 1003)`. All face south, inferred from
the broader lower windshield. The artwork has no separately drawn headlamp
lenses, so the sources use the lower front bumper corners. No car artwork,
position or collision is changed. Each pair uses two PointLight2Ds sharing the
technical `lighting/headlight_beam.png` falloff: short, soft-edged, slightly warm
cones extending 64 source pixels south into the open aisle. Maximum energy is
0.90; there are no dynamic cast shadows. These chosen beam footprints avoid
buildings and other parked cars, rather than implementing general light occlusion.
The existing phase light strength drives their late-evening fade-in and
dawn/morning fade-out. These six accepted south-facing lights remain unchanged.

The original 16 cars share a south-facing window/body layout. White
`ParkedCar11`, in the upper row of the lower parking area, is now reoriented
180 degrees at runtime. Its complete 39 × 59 source region at `(688,1096)` is
sampled in reverse on both axes by the foreground shader. A matching ground
patch samples Wayne's aligned ground layer beneath the old baked car. No source
PNG is edited, and the new opaque artwork shares the existing foreground
Y-sorting and atmospheric grading.

Its north-facing bumper sources are `(694.5,1096.5)` and `(720.5,1096.5)` in native
map coordinates. The two additional lights rotate the existing beam resource
180 degrees, using the same energy, color, scale and phase controller as the
six south-facing lights. Their short cones cross open pavement without a nearby
building or vehicle in their paths; general headlight occlusion is still absent.
The ground-receiver cutout follows the rotated silhouette, including the mirrors,
and only this car's asymmetric shadow-model vertices are rotated. Its centered,
symmetric rectangular collision footprint and parking position are unchanged.
The north-facing addition passed focused runtime checks and Project Lead visual
acceptance.

Twenty-three selected window pairs (46 glass panes) receive additive emission,
with maximum alpha 0.78. These span all three rows of the eastern window facade,
the visible middle-west facade and both rows of the southwest building. Half of
the 46 fully identified, unobscured window pairs remain dark. Group brightness
varies from 70% to 100%, with three warm tints and a small soft glow around each
lit pair. Emission is inset one source pixel inside the glass; frames, dark
windows and original artwork remain unchanged.

Selective interior lighting adds 13 opening groups without changing those 46
panes. The [interior shader](../shaders/school_interior_light.gdshader) uses the
original artwork as its stencil, preserving frames, columns, doors and railings.
Open corridor recesses receive restrained reflected light rather than being
treated as glass. The selective lighting passed Project Lead visual acceptance.

| Area | Selected openings, in native map coordinates |
| --- | --- |
| Upper east wing | Upper floor bays 2, 6, 9 at y338; middle bays 1, 4 at y400; lower bays 3, 7 at y462. Bay rectangles start at x688 + 76 × zero-based bay index, sized 62 × 27. |
| Canteen | Three recessed openings at `(125,279)`, `(254,279)`, `(318,279)`, each 49 × 23. The other two remain dark. |
| Building left of canteen | One existing window pair at `(29,333)`, sized 37 × 19. |
| North/south guardhouses | Existing front glazing at `(522,190)` and `(522,1256)`, each 17 × 8. |

The selected rooms use different fixed warm intensities, without flickering or
symmetry. A shared interior strength peaks at 0.42 and follows the existing
seven-phase light strength and 0.6-second override blend. Guardhouse emission is
attached to each existing Y-sorted guardhouse, so it cannot paint over Albert
when he stands in front. Two small downward spill lights use the existing lamp
falloff at `(530.5,198)` and `(530.5,1264)`, with maximum energy 0.28 and quarter
size. Morning/Noon interiors are off; Evening/Night illuminate and Dawn fades.
The original post lamps, headlights, window panes and phase palette are unchanged.

The two existing mask shaders now accept built-in lighting; their shared texel
sampling and mask/fade logic are unchanged. Lights affect the world canvas only;
dialogue, HUD and transition overlays remain on separate CanvasLayers. Window
emission is unshaded and additive. Lamp pools can light nearby wall faces; they
do not simulate physical shadow casting or building-aware light occlusion.

Wayne's transparent 823 × 829 shadow-only delivery is a reduced full-map export:
lamp-base diagonals, tree footprints, building corners and the south wall match
the map. An authorized nearest-neighbor runtime copy is aligned to 1455 × 1467
as `assets/environments/school_exterior/lighting/school_shadows_aligned.png`.
The original delivery is unchanged. The background and occlusion-underlay shaders
sample this same source-pixel grid; the layer is not painted over Albert or the
separated foreground objects. A darken-only blend preserves already-dark painted
edges and prevents the gray shadow artwork from brightening darker surfaces.
Architectural shading in the original map remains intact. The reduced source
already contains resampling, so this copy cannot recover a native-resolution
export's exact edges. Shadows are static and share the seven-phase ambient tint;
unmatched details remain fixed, while the matched ground casts are replaced by
the dynamic sunlight mask described below. All original PNGs are preserved.

### School-wide sunlight shadows

The five-caster prototype and its school-wide expansion passed Project Lead
visual review. They remain provisional technical geometry for Level 1.
The existing room instances
[school_sun_shadows.tscn](../scenes/environments/school_exterior/school_sun_shadows.tscn),
driven by [school_sun_shadows.gd](../scripts/school_sun_shadows.gd).
It now contains 93 caster groups, without changing the map or collision:

| Category | Groups |
| --- | ---: |
| School buildings | 10 |
| Gatehouses and waiting shed | 3 |
| Trees | 13 |
| Lamp posts | 14 |
| Parked cars | 16 |
| Potted shrubs | 18 |
| Three-bin clusters | 4 |
| Dumpsters | 5 |
| Picnic tables with benches | 2 |
| Perimeter wall sections | 4 |
| Pedestrian gates and vehicle booms | 4 |

The original five models and anchors are preserved:

| Caster | Source-map ground anchor | Estimated model height |
| --- | --- | --- |
| Tree02 | `(235, 434)` | 90 source units |
| Tree03 | `(387, 434)` | 90 source units |
| Canteen | `(276.5, 333)` | 58 source units |
| FrontLamp02 | `(266.5, 1305)` | 80 source units |
| ParkedCar02 | `(661.5, 1031.5)` | 13.5 source units |

These heights are visual estimates, not measured real-world dimensions. Tree
models use overlapping branch tiers and a trunk, the canteen uses its footprint,
eaves and roof ridge, lamps use thin poles and housings, and cars use low
body/cabin profiles. Other school wings use flat roofs, eaves and parapets;
the shed has a curved canopy, supports and back panel. Shrubs, slatted gates,
raised booms, sloping dumpster lids, separate cans and table/bench legs have
their own geometry. Saved vertices carry their height above the ground;
projection offsets those vertices from each fixed base. No source sprite is
stretched or copied into a shadow. Contact polygons remain present at night.

One analytic sun reads GameClock: configurable sunrise 05:00, sunset 19:00 and
peak elevation 68 degrees. Shadows point west/down in the morning, down near
noon and east/down toward sunset. Their length follows elevation with a smooth
3.2-times-height upper bound. The added building wings also have a smooth
320-source-pixel reach limit so their shadows cannot span indefinitely across
unrelated structures. Opacity eases out below 16 degrees and reaches zero at
night. The expansion uses a restrained cool tint, maximum sunlight opacity 0.30
and contact opacity 0.14; the seven ambient phase colors are unchanged.
Direction, length, tint and opacity are continuous through phase
boundaries and midnight. Time overrides use the lighting controller's existing
0.6-second blend duration and replace unfinished interpolation.

One offscreen 1455 × 1467 source-pixel mask stores sunlight, contact, valid ground
and selected static-shadow replacements in its RGBA channels. Ground receivers
cover the complete map. Existing aligned building, prop, tree/lamp and wall
artwork supplies alpha stencils that exclude painted roofs, faces and objects.
The foreground IDs leave ground available beneath fading canopies/posts/shed;
underlying building surfaces stay excluded. The existing map/underlay shaders sample the mask
on their shared pixel grid; Albert, foreground artwork and UI receive no overlay.
The canopy remains a caster when its artwork fades for visibility. Native-pixel
edges stay sharp at the existing 1.1475× scale. Geometry updates are limited to
about 12.5 Hz normally, run each frame during overrides and stop when sunlight
is invisible. A cached swept-bound test includes offscreen casters whose shadows
reach the view, but skips irrelevant geometry. The mask redraws only when its
visible geometry or visibility changes. No new lights or shadow textures are added.

Forty-three individually inspected regions of Wayne's overlay are suppressed
only on receiving ground. Eleven regions retain small residual/contact details,
including the library's front contact strip and a right-edge tree stamp whose
source caster is not independently verified. Painted outlines remain intact.
The replacement/retention polygons are editable scene nodes, not destructive
artwork edits. Disabling the prototype restores the original static contributions
as well as removing the dynamic mask.

For comparison, run the playable scene and select **Remote → SchoolExterior →
SunShadowPrototype**. Under **Development preview**, select 07:00, 12:00, 16:00,
18:00, 21:00 or 05:30, then tick **Preview Now**. Toggle **Prototype Enabled**
to compare with the accepted static layer. These are development controls only.

The expansion's estimated heights, receiver stencils and static reconciliation
remain provisional despite visual acceptance. Invisible map-bound barriers, flat litter
and ambiguous roof-mounted rails do not get separate casters. The unmatched
right-edge tree stamp remains static. Shadows stop at non-ground surfaces; they do not
continue onto walls or implement mutual object shadowing. There are no dynamic
lamp/headlight shadows or soft penumbrae. First-use renderer compilation can
hitch. Focused runtime captures cover the day/night previews, building/prop
close-ups and five culling viewpoints. Warmed on/off samples both remained near
60 FPS on Intel UHD 620; this short comparison is not a performance guarantee.

### Continuous ground mist

The [fog scene](../scenes/environments/school_exterior/school_ground_fog.tscn) is implemented,
runtime-checked and Project Lead-accepted.
Its reusable [controller](../scripts/environment_fog.gd) reads GameClock and the
existing lighting timeline. One [procedural shader](../shaders/ground_fog.gdshader)
draws a single 1455 × 1467 source-map field. Eight geographic density controls
favor the north/south courtyard lawns, east tree-lined walkway, west building
approach, parking verge, south sidewalks and northeast perimeter. These are
continuous spatial weights, not separate rendered cards. Smooth long-tail
falloffs and a saturating union join the pockets without clipping edges or
stacked transparency. A very thin background weight connects quieter ground
areas. No helper images, particles or additional render targets are needed.

The scene uses the map's 1.1475× transform and the accepted shadow mask's blue
ground channel. Roofs, painted faces, cars and other solid artwork are excluded.
Mist draws above the map and below Albert and the Y-sorted foreground; fading
trees and the shed still reveal the underlying ground. Dialogue, Object Focus,
Sanity and Time HUD layers receive no effect. `density_pockets` stores native
map centers/radii and `pocket_strengths` stores their weights; both can be tuned
on the existing GroundFog node without rebuilding geometry.

Source-pixel sampling keeps the field anchored during camera movement. Three
continuous noise scales form uneven banks and elongated wisps, drifting about
0.50–1.35 source pixels per real second. The continuous density weighting has no
internal rectangle boundaries. Density is optical depth, converted to translucent
alpha after shape weighting, with a per-pixel cap of 0.52. Clear gaps remain
between the mist banks. Overrides blend
density, color and drift velocity for 0.6 seconds from the current visible state;
they do not relocate the mist or count through skipped times. Interrupted blends
use the newest target. Clock speed and story behavior are unchanged.

| Phase | Existing start | Optical depth before spatial/noise weighting |
| --- | --- | ---: |
| Morning | 06:30 | 0.240 |
| Noon | 12:00 | 0.002 |
| Afternoon | 15:00 | 0.004 |
| Sunset | 18:00 | 0.080 |
| Evening | 19:30 | 0.220 |
| Night | 21:00 | 0.440 |
| Dawn | 05:00 | 0.720 |

Profiles interpolate over each whole phase, including midnight and Dawn back
to Morning. Morning mist gradually dissipates; Noon and Afternoon are nearly
clear. Mist reappears through Sunset and Evening, forms visible patches at Night
and is strongest at Dawn while remaining translucent. Cool silver-blue tints
separate the mist from the ground without changing the existing ambient grading.
The continuous-field rework passed Project Lead visual acceptance.
Mist receives a small warm tint near the actual ground-light centers of FrontLamp02/04/06 and
RearLamp04/06, driven by existing lamp intensity. This is restrained tinting,
not volumetric scattering or new bloom. Fog does not cast shadows or simulate
height, and its ground stencil has hard artwork edges.

Use the existing School phase preview below, then select **Remote →
SchoolExterior → GroundFog → Development preview → Preview Fog Enabled** for
on/off comparison. The toggle is debug-only; there is no gameplay control.
Focused runtime checks covered phase continuity, interrupted overrides, idle
drift, camera anchoring, receiver masks, Albert/HUD isolation, foreground fading
and normal School arrival. Matching Dawn/Night on/off gameplay captures and a
stationary-camera motion sequence show the mist at normal artistic settings.
Warmed courtyard/street comparisons stayed near 60 FPS on Intel UHD 620; this
short sample is not a performance guarantee.

For instant development preview, run this playable scene with F6, switch the Scene
dock to **Remote**, select `SchoolExterior`, choose **Development preview →
Preview Phase Index**, then tick **Preview Now**. This debug-only action sets
the shared session clock, clears the checkbox and resumes normal ticking. It
does not save a starting time. A new application run returns to 06:30. Future
approved story callers can use `GameClock.set_time(14, 0)` explicitly.

### Animated time indicator

The School playable scene instances the reusable
[Time HUD](../scenes/UI/time_hud.tscn), driven by [time_hud.gd](../scripts/time_hud.gd).
It reads GameClock and displays 12-hour time without owning a second clock. This
UI is runtime-validated and manually accepted. It is instanced in both Bedroom and School laboratories. The Bedroom
story hides it during the wake-up/phone/reflection sequence and enables it when
exploration begins; direct Bedroom playable scene runs show it immediately. The clock
itself already ticks globally during the opening, and no room entry resets it.
The original scripted 06:30 alarm label is unchanged.

Its small screen-space panel starts at the top left, opposite the normal Sanity
HUD. School now instances that same existing Sanity HUD as well. Placement uses
the viewport and actual visible UI rectangles, including
Sanity, top/bottom dialogue, Object Focus and existing prompts. It moves between
clear edge positions over 0.3 seconds, hides while crossing an occupied region
or when no safe position exists, and fades back in when clear. Visible arrival
and scene fades suppress it, including fades on lower UI layers. Future UI can
join `time_hud_obstacles` or be assigned through the
HUD's `avoid_controls` paths; the other UI systems need no behavior changes.

Normal minute changes use a 0.24-second clipped number slide/crossfade. Explicit
`set_time()` calls additionally emit `time_overridden(previous_minutes,
current_minutes)` after updating the clock, before the existing minute notification.
Jumps of at least two minutes use a 0.6-second HUD transition; School ambient
color and light strength also blend over 0.6 seconds beneath existing fades.
New overrides replace unfinished transitions. Time itself changes immediately,
and its initial time, real-time speed and midnight wrap remain unchanged.
No skipped minutes are counted visually. Each viewport keeps one HUD instance.

To review, run the School playable scene with F6, watch a one-second tick, then use
the existing Remote School phase preview to jump between Morning and Night.
The clock text and lighting should transition together. The existing story
wrapper receives the same HUD through its playable scene instance.

Focused native checks cover ticking/overrides, the midnight wrap, all seven phase
boundaries, illumination changes, unchanged mask composition, all 27 foreground
fade targets, UI isolation and the existing Bedroom-to-School departure. Palette,
night readability and light placement remain provisional for further tuning.

## Editable collision

The room contains 99 named StaticBody2D rectangle barriers grouped under
Buildings, WallsAndGates, Trees, StreetFurniture, Vehicles and MapBounds. They were
hand specified from the visual layout, not generated from opaque pixels. Shared
shape resources with equal dimensions can be made unique in Godot before tuning
one instance independently.

Collision positions and the actual RectangleShape2D dimensions are multiplied by
1.1475 in the saved room. The room, physics groups, all 99 bodies and all collision
nodes retain unit scale; physics is not scaled through a parent. Markers use the
same coordinate transform. The Player's 14 × 10 feet remain unscaled.

The four long perimeter walls now cover the complete solid wall faces rather
than only their upper strips. Original map bounds are y172–211 for both north
sections and y1238–1277 for both south sections; each is 44.7525 world units high
at 1.1475×. Their horizontal endpoints and gate openings are unchanged. Extending
the southeast wall also seals the narrow return route around the closed south
vehicle boom; no extra barrier was added, so the total remains 99. These
corrections passed focused runtime checks and manual review.

The northwest service slot retains its exposed paving and original obstacle
spacing. The northeast approach remains reversible, but its former continuation
through the painted wall/building footprint is blocked. No separate closure was
added to either narrow approach; future access design remains subject to review.

Buildings are conservatively closed; ground-floor approaches/stairs remain outside
their barriers and do not enter interiors. Courtyard stone bands are walkable
sidewalks, not fences. Trees/lamps use base collisions; the shed uses supports/back
instead of treating its whole canopy as solid. Vehicles, tables, planters and
bins have simple initial footprints. These are prototype approximations, not
artist-approved architectural collision plans.

The following footprints are in original map coordinates; the saved room stores
their positions and dimensions multiplied by 1.1475.
Waste containers were checked by their placed artwork. Four three-bin groups
(12 individual cans) use 28 × 8 footprints. Three were already present; `Bins04`
adds the missing group at footprint `(119, 336, 28, 8)`. The accessible dumpsters
use 19 × 12 ground footprints: corrected `Dumpster01` at `(95, 299, 19, 12)`,
new `Dumpster04` at `(95, 260, 19, 12)` and new mirrored `Dumpster05` beside the
shed at `(420, 1063, 19, 12)`. Their lids are not full-height barriers.
Two existing east-edge dumpsters remain behind the unchanged map inset; their
original barriers are preserved. Flat leaf litter and shadows have no added
collisions. Some bin sides abut buildings or the shed and are not approachable;
use the existing open routes rather than expecting a full circuit around each.

Closed vehicle booms and the north pedestrian gate are solid. The open south
pedestrian gap is passable in both directions, allowing access to the south road.
Map-edge barriers include small visible-sprite safety insets. No gate behavior or
interaction system is implemented. Real collision routes and corner comfort still
require Project Lead review; passing automated probes does not establish perfection.

## Manual review

1. Open the development project's `project.godot` in Godot 4.7.2 and wait for
   resource imports. Open the exterior playable scene above and press F6. F5 continues
   to start Dream; after the Bedroom introduction and all three preparations,
   Door Yes now enters the School story wrapper. The F6 playable scene is unchanged.
2. Move with WASD/arrows, including diagonals, stopping and reversing.
3. Explore north on the central road, left through the grass courtyard, right
   along the east-hall frontage, and through the parking aisles.
4. Test building faces, tree bases, cars, tables, bins and gate barriers. Use
   Debug > Visible Collision Shapes to inspect/edit the initial geometry.
5. Use the open pedestrian gap beside the south gatehouse to reach the outer road
   and return. Try rounding the closed vehicle boom at its east end from both
   sides, including diagonals; the corrected wall/boom join should block passage.
6. Walk behind/in front of trees, lamps and the waiting shed. Check smooth 65%
   fading/restoration, intact underlays and solid bases/supports. The gatehouses
   and shed-adjacent FrontLamp03 intentionally remain opaque. Review scale,
   leftover baked occlusion and corner behavior.
7. Check that the camera stops at map edges and the artwork remains sharp. Stop
   the game after testing. School free exploration is the current endpoint; no
   Scene 03 narrative or further story transition is implemented.

The catalog is [a TSV in docs/art](art/school_exterior_asset_manifest.tsv) so Godot
does not import it as CSV translations. No private tooling/configuration is needed.
