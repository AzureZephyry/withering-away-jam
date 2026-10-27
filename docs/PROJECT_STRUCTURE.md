# Project structure

This guide maps the game implementation, including the accepted first playable
Sanity integration, Dream-to-Bedroom introduction (`fad8a76`), and accepted Dream
signal repair (`eef63da`). The introduction passed 156 automated checks and received Project
Lead acceptance on October 20, 2026. Start with the
[README](../README.md) for setup and controls; use the system guides linked below
for detailed APIs and authoring steps.

Godot scenes assemble nodes and reference scripts and resources. Shared behavior
lives mainly in `scripts/`, artwork and animation resources in `assets/`, and
production hosts in `scenes/gameplay/`. Their maps/rendering resources live in
`scenes/environments/`; independent Garden and School Interior experiments remain
in `scenes/prototypes/` beside their drawing helpers. Story wrappers instance the
production hosts, which also remain runnable with F6. Existing `Laboratory` node
names are preserved because scripts use those NodePaths.

The earlier `590184b` snapshot remains historical evidence; the introduction
components below are now published. This guide does not audit other branches.
Scene 02 was published in `b40ab47`; this release adds its accepted School
Exterior handoff and atmospheric systems. For player-facing sequence order use [Game flow](GAME_FLOW.md); for intent and constraints use
[Design decisions](DESIGN_DECISIONS.md). [Team progress](TEAM_PROGRESS.md) owns the
current status snapshot, and [Development history](DEVELOPMENT_HISTORY.md) owns
the milestone record.

Scenes are saved node hierarchies; instances reuse those hierarchies and may attach
scripts or override properties in the hosting scene. Resources such as SpriteFrames,
textures, fonts, shapes, and shaders are referenced by scenes/scripts. `GameState`
and `SanityState` are separate public gameplay Autoloads; cameras, environmental
controllers, and HUD instances remain scene-local.

