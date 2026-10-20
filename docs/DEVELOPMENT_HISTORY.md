# Development history

[README](../README.md) · [Current structure](PROJECT_STRUCTURE.md) ·
[Design decisions](DESIGN_DECISIONS.md) · [Team progress](TEAM_PROGRESS.md)

## Evidence and scope

This reconstructs meaningful changes reachable from published main at
`590184baf43a43410e7f6288258d1ef080d17967`. Commit identities, parents, changed files,
and relevant diffs were inspected. The order below follows ancestry, not guessed
milestone dates. A merge's side-branch commits are identified explicitly.

Git establishes what was saved and integrated. It does not establish every design
discussion, runtime test, or original contribution's author. Team responsibilities
come from the Project Lead's confirmed assignments, not guesses from filenames or
commit authors. Where motivations are not recoverable, the record describes the
effect of the change rather than inventing a rationale.

### Evidence categories

| Category | What it can establish |
| --- | --- |
| Git-verified | Commit identity/parents, changed files, merge structure, and implementation included in the inspected main history |
| Project Lead-confirmed | Design/acceptance decisions and reported manual or isolated validation supplied by the Project Lead; not independently recoverable from a diff |
| Unverified or unavailable | Details not established by Git or reliable confirmed project records; omit them or state the limitation |

The historical acceptance subsection below uses the second category explicitly.
Neither a commit nor a reported historical test is a fresh runtime result from
this documentation refinement.

## Published milestone map

| Order | Verified commit | Significant change |
| --- | --- | --- |
| 1 | [f22a1b1](https://github.com/AzureZephyry/withering-away-jam/commit/f22a1b12e3fb7a17392314de2f4260daca593849) | Initial Godot project, sample sprites, Player scene, movement controller, and game sandbox |
| 2 | [5549fad](https://github.com/AzureZephyry/withering-away-jam/commit/5549fad53ecd4ff842fa96714673427bf1e3dd48) | Project migration from the 4.3 feature setting to 4.7, updated imports and script UIDs |
| 3 | [e68eed9](https://github.com/AzureZephyry/withering-away-jam/commit/e68eed9633d1da89ab58f50f83c9abe180ee6632) | Sandbox Camera2D parented under Player to follow movement |
| 4 | [6fae21a](https://github.com/AzureZephyry/withering-away-jam/commit/6fae21a9de71a8368e4b909788b71f7bd8e29b81) | Six built-in dead-zone camera properties added to the sandbox |
| 5 | [a76a470](https://github.com/AzureZephyry/withering-away-jam/commit/a76a470e3f87409ca81b34beb8682c160d99e277) | Bedroom fixed-camera laboratory, room scene, and pixel drawing helpers |
| 6 | [7da8e39](https://github.com/AzureZephyry/withering-away-jam/commit/7da8e395220149ebf41035d087bac386bdb75e7e) | School room and laboratory, initially using dead-zone follow with limits |
| 7 | [37c9e8e](https://github.com/AzureZephyry/withering-away-jam/commit/37c9e8e665efc7838e273f7be99cc6cccbb7a9cc) | Bedroom/School environment refinements, WASD Input Map bindings, School continuous-follow camera |
| 8 | [dc37958](https://github.com/AzureZephyry/withering-away-jam/commit/dc3795833d080e6e3b86209e7461e907d3acc828) | Dream Garden laboratory/room and ground, prop, and overhang drawing/fading helpers |
| 9a | [879a926](https://github.com/AzureZephyry/withering-away-jam/commit/879a9266e24644dcfa44dfa72e3cb1f81a829c90) | Opening, shared dialogue presentation, effects, main-scene/display/input configuration; integration side branch |
| 9b | [b010a5e](https://github.com/AzureZephyry/withering-away-jam/commit/b010a5e3f719c8489fa4a571a67b0bade2396929) | Bedroom expansion and camera adaptation for native 4:3; child of 879a926 |
| 10 | [fb11575](https://github.com/AzureZephyry/withering-away-jam/commit/fb115750abe34159862a801bfe3aad0c15d9f238) | Merge of the two opening/Bedroom integration commits into main |
| 11 | [0029fed](https://github.com/AzureZephyry/withering-away-jam/commit/0029fed90f593ec914bcaf873ab6622661d2ea56) | Garden-specific Corpse Lily interaction prototype and visual idle animation |
| 12 | [79247a2](https://github.com/AzureZephyry/withering-away-jam/commit/79247a2640a16fa2256add1795432944cfb57166) | Reusable environmental interactions, overlay, and refined Bedroom objects/interactions |
| 13 | [9987b51](https://github.com/AzureZephyry/withering-away-jam/commit/9987b51c66d5084832ca8fd949c9a6d8b74b3292) | Official Albert sheets/frames, directional animation helper, shared Player/controller integration, placeholder cleanup |
| 14 | [590184b](https://github.com/AzureZephyry/withering-away-jam/commit/590184baf43a43410e7f6288258d1ef080d17967) | Session GameState script, UID, public Autoload registration, and technical guide |

The small intermediate `5daf819` commit added placeholder files under fonts,
music, and sounds; it did not establish finished audio/font integration. It is
not expanded into a separate gameplay milestone.

## Foundation and engine migration

The initial project ran [scenes/game.tscn](../scenes/game.tscn). It already had an
active CharacterBody2D movement controller at speed 150 using `Input.get_vector()`
and `move_and_slide()`. Visual animation used retained sample artwork. An unrelated
root platformer-style script also existed; it was not the active top-down controller.

The migration commit changed the project feature version from 4.3 to 4.7 and
included updated import metadata, script UIDs, and a compatibility setting. It
did not introduce a new movement system. The team's current exact engine version,
4.7.2, is confirmed project context; the project feature setting records 4.7,
not a patch-version history. The detailed reason for choosing this engine version
is not established by the migration diff.

## Camera experiments became independent room prototypes

The early sandbox's camera originally stayed at the scene root. `e68eed9` moved
it under Player, retaining 4× zoom and a local `(1, -18)` position. This addressed
the confirmed off-screen movement limitation. `6fae21a` then enabled horizontal and
vertical drag with four 0.35 margins, using built-in Camera2D functionality.

The Bedroom milestone introduced a separate room resource and fixed-camera
laboratory, keeping the existing Player/controller. School followed as a larger
independent room with a bounded dead-zone camera. These were scene prototypes,
not chapter travel or a final camera framework.

`37c9e8e` refined those environments, added physical WASD keys alongside arrows,
and explicitly disabled School drag and smoothing for continuous follow at 2.5×.
The exact rationale for that School camera replacement is not preserved in the
diff. Its supersession is clear: the old commit's “dead-zone” subject does not
describe School's current camera. The older sandbox still retains its dead zone.

## Garden environment before interaction

`dc37958` added [garden_camera_lab.tscn](../scenes/prototypes/garden_camera_lab.tscn),
its room, and native drawing helpers. It introduced a separate Garden exploration
setup with a follow camera and overhead foliage/roof fading to retain Player
visibility. It did not yet add the Corpse Lily dialogue controller.

The Garden's presence as a room resource did not make it the opening's background
or establish narrative travel. That distinction still matters in
[current game flow](GAME_FLOW.md).

## Opening presentation and native 4:3 Bedroom integration

`879a926` added 22 opening-related files/changes, including the font, Isabela's
Dream/Real dialogue artwork, reusable panel/typewriter, eyelid and deterioration
effects, and sequence script. It changed the startup scene to Dream, configured
1280 × 960 with `canvas_items` stretch, and added E/Space `dialogue_advance` bindings.

This delivered a provisional Scene 1 presentation: black text, opening eyes,
white Dream placeholder, glitch cues, and a waking-room placeholder. The saved
implementation ended with `sequence_finished`; it did not connect that signal to
a playable Bedroom. The integration milestone's name must not be interpreted as
proof that story-to-overworld travel was completed.

`b010a5e` modified only the Bedroom laboratory and room. It expanded the earlier
384 × 216 room to 512 × 384, repositioned scenery/collision/spawn markers, added a
door stop, and set a centered fixed 2.5× camera with room limits. At that zoom,
512 × 384 maps to the configured 1280 × 960 view. The result was a standalone
Bedroom matching the target aspect ratio, not a new startup scene.

`fb11575` is a two-parent merge: its first parent is `dc37958`, its second is
`b010a5e`, whose parent is `879a926`. The merge preserved both approved commits;
its tree matches `b010a5e`. The combined first-parent diff contains 24 changed
files. This is the verified publication route, rather than an assumed squash.

## Garden-specific interaction, then reusable environmental behavior

`0029fed` added a Garden-specific controller, its UID, and laboratory changes. Its
published form already used automatic proximity entry/re-entry, three temporary
lines, Dream artwork, typewriter reveal/advance, movement locking, subject-aware
panel placement/temporary camera pan, and a small visual Lily bob. Although early
design requests considered E/Space initiation, this committed prototype did not
use a manual activation prompt. Git records the final published state, not each
intermediate experiment.

`79247a2` extracted reusable object configuration and a scene-local controller,
introduced the shared overworld overlay, and reduced
[garden_lily_interaction.gd](../scripts/garden_lily_interaction.gd) to an adapter.
Garden settings moved onto an interactable target. The Bedroom gained a refined
native-drawn layout and notebook/card examples with distinct repeat rules.

The extraction made environmental authoring reusable while retaining the
opening's separate cinematic sequence. The evolution was Garden-specific code →
shared target/controller/overlay → consistent object authoring across rooms. This
made it possible to configure new environmental content through the established
contract instead of duplicating controller logic, supporting teammate content
integration and maintenance. It did not create a general NPC cinematic
framework, cross-scene interaction persistence, or GameState integration. Detailed
current setup and placement constraints live in
[overworld_interactions.md](overworld_interactions.md).

## Official Albert artwork and directional animation

`9987b51` introduced Isabela's official idle/walk sheets, explicit SpriteFrames,
and [albert_animation.gd](../scripts/albert_animation.gd). The active movement
controller retained its motion/collision calculations and began passing input and
actual displacement to the animation helper. Five drawn directions and mirrored
left-facing directions supply eight-direction idle/walk presentation.

Sample artwork supported the early prototypes; Albert's active production
character artwork now uses Isabela's original directional sheets. The shared
Player replaced embedded sample frames. The two old 2× Farmer PNG
paths and unused root controller/UID were removed; texture import entries moved
to the official assets. The rest of the sample library remained. This was a
targeted character integration, not a project-wide asset removal.

The overworld controller changed from hardcoded sample `Idle` playback/bounds to
Albert's `show_idle()` and the union of all directional idle frames. This preserved
dialogue visibility when facing or breathing changed. Explicit atlas regions and
the one-pixel walk-sheet offset preserve source artwork/alignment; see
[the animation guide](albert_animation.md) for the exact resource contract.

## Session-based GameState V1

`590184b` added the script, UID, guide, and public Autoload registration: four files
in total. V1 supplies an explicit approved-event registry, strict Boolean/name
validation, change notifications, and session reset. It survives scene changes
but has no persistent save storage.

The approved V1 choice centralized shared event information rather than storing
progression only on a loaded room. Its Autoload lifetime supports later cross-scene
consumers while keeping the initial scope to session flags. This is the approved
design purpose, not a claim that production scenes already consume those flags.

The empty production registry is deliberate. No real story identifiers or
opening/environmental callers were added. Sanity remains a separate responsibility;
the state foundation is not evidence of completed Sanity or story progression.
The current public contract is in [game_state.md](game_state.md).

## Project Lead-confirmed historical acceptance

The Project Lead supplied these acceptance records for continuity. They are
reported historical evidence, not inferred from Git or independently rerun in
this documentation checkpoint:

- The Corpse Lily prototype received manual acceptance after focused interaction
  and camera validation. No exact Lily regression-assertion count is asserted here.
- The reusable environmental interaction foundation was accepted before publication.
- Albert's official sprites and eight-direction animations were manually approved.
- GameState V1 was manually inspected and its isolated validation was repeated.

Reported GameState results:

| Historical validation | Passed checks | Failures | Expected validation warnings |
| --- | --- | --- | --- |
| Isolated suite | 76 | 0 | 42 |
| Fresh-process validation | 4 | 0 | 0 |

The Project Lead also reported that the GameState Autoload was present/enabled,
visible at runtime, with no related runtime errors, and that Corpse Lily
interaction remained functional. These reports do not establish an implemented
story progression or Sanity system. The underlying historical test artifacts were
not independently inspected or recreated in this documentation refinement.

## Historical gaps and future maintenance

- Detailed motivations not represented by source, guides, or confirmed project
  decisions remain unknown; this includes final camera design and platform choice.
- No comprehensive test-run archive is established by these commits. This record
  does not recreate historical pass counts, graphics incidents, or visual approval
  evidence from a diff alone.
- Narrative proposals and role assignments are context, not proof of implemented
  endings, transitions, Sanity mechanics, or finished audio.
- Work outside the inspected main history is not claimed as published here.
- This documentation records the implementation and history verified at
  `590184b`; it does not represent a new gameplay milestone.

Add a history entry when an accepted, published change materially helps future
developers understand the project. Preserve superseded decisions with evidence,
link to the current detailed guide, and use Git as the commit record. Do not turn
this into a log of routine edits, tests, or branch housekeeping.