The shared `GameClock` Autoload is a third, independent session service. It owns
only repeating time of day; it does not own story flags or Sanity. The existing
School room reads it for seven-phase atmosphere through its scene-local lighting
controller. This addition is runtime-validated and manually accepted. See [School atmosphere](SCHOOL_EXTERIOR.md#session-clock-and-atmosphere)
for timing, light locations and development preview controls.


The production scene organization preserves scene UIDs, node identifiers, Player/camera behavior and
the existing School rendering geometry. The hidden old Dream wake-up placeholder
and Scene 02 Return endpoint are removed; the active white Dream-art placeholder,
real Bedroom introduction, door recovery and School handoff remain. Historical
milestone records retain their original filenames. Raw phone originals and import
sidecars are recoverably archived outside the runtime project under the sibling
artwork-source archive's `phone-originals/2026-10-27/` directory.

## Directory map

This is a curated map, not a complete inventory. Import metadata and most UID
sidecars are omitted from the tree.

```text
project.godot
assets/
  characters/albert/              # Original sprite sheets and SpriteFrames
  environments/school_exterior/   # Composite, masks, source variants and lights
    composite/  foliage/  foreground/  ground/
    lighting/   props/    structures/  vehicles/
  fonts/                          # Existing font and import metadata, unchanged
  placeholders/scene02/           # Four active SVGs + imports
  ui/
    dialogue/                     # Dream and Reality final artwork
    phone/prepared/               # 16 runtime PNGs + imports and preparation guide
    sanity/                       # Seven PNGs + imports; zero-state AtlasTexture
  music/  sounds/                 # Future audio markers; no audio tracks yet
scenes/
  player.tscn                     # Shared actor
  game.tscn                       # Historical movement/camera sandbox
  story/
    dream_story.tscn              # Configured main scene
    bedroom_story.tscn            # Introduction + Scene 02 wrapper
    school_exterior_story.tscn    # Sidewalk arrival wrapper
  gameplay/
    bedroom_playable.tscn         # Standalone F6 exploration + fixed camera
    school_exterior_playable.tscn # Standalone F6 campus + atmosphere/HUDs
  environments/
    bedroom_room.tscn
    school_exterior/
      school_exterior_room.tscn
      school_sun_shadows.tscn     # 93 caster groups and receiver mask
      school_ground_fog.tscn      # One continuous field; eight density controls
      school_exterior_occlusion.gd + .gd.uid
  UI/
    dialogue_panel.tscn           # Shared presentation, not a conversation owner
    overworld_overlay.tscn
    object_focus_overlay.tscn
    bedroom_scene02_overlay.tscn  # Checklist, door decision and departure fade
    objective_marker.tscn
    time_hud.tscn  sanity_hud.tscn
    phone_conversation.tscn
    eyelid_effect.tscn  eyelid_effect.gd  eyelid_effect.gdshader
    dream_deterioration.gdshader
  prototypes/
    garden_camera_lab.tscn  school_camera_lab.tscn
    bedroom_prop.gd  pixel_floor.gd  pixel_prop.gd
    garden_ground.gd  garden_prop.gd  garden_overhang.gd
    rooms/garden_room.tscn  rooms/school_room.tscn
  tests/
    bedroom_intro_test.tscn
    sanity_tests.gd  sanity_tests.tscn
    scene02_tests.gd  scene02_tests.tscn
scripts/                          # Shared/feature scripts + UID sidecars
  player_movement.gd  albert_animation.gd
  opening_sequence.gd  bedroom_intro.gd  bedroom_scene02.gd
  school_exterior_arrival.gd
  text_type.gd  dialogue_panel.gd  phone_conversation.gd
  overworld_interactable.gd  overworld_interaction.gd
  garden_lily_interaction.gd  object_focus_presenter.gd
  game_state.gd  sanity_state.gd  game_clock.gd
  sanity_hud.gd  time_hud.gd
  school_exterior_lighting.gd  school_sun_shadows.gd  environment_fog.gd
shaders/                          # Six world shaders + UID sidecars
docs/                             # Current guides, decisions and retained history
  SCHOOL_EXTERIOR.md
  art/school_exterior_asset_manifest.tsv
```

The unused sample-character library is removed after dependency checks and
verified external recovery archival. Albert's
active sheets remain unchanged in `assets/characters/albert/`.

[School Exterior artwork](../assets/environments/school_exterior/README.md)
documents Wayne's corrected delivery, original-name mapping, source-only
references and technical compositing data. The complete map remains authoritative
when partial exports differ. The original ZIP and two
Krita projects are preserved outside the game repository. The separate
[School Exterior guide](SCHOOL_EXTERIOR.md) describes the
accepted integration using the complete map, without adding Scene 03 narrative.

Contributor procedures live in the [Git handbook](GIT_WORKFLOW.md), with
[existing-clone synchronization and recovery](GIT_EXISTING_CONTRIBUTORS.md) as its
companion. This guide remains the reference for actual game-file dependencies.

[Sanity design](SANITY_DESIGN.md) is the primary approved design reference for
Sanity, environmental transformation timing, session-only checkpoints, and HUD
direction. The first playable Sanity integration is implemented, automatically
validated, and Project Lead-accepted. Each laboratory owns one HUD; the story
wrapper reuses Bedroom's instance.

## Main entry point: Dream opening

[project.godot](../project.godot) configures
[scenes/story/dream_story.tscn](../scenes/story/dream_story.tscn) as the main scene. F5 runs this scene.
Its `OpeningSequence` Control uses
[opening_sequence.gd](../scripts/opening_sequence.gd) to advance a provisional
sequence of lines and events:

1. Centered dialogue on black.
2. Eyelids opening onto a white Dream background placeholder.
3. Dream-themed dialogue, individual glitch cues, and gradual deterioration.
4. A waking fade to black, followed by a deferred handoff to the playable Bedroom.

The sequence ends by emitting `sequence_finished`; its local consumer defers
loading the story Bedroom so awaited callbacks can unwind. Dream itself has no
overworld Player. The Bedroom now owns the three waking lines and 6:30 AM clock.
Audio cue signals are integration points;
the current scene does not play finished music or alarm assets. The dialogue,
timings, and placeholder backgrounds are not final narrative or visual direction.

## Story Bedroom and phone components

The published [bedroom_story.tscn](../scenes/story/bedroom_story.tscn) root uses
[bedroom_intro.gd](../scripts/bedroom_intro.gd). Its `Laboratory` child instances
the existing Bedroom playable scene without changing its saved defaults. `StoryLayer`
is CanvasLayer 4 and contains the shared Reality DialoguePanel, PhoneConversation,
clock, and arrival fade. This preserves the playable scene's room, Player, camera,
and notebook/card targets.

The story controller is the single input/progression owner during arrival,
waking dialogue, buzz, reaction, phone, and reflection. It disables its panel
body's independent key handler, saves Player physics state, calls
`interactions.set_suspended(true)`, and restores both only after final reflection.
Environmental input is not used to drive the scripted introduction.

| Component | Responsibility and public entry |
| --- | --- |
| `bedroom_intro.gd` | `EntryContext.STORY`, `REENTRY`, or `DEVELOPER_TEST`; `configure_entry(context, entry_position)` before tree insertion; `introduction_finished(branch)` and `audio_cued(cue_id)` signals |
| `phone_conversation.gd` | `open_conversation()`, `advance()`, choice navigation/confirmation and hit testing; `finished(branch)` emits after an additional input on the last screen |
| `phone_conversation.tscn` | Full-viewport dimmer, centered 640 × 1088 PhoneCanvas, Artwork, and ChoiceOutline; no independent input owner |
| `bedroom_intro_test.tscn` | Instances the same story scene with developer context, bypassing completion reads/writes; rerun with F6 for each branch |

`configure_entry` takes room-local coordinates (the laboratory has an identity
transform). Completed story entries skip the introduction and use the supplied
entrance. No room router is added. The ordinary Bedroom F6 entry does not invoke
the story controller or write completion.

Current provisional defaults are bedside **(144, 176)**, future entrance fallback
**(464, 304)**, arrival fade **0.35 s**, buzz shake **0.32 s** at strength **1.5**,
and phone scale **0.75**. The camera offset is restored after shake. Phone layout
uses a common viewport center and uniformly shrinks only when needed to fit
16-pixel margins; it never compensates per-image silhouette widths. Dimmer alpha
is **0.32**; the gold outline uses a **3-source-pixel** border and shared image-space
hit regions. These are accepted prototype defaults; final production values remain tunable.

The phone preloads all 16 transparent copies in `assets/ui/phone/prepared/`.
Original opaque PNGs are preserved and unused by this overlay. Branch order and
reflection text belong in [Game flow](GAME_FLOW.md#phone-screens-and-choices).
The Sanity integration adds +1 at Option 3 commitment; Options 1/2 remain
neutral. Its existing narrative/completion behavior is unchanged. Final phone-buzz audio is
pending; the controller exposes an integration cue rather than generating audio.

### Scene 02 components and School departure

[bedroom_scene02.gd](../scripts/bedroom_scene02.gd) belongs to the story wrapper's
`Scene02` child, instanced from
[bedroom_scene02_overlay.tscn](../scenes/UI/bedroom_scene02_overlay.tscn). It waits
for the introduction's exploration handoff, listens for successful required
interactions, writes the three preparation flags, and owns the checklist and
Bedroom-specific door decision. The accepted Yes handoff fades into
[school_exterior_story.tscn](../scenes/story/school_exterior_story.tscn), manually accepted. Its [arrival script](../scripts/school_exterior_arrival.gd)
uses a named outside-sidewalk marker and fades in before restoring control.
The wrapper instances the same School playable scene; it does not copy map
geometry or add a second Player/camera. Autoload flags and Sanity survive.
Not Yet remains Bedroom exploration; Scene 03 narrative is not implemented.

The room supplies repeatable notebook, Student ID, and medal targets plus four
instances of [objective_marker.tscn](../scenes/UI/objective_marker.tscn). The first
three guide incomplete inspections; the door marker appears after all three.
Markers hide during scripted/modal presentation and do not own interaction input.
The medal visual adds no collision. Existing furniture and doorway collision remain.

[object_focus_overlay.tscn](../scenes/UI/object_focus_overlay.tscn) sits behind
dialogue in the shared environmental overlay and uses
[object_focus_presenter.gd](../scripts/object_focus_presenter.gd). It observes
interaction and actual panel visibility, handles transparent padding and dimming,
and fits artwork centered at half viewport width, vertically clear of dialogue
and the Sanity HUD. It owns no input, movement, flags, Sanity or completion.
Missing artwork falls back to ordinary dialogue.

`assets/placeholders/scene02/` contains `planner_focus.svg`, `student_id_focus.svg`,
`graduation_medal_focus.svg`, and the small room sprite `graduation_medal_prop.svg`,
each with a matching `.import` sidecar. These are replaceable temporary drawings.
[scene02_tests.tscn](../scenes/tests/scene02_tests.tscn) runs
[scene02_tests.gd](../scenes/tests/scene02_tests.gd), which reuses the Sanity test
harness. Keep both new scripts' and the test script's `.gd.uid` files.
See [Scene 02 flow](GAME_FLOW.md#scene-02--first-morning) and
[Object Focus](overworld_interactions.md#object-focus) for the detailed contracts.

## Playable scenes and room resources

Open a laboratory and use F6 for movement testing. Each laboratory instances
[player.tscn](../scenes/player.tscn), attaches the movement controller to its Player,
and supplies a camera. Its room resource contains environment visuals, collision
nodes, and any room-authored interaction targets. Running a room resource alone
does not reproduce the complete playable setup.

| Laboratory | Room resource | Current responsibility |
| --- | --- | --- |
| [bedroom_playable.tscn](../scenes/gameplay/bedroom_playable.tscn) | [bedroom_room.tscn](../scenes/environments/bedroom_room.tscn) | Refined Bedroom prototype, fixed 2.5× camera, repeatable notebook/ID/medal inspections |
| [garden_camera_lab.tscn](../scenes/prototypes/garden_camera_lab.tscn) | [garden_room.tscn](../scenes/prototypes/rooms/garden_room.tscn) | Dream Garden prototype, continuous-follow 2.5× camera with room limits, Corpse Lily interaction |
| [school_camera_lab.tscn](../scenes/prototypes/school_camera_lab.tscn) | [school_room.tscn](../scenes/prototypes/rooms/school_room.tscn) | School Interior prototype, continuous-follow 2.5× camera with room limits |
| [school_exterior_playable.tscn](../scenes/gameplay/school_exterior_playable.tscn) | [school_exterior_room.tscn](../scenes/environments/school_exterior/school_exterior_room.tscn) | Local School Exterior, 1.1475× environment, original 2× Albert sprite, bounded 2× camera, 99 unit-scale physics barriers and 33 sorted foreground groups (29 fadeable); manually accepted |

**Bedroom:** the Camera2D is a sibling of Player, framing the 512 × 384 room.
`OverworldInteraction` owns the dialogue overlay. The room uses
[pixel_floor.gd](../scenes/prototypes/pixel_floor.gd),
[pixel_prop.gd](../scenes/prototypes/pixel_prop.gd), and
[bedroom_prop.gd](../scenes/prototypes/bedroom_prop.gd) for temporary drawings;
collision shapes are authored in the scene. Its right door is a closed placeholder,
not a room transition. The notebook, Student ID and medal are manual/keypress
repeatable. Only the story wrapper adds preparation objectives and door decisions.

**Garden:** Camera2D is under Player and has limits covering 2048 × 1152.
[garden_ground.gd](../scenes/prototypes/garden_ground.gd) and
[garden_prop.gd](../scenes/prototypes/garden_prop.gd) draw the environment.
[garden_overhang.gd](../scenes/prototypes/garden_overhang.gd) fades canopy/roof
groups when they cover Albert. The laboratory adds the Corpse Lily interaction
target and its visual idle animation to the room instance. Dialogue starts on
approach and becomes available again after leaving and re-entering the radius.

**School Interior:** Camera2D is under Player, with limits covering 1600 × 896. Its drag
margins and position smoothing are disabled: this is currently continuous follow,
not a dead-zone camera. The room uses `pixel_floor.gd` and `pixel_prop.gd`. The
laboratory has no environmental interaction controller attached.

This room contains classrooms, a library, and lobby/study areas. It is not the
confirmed School Exterior. The separate exterior playable scene now uses Wayne's
1455 × 1467 source map enlarged to 1669.6125 × 1683.3825 world units, a scene-local
unscaled 14 × 10 Player-foot collision shape,
and masked foreground sprites sampling the original map. See its
[guide](SCHOOL_EXTERIOR.md) for hierarchy, editable barriers and limitations.
No separate road or family-house story scene has been added. The normal Dream
route reaches Bedroom and then School Exterior after preparation and departure;
a general room-routing system remains unimplemented.

[scenes/game.tscn](../scenes/game.tscn) is an older movement/camera sandbox, not the
startup scene. It uses the shared Player, a 4× camera with horizontal and vertical
drag margins of 0.35, and a collision boundary. Its camera configuration is
separate from the three laboratories.

### Important node layouts

The following omits decorative children but preserves the ownership relationships:

```text
CameraLaboratory (Bedroom)
  Bedroom                       # Instanced room; targets live inside it
  Player                        # Shared scene + player_movement.gd
  Camera2D                      # Fixed, sibling of Player
  OverworldInteraction           # overworld_interaction.gd
    DialogueLayer               # Instanced overworld overlay
  SanityHUD                     # Combined display, CanvasLayer 3

DreamGardenLaboratory            # garden_lily_interaction.gd adapter/controller
  Garden                        # Instanced room
    Props/CorpseLily/Interaction # Target added by the laboratory
  Player                        # Shared scene + player_movement.gd
    Camera2D                    # Follow with limits
  DialogueLayer                 # Instanced overworld overlay
  LilyIdle                      # AnimationPlayer, visual bob only
  SanityHUD                     # Combined display, CanvasLayer 3

SchoolCameraLaboratory
  School                        # Instanced room
  Player                        # Shared scene + player_movement.gd
    Camera2D                    # Follow with limits
  SanityHUD                     # Combined display, CanvasLayer 3
```

The Bedroom controller's default `player_path` is `../Player`; the Garden root
overrides it to `Player`. Do not copy one path into the other hierarchy unchanged.
School currently has no DialogueLayer/controller pair.

### Other reusable scene responsibilities

| Scene | Root and important nodes | Dependencies and status |
| --- | --- | --- |
| [player.tscn](../scenes/player.tscn) | CharacterBody2D, AnimatedSprite2D, CollisionShape2D | Reusable actor structure and visuals; movement is attached by hosts |
| [dialogue_panel.tscn](../scenes/UI/dialogue_panel.tscn) | Control, Artwork, Speaker, Margin/Content/Body and Hint | Shared presentation, panel script, font, typewriter; not a conversation owner |
| [overworld_overlay.tscn](../scenes/UI/overworld_overlay.tscn) | CanvasLayer `DialogueLayer`, DialoguePanel, Prompt | Reusable environmental overlay; controller paths depend on these names |
| [eyelid_effect.tscn](../scenes/UI/eyelid_effect.tscn) | CanvasLayer, ColorRect with ShaderMaterial | Eyelid script/shader; opening instances it with its own sequence timing |

Walls/furniture use StaticBody2D and authored collision shapes in room scenes;
procedural visual drawing does not create those collision shapes. Spawn and door
markers do not themselves move a Player or switch scenes.

## Shared Player and Albert animations

[scenes/player.tscn](../scenes/player.tscn) supplies a CharacterBody2D,
`AnimatedSprite2D`, and a 24 × 40 rectangular collision shape at `(0, -20)`.
The Player root has no movement script saved in the shared scene; the hosting
game/laboratory scenes attach
[scripts/player_movement.gd](../scripts/player_movement.gd) to their Player instance.

The controller uses the `ui_left`, `ui_right`, `ui_up`, and `ui_down` Input Map
actions for WASD and arrows. It moves at 150 units per second with normalized
diagonals and `move_and_slide()`. Input and actual displacement are passed to
[albert_animation.gd](../scripts/albert_animation.gd) on the sprite.

The animation helper selects eight facing directions from five drawn directions,
mirroring only the sprite for left-facing movement. Stopping retains facing;
pressing against a blocking obstacle faces that direction while idling. The sprite
uses nearest filtering, 2× visual scale, and
[albert_frames.tres](../assets/characters/albert/albert_frames.tres), which references
Isabela's original idle and walk PNGs. Frame regions are explicit; the sheets are
not a uniform grid that can be divided automatically.

See [Albert's animation guide](albert_animation.md) before changing frames,
alignment, or animation selection.

### Animation and import dependencies

`albert_frames.tres` contains the ten drawn idle/walk animations and forty explicit
AtlasTexture regions. Its texture references resolve to
[albert_idle.png](../assets/characters/albert/albert_idle.png) and
[albert_walk.png](../assets/characters/albert/albert_walk.png). Mirroring supplies
the remaining facing directions without additional source artwork.

The PNGs' adjacent `.import` files record their source paths, import parameters,
and imported texture identities. Those point into Godot's generated import cache;
the source images and resources remain the materials to preserve and review.
Allow import completion after moving or adding assets, and check resource paths
and UID references instead of assuming a file rename updated every consumer.

## Environmental Overworld Interaction System

The reusable environmental system has three parts:

| Part | File | Role |
| --- | --- | --- |
| Object configuration | [overworld_interactable.gd](../scripts/overworld_interactable.gd) | Node2D with radius, trigger, repeat rule, world presentation, lines/speakers, and visual bounds; joins `overworld_interactables` |
| Scene-local controller | [overworld_interaction.gd](../scripts/overworld_interaction.gd) | Chooses an eligible target, handles input and dialogue lifecycle, pauses/restores Player physics, and manages placement |
| Dialogue overlay | [overworld_overlay.tscn](../scenes/UI/overworld_overlay.tscn) | CanvasLayer containing the shared DialoguePanel and E/Space prompt |

Keep one controller per playable scene, with its Player reference and a child
overlay named `DialogueLayer`. E/Space reveals a typing line, advances a revealed
line, or closes the last line. Input guards prevent the activation press or held
keys from performing several dialogue actions. The controller stops velocity and
calls Albert's idle helper while movement is locked.

Dialogue placement considers Albert's idle sprite bounds, the object's configured
visual bounds, and the panel's full artwork. It chooses a clear top/bottom position
or temporarily pans the camera within its limits, then restores it. Temporary
panning supports the current unrotated cameras with drag disabled. An impossible
layout cancels with a warning and restores control; new layouts need placement
testing.

[garden_lily_interaction.gd](../scripts/garden_lily_interaction.gd) now only extends
the shared controller to preserve the Garden scene's existing script reference.
It is not a second dialogue implementation. One-time interaction completion is
stored on the loaded target, not in GameState or a save file. Controller signals
provide scene-local start/finish hooks. Scene 02 now consumes successful finishes
for its three preparation flags; the shared controller itself writes no flags.

The opening cinematic keeps its own sequence/input owner. Future character/NPC
cinematic interactions are a distinct planned responsibility; sharing panel and
typewriter components does not make the environmental controller that system.
See [the environmental interaction guide](overworld_interactions.md) for setup,
repeat rules, bounds, and test examples.

### Target scope and input ownership

Proximity is a distance check from Albert's origin to the target's Node2D origin;
it is not an Area2D or a line-of-sight test. The controller scans grouped targets
under Player's parent. An eligible selection is retained until unavailable;
otherwise the nearest target wins, with node path breaking equal-distance ties.

The body Label still runs its typewriter process, but its independent unhandled
key handler is disabled by the controller. Do not add a second input owner that
also advances this panel. `interaction_started(target)` is emitted when dialogue
opens, before safe placement has necessarily succeeded. Completion listeners
must inspect `interaction_finished(target, completed)`; a placement cancellation
is not a successful interaction. The finish signal follows any camera restoration.

## Session GameState

[scripts/game_state.gd](../scripts/game_state.gd) is a Node registered as the
`GameState` Autoload. The public registration in `project.godot` is
`GameState="*uid://c647p0ta1wljq"`; the identity comes from
[scripts/game_state.gd.uid](../scripts/game_state.gd.uid). Keep that sidecar with
the script.

GameState stores Boolean event flags for one running application and survives
scene changes. `REGISTERED_FLAGS` is the explicit production registry and
contains the published `bedroom_intro_completed` and the accepted local
`bedroom_schedule_checked`, `bedroom_id_checked`, and `bedroom_medal_checked`.
Names and values are strictly validated; reads/writes never
create an event implicitly. Unknown reads return `null`, invalid writes return
`false`, and actual value changes emit `flag_changed`. `reset_session()` clears
registered values; restarting the application creates a fresh session.

The foundation and its first story producer are published.
The introduction writes completion after final reflection; developer context
bypasses that flag. The separate Scene 02 controller writes preparation only after
a matching successful environmental interaction. GameState does not implement
Sanity, dialogue playback, save/load, inventory, or quests. See
[GameState V1](game_state.md) for event registration and the full API contract.

## Sanity service and adaptive HUD

[sanity_state.gd](../scripts/sanity_state.gd) is the separate SanityState Autoload;
its .gd.uid identifies the project registration. It owns one validated integer
score, derived playable stages, failure notification, and explicit session reset.
GameState remains the Boolean-only story registry and has no dependency on it.

[SanityHUD](../scenes/UI/sanity_hud.tscn) uses
[sanity_hud.gd](../scripts/sanity_hud.gd) and Isabela's seven textures in
assets/ui/sanity/. One instance belongs to each laboratory. The story Bedroom
inherits its laboratory's HUD; Dream has none. Dialogue panels join the
dialogue_panels group; visibility/rectangle signals let the HUD follow actual
top/bottom dialogue placement without changing input, text layout, or cameras.

The phone's choice_committed(branch) signal reaches the Bedroom story controller;
a per-conversation guard applies +1 for branch 3 only. Existing completion timing
remains unchanged. The [focused test entry](../scenes/tests/sanity_tests.tscn) uses
[sanity_tests.gd](../scenes/tests/sanity_tests.gd). See
[Sanity design](SANITY_DESIGN.md) for exact APIs, assets, signals, and limitations.
Environment switching, manifestations, full failure presentation, and checkpoints
are not supplied by these files.

## Dialogue, UI, and presentation resources

[dialogue_panel.tscn](../scenes/UI/dialogue_panel.tscn) is a reusable Control with
an `Artwork` TextureRect, `Speaker` Label, and `Margin/Content` containing `Body`
and `Hint` Labels. [dialogue_panel.gd](../scripts/dialogue_panel.gd) selects world
artwork and text styling, preserves the artwork's aspect ratio, and positions
text in its safe areas. The two skins are
[dialogue_dream_world.png](../assets/ui/dialogue/dialogue_dream_world.png) (dark
floral) and [dialogue_real_world.png](../assets/ui/dialogue/dialogue_real_world.png)
(light).

The panel, opening text, and overworld prompt use the committed
[Pixel handwriting_regular.ttf](../assets/fonts/Pixel%20handwriting_regular.ttf).
FontVariation resources adjust spacing for its metrics.
[text_type.gd](../scripts/text_type.gd) handles character reveal and line signals.
The opening owns its sequence advancement; the overworld controller handles
advancement for its panel and disables the body's independent input handler.

[eyelid_effect.tscn](../scenes/UI/eyelid_effect.tscn) combines
[eyelid_effect.gd](../scenes/UI/eyelid_effect.gd) with
[eyelid_effect.gdshader](../scenes/UI/eyelid_effect.gdshader) for the opening's wake-up
animation. [dream_deterioration.gdshader](../scenes/UI/dream_deterioration.gdshader)
supplies the gradual Dream glitch effect. These effects belong to the scripted
opening, not the environmental interaction overlay.

### Cinematic sequence ownership

`OpeningSequence` owns the ordered `STEPS` array and controls the centered Label,
DialoguePanel, Eyelids, GlitchPlaceholder, and AwakeningFade nodes. The typewriter's
`advance_requested` signals reach the sequence controller; its `_ready()` connects
the instanced panel body's `advance_requested` and `character_revealed` signals
only when their intended callables are not already connected. Published repair
`eef63da` therefore works with or without those saved scene connections. The
controller's busy/completed states prevent advancement through a timed effect.
The eyelid's `completed` signal allows the sequence to continue after opening the eyes.

`event_cued`, `audio_cued`, and `character_revealed` expose sequence/audio hooks;
they do not supply sound playback or a scene router. The typewriter converts the
unsupported ellipsis glyph to three periods for display while source dialogue
remains unchanged. Any font/art update needs a check of text safe areas, spacing,
and this compatibility behavior. Font licensing remains unresolved.

## Dependency examples

- **Player visuals:** `scenes/player.tscn` → its AnimatedSprite2D →
  `assets/characters/albert/albert_frames.tres` → `albert_idle.png` and
  `albert_walk.png` in the same asset directory. The attached
  `scripts/albert_animation.gd` selects those animations.
- **Bedroom interaction:** `scenes/environments/bedroom_room.tscn` supplies
  targets using `scripts/overworld_interactable.gd`; the hosting
  `scenes/gameplay/bedroom_playable.tscn` supplies the controller using
  `scripts/overworld_interaction.gd` → `scenes/UI/overworld_overlay.tscn` →
  `scenes/UI/dialogue_panel.tscn` → panel script, typewriter, font, and world skin.
- **Opening presentation:** `scenes/story/dream_story.tscn` → attached
  `scripts/opening_sequence.gd` → scene-local dialogue and eyelid nodes. The
  scene instances the shared panel and eyelid scenes; the controller sequences
  their behavior without using the overworld controller.

### Runtime traces

| Scenario | Verified control flow | Important boundary |
| --- | --- | --- |
| Move/turn Albert | Input Map → `Input.get_vector()` → velocity at speed 150 → `move_and_slide()` → `update_motion(input, displacement)` → idle/walk animation and sprite flip | Collision controls actual displacement; artwork does not change physics |
| Approach the Lily | Controller observes target → radius check → available automatic/re-entry target selected → begin dialogue → select Dream skin → lock Player/idle → present line → start signal → validate framing | The Garden root inherits the shared controller; the opening is not involved |
| Use the notebook | Eligible manual target → prompt → fresh E/Space → typing → reveal/advance → complete | Keypress repeat allows another activation while still nearby |
| Reveal/advance overworld text | Controller reads `body.is_typing` → `reveal_line()`, or increments `line_index` and presents the next line, or closes the last line | The body's own key handler is disabled; layout/entry/held-key guards prevent duplicate actions |
| Frame/restore dialogue | `_position_dialogue()` checks full artwork and subject bounds → chooses a clear edge or feasible pan → verifies actual result within limits → closing restores a shifted camera | Failed framing closes with `completed = false` and restores control; movement returns before any camera-return tween finishes |
| Close/cancel dialogue | Target records success/failure → panel clears/hides → velocity zeroed and previous physics-processing state restored → camera returns if shifted → finish signal | Failed placement does not consume a one-time completion; leave/re-enter before retrying |
| Finish story introduction | Last reflection dismissed → registered completion set true → environmental suspension and prior Player physics restored → `introduction_finished(branch)` | Developer context never reads/writes the completion flag; choice remains local |
| Run F5 | Dream initializes → `STEPS` lines/events → completion signal → deferred story Bedroom load → introduction → exploration | Waking dialogue occurs once in Bedroom; main scene setting remains Dream |

The detailed interaction lifecycle and API remain in the specialized guides;
these traces show where responsibilities meet.

## Extending the project safely

| Task | Where to start |
| --- | --- |
| Add an environmental object interaction | Follow [interaction scene setup](overworld_interactions.md); configure the target's full visual bounds, trigger, and repeat behavior, then test placement and movement restoration |
| Update Albert's animations | Follow [the animation guide](albert_animation.md); preserve original PNGs and review atlas regions, feet alignment, mirrored directions, and dialogue bounds |
| Register an approved story event | Add its name to `REGISTERED_FLAGS` in `scripts/game_state.gd` and follow [GameState V1](game_state.md); connect callers/listeners deliberately |
| Work on an assigned room | Coordinate ownership, edit the relevant room/laboratory pair, and run that laboratory with F6; a camera change in one laboratory does not update the others |
| Add or move an asset/resource | Use the existing asset category, preserve source art/audio, update dependent references, and keep required UID sidecars; allow Godot imports to finish and test affected scenes |

When editing existing environmental text, change the target's `lines` and matching
`speakers` entries, then test wrapping and framing with the selected skin. Missing
speaker entries intentionally display a blank name. An empty lines array makes a
target unavailable. `visual_path` must resolve to the visible object's Node2D;
measure `visual_bounds` in that node's local space, including all animated poses.

When moving scenes/scripts, find all scene resource paths, preloads, inheritance
references, and node paths affected by the move. Preserve resource identities and
check every host of a shared scene. A successful import alone is not proof that
runtime `get_node()` paths or signals remain correct.

### Current configuration versus required behavior

The following values describe the inspected baseline, not permanent prohibitions
against tuning. An approved change may adjust them with coordinated review and
regression checks; changing a number does not waive a behavioral constraint.

| Current configuration | Where it lives | Checks needed when tuning |
| --- | --- | --- |
| Movement speed 150 | `scripts/player_movement.gd` | Both input schemes, normalized diagonals, collisions, animation response, and all hosting scenes |
| Laboratory zoom 2.5×; older sandbox zoom 4×; scene-specific camera position/limits | The respective laboratory or game scene | Framing, edge/corner travel, fixed/follow behavior, and safe dialogue placement |
| Idle 3 fps; walk 8 fps | `assets/characters/albert/albert_frames.tres` | All directions, turn continuity, stopping, and interaction idle behavior |
| Lily radius 84; notebook 92; card 76 | Garden laboratory target; Bedroom room targets | Approach/re-entry behavior, navigation access, and eligible-target selection |
| Typewriter interval 0.1 seconds; framing tween 0.25 seconds | `scripts/text_type.gd`; `scripts/overworld_interaction.gd` | Reveal/advance input ownership, layout busy periods, and movement/camera restoration |

Sprite scale/offset, collision geometry, text spacing, and prototype effect timings
are also current configuration. Changes require the relevant owner review and
tests of their dependents. Original atlas regions follow the supplied sheets;
altering them is an artwork/resource change, not merely an FPS adjustment.

### Extension checks and invariants

- Preserve normalized movement, functional collisions, and input schemes within
  the approved scope; tune numeric values only through an approved, tested change.
  Preserve original artwork unless its alteration is explicitly authorized.
- Mirror the sprite only: collision and camera nodes must not mirror with it.
- Keep the full dialogue artwork clear of Albert and the interaction object.
  Invalid framing must restore control and report unsuccessful completion.
- Test all eight moving and idle directions, reversing, stopping, and pressing
  against a wall when player visuals/controller integration changes.
- Run affected laboratories independently. Check room/furniture collisions,
  fixed/follow camera behavior, limits, and the view near edges/corners.
- For interaction changes, test manual/automatic activation, reveal versus advance,
  held keys, completion/re-entry/one-time rules, and restored movement. Approach
  from several sides and confirm the full panel, Albert, and object remain clear.
- Check the opening separately after modifying the shared panel, font, or
  typewriter. Do not combine cinematic and environmental input ownership without
  an approved integration design.
- Keep GameState independent of Sanity; agree on approved event names and the
  actual consuming contract before wiring new systems together.

These are validation procedures for future changes, not claims of new runtime
tests during documentation preparation. See the [README maintenance rule](../README.md#keeping-the-documentation-accurate)
for which guide should accompany a meaningful accepted change.

Meaningful accepted changes to file locations, behavior ownership, dependencies,
or architecture require updating the affected sections here and relevant links.
Review required UID/resource identities and every affected shared consumer.

## Confirmed unfinished integration

- The opening-to-Bedroom introduction and Dream signal repair are accepted and
  published. Dream backgrounds and final audio remain placeholders/integration hooks.
- Garden and School retain standalone entries. Door transitions between rooms
  are not implemented.
- Environmental descriptions and the Garden conversation are prototype content.
  A general character/NPC cinematic interaction system remains separate planned
  work.
- GameState has one published introduction event and three Scene 02
  preparation events. Sanity mechanics and persistent
  save/load remain outside its current scope.
- The music and sounds directories contain placeholder files, not finished audio
  integrations. Font licensing/redistribution permission still needs verification.

These statements describe the accepted implementation while preserving
the earlier historical snapshot; they do not audit other branches. Use [Game flow](GAME_FLOW.md) for prerequisites
and [Team progress](TEAM_PROGRESS.md) for ownership and review priorities.
