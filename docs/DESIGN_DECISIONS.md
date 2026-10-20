# Design decisions

[README](../README.md) · [Project structure](PROJECT_STRUCTURE.md) ·
[Game flow](GAME_FLOW.md) · [Development history](DEVELOPMENT_HISTORY.md) ·
[Team progress](TEAM_PROGRESS.md)

## How to read this record

This preserves approved constraints supplied by the Project Lead and decisions
visible in the earlier published snapshot at `590184b`. D12 and related updates
describe the completed local introduction: all 156 automated checks passed, and
the Project Lead granted manual acceptance on October 20, 2026. Git publication
is still pending. Implementation evidence is linked to
current files/guides and the verified [milestone history](DEVELOPMENT_HISTORY.md).
A working implementation is not automatically final design approval.

**Accepted** describes agreed direction/constraints; **implemented/published**
describes code status; **provisional** allows tuning; **proposed** is not approved;
**deferred** is outside the current scope; **superseded** records a replaced choice;
**unresolved** requires a decision. These labels can apply together.

Each decision records context, known reasoning, consequences, current evidence,
and when it can be revisited. No unrecorded alternatives or motivations are
invented. Narrative authority and team coordination remain with their assigned
owners.

### Invariants and tunable configuration

Required behavior includes restoring Player control after dialogue, preserving
single input ownership, keeping environmental panels clear of protected subjects, rejecting
unknown event identifiers, and separating story-state storage from Sanity rules.
These constraints must survive ordinary content/configuration changes.

Movement speed, camera zoom/offsets/settings, animation FPS, prototype interaction
radii, typewriter rate, and effect/pan timing are current configuration. They may
be tuned through a coordinated, approved, tested change; their observed numeric
values are not permanent architectural prohibitions. See
[the configuration snapshot](PROJECT_STRUCTURE.md#current-configuration-versus-required-behavior).
Changing configuration does not waive invariants or authorize artwork changes.

## D01 — Working title and psychological-horror direction

**Provenance:** Project Lead-confirmed premise/direction and unresolved narrative
scope; not a finalized story inferred from source.

**Status:** Accepted project direction; narrative details unresolved.

**Decision/context:** Withering Away is a working title for a six-student 2D
psychological horror game for Month of Horror #2: Withering Away. The Project
Lead's current premise follows Albert beginning college. Deterioration, dreams,
and unsettling environments are developing themes, not a finalized plot contract.

**Reasoning and consequences:** This is supplied project context rather than a
decision recoverable from a gameplay diff. It guides tone but does not authorize
developers to invent story, endings, or psychological mechanics. Garden/Lily
symbolism and multiple endings remain proposals described in
[Game flow](GAME_FLOW.md#intended-direction-and-narrative-uncertainty).

**Implementation/revisit:** The opening and prototypes express parts of the
direction. Isabela and the team must approve final narrative/title decisions
before code or documentation treats them as settled canon.

Technical ownership is distinct from narrative authority. Ali implementing a
scene does not finalize its narrative; Christan implementing mechanics does not
finalize their narrative interpretation. Coordinate content decisions with
Isabela and the relevant team members according to their confirmed responsibilities,
without assuming an additional formal approval hierarchy.

## D02 — Engine and native 4:3 presentation

**Provenance:** Project Lead-confirmed engine/display baseline; Git/source evidence
in `5549fad`, `879a926`, and `b010a5e`. Renderer motivation is not established.

**Status:** Accepted current baseline; implemented/published. Release platforms
and final hardware expectations unresolved.

**Decision/context:** Use Godot 4.7.2, GDScript, the project's Forward Plus feature
setting, and a logical 1280 × 960 viewport with `canvas_items` stretch. The project
feature version is 4.7; the exact current patch version is confirmed team context.

**Known rationale:** The native 4:3 integration established a consistent target
for opening UI and Bedroom framing. At 2.5×, the 512 × 384 Bedroom maps to that
viewport. The reason for choosing Forward Plus or the precise engine version is
not fully established in the committed evidence; no performance justification is
claimed here.

**Evidence/consequences:** Migration `5549fad`, opening configuration `879a926`,
Bedroom adaptation `b010a5e`, and [project.godot](../project.godot). The target does
not guarantee a fixed aspect ratio for every resized window. UI/camera changes
must be checked against the real logical viewport and affected room limits.

**Revisit:** Coordinate renderer, viewport, platform, or engine changes with the
Project Lead and scene/UI owners; validate all affected scenes before integration.

## D03 — Prototype cameras belong to their scenes

**Provenance:** Source-verified current cameras, Project Lead-confirmed provisional
prototype direction, and Git-verified evolution from `e68eed9` through `37c9e8e`.

**Status:** Implemented/published; current framing/behavior provisional, not a
final game-wide camera system.

**Decision/context:** Bedroom uses a fixed room camera. Garden and School use
continuous follow with limits. The older game sandbox keeps a built-in dead zone.
See [scene configurations](PROJECT_STRUCTURE.md#playable-scenes-and-room-resources)
for current values and hierarchy.

**Known evolution:** The early stationary sandbox camera allowed off-screen
movement; parenting it under Player fixed following (`e68eed9`). Built-in drag
margins then allowed central movement before following (`6fae21a`). School initially
used those margins (`7da8e39`), but `37c9e8e` disabled them and smoothing. The School
dead-zone choice is **superseded in that scene**, not removed from the older sandbox.
The detailed reason for replacing School's behavior is not established by the diff.

**Consequences/revisit:** Do not infer a camera policy from an old commit subject
or apply one laboratory's camera globally. Environmental dialogue may need safe
temporary framing; its current pan support assumes unrotated cameras without
drag. Review visibility and limits when changing camera behavior or room dimensions.

## D04 — Shared Player, original Albert artwork, separate animation helper

**Provenance:** Project Lead-confirmed original-artwork/behavior constraints;
published `9987b51` and the animation guide verify the implementation.

**Status:** Accepted constraints; implemented/published.

**Decision/context:** Reuse [player.tscn](../scenes/player.tscn) across playable
hosts. Hosts attach [playerMovement.gd](../scripts/playerMovement.gd); the sprite
uses [albert_animation.gd](../scripts/albert_animation.gd). Keep movement/collision
behavior separate from directional visual selection and preserve Isabela's
original artwork.

**Known rationale:** Explicit atlas regions accommodate the actual sheet layout
and the walk sheet's one-pixel vertical difference without redrawing the PNGs.
Five original directions plus sprite-only mirroring provide eight-direction idle
and walk presentation. Keeping facing and animation phase avoids restarting the
step/breath on every turn. These behaviors are documented in
[the animation contract](albert_animation.md) and implemented by `9987b51`.

**Consequences:** Preserve normalized diagonals, WASD/arrows, and functional shared
collisions. Speed 150, animation FPS, and current geometry/offsets are baseline
configuration; approved tuning requires checks of all relevant hosts and dependents.
Turning the sprite must not mirror the collider/camera. Fully blocked motion should
idle while facing the requested direction. Interactions call `show_idle()` during
movement lock.

**Revisit:** New artwork, frame regions, sprite scale/offset, or animation names
require checks in all hosts and in dialogue placement. Movement mechanics and
art replacement need their own approval; they are not incidental cleanup.

## D05 — World-specific supplied dialogue artwork and a shared typewriter

**Provenance:** Project Lead-confirmed world skins, speaker attribution, and draft
sequence constraints; published opening/panel/typewriter evidence in `879a926`.

**Status:** Accepted presentation boundary; implemented/published with provisional
content/timing.

**Decision/context:** Use the existing dark floral Dream World and light Real
World artwork, selected by Albert's world rather than the speaker's identity.
The shared panel preserves the full supplied image and positions text in measured
safe areas. The mysterious Dream speaker remains `???`; Albert's silent reaction
is attributed to Albert. Preserve narrative order instead of rewriting the draft.

**Known rationale/evidence:** The two supplied skins carry the world distinction.
[dialogue_panel.gd](../scripts/dialogue_panel.gd) preserves aspect ratio and uses
world-specific text areas/colors. FontVariations trim oversized font metrics
without changing the font. [text_Type.gd](../scripts/text_Type.gd) displays three
periods for an unsupported ellipsis glyph while leaving source dialogue intact.

**Consequences:** E/Space reveals a line before advancing; held/duplicate input
must not consume multiple actions. Opening and environmental controllers own
their respective progression, while reusing low-level presentation. The white
Dream background, audio cues, and exact effect timing are not final assets.
The local introduction supersedes the waking placeholder's dialogue role: the
three waking lines now use the Reality panel over the actual Bedroom (D12).

**Revisit:** Isabela's approved art/narrative changes and Lawrence's audio contract
may require new safe-area or signal checks. Font permission remains unresolved;
do not assume its inclusion establishes redistribution rights. This concerns
[Pixel handwriting_regular.ttf](../assets/fonts/Pixel%20handwriting_regular.ttf)
and is an asset-provenance uncertainty, not proof of infringement. Verify the
documented license or permission with the actual rights holder before public
build distribution. No license is asserted and no font replacement is authorized
by this record.

## D06 — Environmental-object interactions remain scene-local

**Provenance:** Project Lead-confirmed environmental/cinematic scope boundary;
published extraction in `79247a2` and the current interaction guide/source.

**Status:** Accepted foundation; implemented/published. General character/NPC
cinematic interaction design remains separate planned work.

**Decision/context:** Reusable targets describe nearby environmental objects; one
controller per playable scene handles selection, dialogue, and Player/camera
coordination. The opening retains its own scripted sequence and input ownership.
This avoids treating environmental descriptions as the complete cinematic system.

**Known evolution:** The Garden-specific controller in `0029fed` was replaced by
the shared target/controller/overlay in `79247a2`. Its old script reference is
preserved by a small inheritance adapter, not duplicated controller logic.

**Consequences/constraints:** Christan can add environmental content using
[overworld_interactions.md](overworld_interactions.md). Keep targets inside the
controller's Player-parent scope and retain expected node paths. Reusing a panel
or typewriter does not transfer ownership of Ali's opening or authorize combining
the systems. Avoid a second handler advancing the same panel.

**Revisit:** Agree with the relevant owners on future NPC cinematic input,
movement/camera handoff, and content interfaces before unifying responsibilities.

## D07 — Configurable activation/repeats and controlled movement locking

**Provenance:** Project Lead-confirmed interaction requirements/acceptance;
published target/controller behavior in `79247a2`, retained in current source.

**Status:** Accepted prototype contract; implemented/published.

**Decision/context:** Support manual E/Space activation and automatic proximity
activation, with keypress, re-entry, or one-time repetition per target. One press
must not both activate and skip/advance. Pause movement during environmental
dialogue, then restore the Player's prior physics-processing state.

**Known rationale:** Configurable rules let the reusable system retain the
Garden's automatic re-entry behavior and support Bedroom's manual descriptions.
The typewriter and input guards prevent accidental line consumption. The actual
repeat matrix and examples are authoritative in the interaction guide.

**Consequences:** Completion currently belongs to a loaded target instance;
reloading recreates it. Distance checks do not provide line-of-sight detection.
The controller clears velocity, holds a directional idle, and reports completion
separately from opening. None of these rules currently write GameState events.

**Revisit:** Cross-scene/persistent completion, different Player locking, or a
visibility/raycast requirement needs an approved contract and relevant regression
tests, not an implicit behavior change while adding content.

## D08 — Environmental dialogue must not hide Albert or the interacted object

**Provenance:** Project Lead-confirmed visibility requirement; source/history in
`0029fed`, `79247a2`, and `9987b51` verifies placement and updated Albert bounds.

**Status:** Accepted visibility constraint; implemented/published with explicit
camera/layout limits.

**Decision/context:** Checking only the text or speaker name is insufficient: the
decorative box can cover the object or Player. Placement protects the complete
artwork, configured object envelope, and all Albert idle frames/directions.

**Evidence/reasoning:** The controller evaluates top/bottom positions in screen
space and can make a short feasible pan respecting camera limits. `9987b51`
expanded Player bounds handling for the official directional animations. See
[placement](overworld_interactions.md#placement) for the precise supported setup.

**Consequences:** New objects must supply correct local visual bounds, including
animation. Impossible framing cancels with a warning and restores control rather
than claiming success. `interaction_started` is not a completion guarantee;
listeners must check the finish outcome. New viewport sizes, rotated/drag cameras,
or large art require review.

**Revisit:** Any relaxation of subject visibility, different panel layout, or new
camera support must be explicitly designed and tested with the art/UI owners.

The approved story phone overlay in D12 is a separate presentation: it stays
centered and may cover Albert. This does not relax environmental subject framing.

## D09 — GameState V1 is a strict session event registry

**Provenance:** Project Lead-approved V1 choices; published script, UID, registration,
and contract in `590184b`. Future producer/consumer interfaces remain unapproved.

**Status:** Approved V1 design; foundation published in `590184b`. One story
completion event is implemented locally under D12; persistence remains deferred.

**Context/purpose:** Shared event state needs to survive scene changes without
putting progression storage in a particular room or dialogue controller. Initial
scope is Boolean story/event flags, not a general gameplay manager.

| Approved choice | Implemented consequence |
| --- | --- |
| Central Godot Autoload | `GameState` resolves the script through its preserved UID; callers share the running session |
| Session lifetime | Scene changes preserve flags; restarting the application creates defaults; explicit `reset_session()` resets within the same application |
| Descriptive names in one explicit registry | Approved names live in `REGISTERED_FLAGS`; local introduction registers `bedroom_intro_completed` |
| False defaults; values can change both ways | Flags are Boolean and mutable true/false; permanent milestones are caller conventions |
| Strict types and known identifiers | Actual String names and Boolean values are required; invalid/unknown identifiers warn; unknown reads return null, rejected writes return false |
| No implicit registration | Reading/writing a new name never creates a flag |
| Notifications for actual changes | `flag_changed(name, value)` emits after changes; assigning the same value emits nothing |
| Consistent session reset | All values become false before reset notifications; previously true entries notify in registry order |
| No save/load in V1 | Quitting does not persist state; save behavior needs a separate approved design |
| Sanity stays separate | Christan owns Sanity mechanics; that system may consume agreed flags/signals without moving its rules into GameState |

**Rationale and constraints:** These are approved V1 boundaries supplied by the
Project Lead and verified in [game_state.gd](../scripts/game_state.gd). Explicit
registration/validation makes unknown event use visible rather than silently
creating state. It is not a decision about final event names or narrative outcomes.

**Current integration/revisit:** The local Bedroom introduction sets its approved
completion flag after the final reflection. Additional events still require
approved meanings, producers, consumers, and reset rules. Do not write `_flags`
directly or replace invalid-read null with
an assumed false. Use [game_state.md](game_state.md) for the API/examples, and
agree on any persistence or Sanity contract separately.

GameState exposes approved shared story-event information. Christan's future
Sanity implementation may read registered events or subscribe to suitable change
signals, but GameState must not calculate Sanity, implement psychological effects,
or invent Sanity event identifiers. The actual integration interface remains
unresolved until coordinated and approved; no such consumption is wired on main.

## D10 — Preserve resource identities and shared consumers

**Provenance:** Project Lead-confirmed resource-preservation constraint; current
scene/resource dependencies and GameState UID registration provide implementation evidence.

**Status:** Accepted maintenance constraint; reflected in existing resources.

**Decision/context:** Keep original art/audio intact, retain required UID sidecars,
and inspect dependent scenes/scripts when adding, moving, or changing shared
resources. A scene reference may use a path and UID; an Autoload may use a UID
alone. File existence does not prove that runtime node paths remain correct.

**Evidence/consequences:** GameState's registration uses its `.gd.uid`; the Player
references SpriteFrames and the animation helper; multiple laboratories reference
the shared Player/controller. Texture import metadata refers back to source PNGs.
Detailed file relationships and extension checks are in
[Project structure](PROJECT_STRUCTURE.md).

**Revisit:** Asset organization can evolve with coordinated changes and dependency
validation. Do not change shared identities or remove retained sample resources
merely because one active scene no longer uses them.

## D11 — Ownership and documentation are part of integration

**Provenance:** Project Lead-confirmed team responsibilities and standing human
development/documentation maintenance requirements.

**Status:** Accepted standing team workflow.

**Decision/context:** Coordinate shared edits and respect the confirmed
[responsibilities](TEAM_PROGRESS.md#confirmed-responsibilities). Meaningful
accepted changes include evaluating relevant documentation, keeping it aligned
with source, and reviewing it with the implementation. Publication requires
review/authorization and verification before status becomes published.

**Rationale/consequences:** A returning developer needs recoverable behavior,
dependencies, decisions, and unresolved questions without reconstructing every
conversation. Each topic has one detailed reference. Update only affected guides;
routine debugging/test runs do not need activity-log entries. Source defines
implementation; approved intent and assignments do not prove completion.

**Maintenance:** Follow the [README change-to-document mapping](../README.md#keeping-the-documentation-accurate).
When an important accepted decision changes, retain the previous choice marked
**superseded**, identify the replacement and affected systems, record the known
reason (or state it is unknown), and explain required validation or migration
consequences. Link the new evidence without creating a raw changelog. Do not erase
meaningful context or add speculative implementation status.

## D12 — One story owner for the Dream-to-Bedroom introduction

**Provenance:** Project Lead-approved complete introduction contract and prepared
phone placeholder acceptance. See [Game flow](GAME_FLOW.md#bedroom-introduction)
and [implementation structure](PROJECT_STRUCTURE.md#story-bedroom-and-phone-components).

**Status:** Implemented locally; automated validation passed all 156 checks.
Project Lead manual acceptance was granted on October 20, 2026. Git publication
is pending. Visual tunables remain provisional prototype values.

**Decision/context:** Keep Dream as the main scene, preserve its earlier narrative
and effects, and defer its waking handoff into a story wrapper around the existing
Bedroom laboratory. Move the three waking lines to that actual room, without
replaying them on the old waking placeholder. Albert stands beside the bed in
his existing idle pose. No new awakening animation or room geometry is needed.

One introduction controller owns input and movement through waking dialogue,
brief buzz/shake, `!!!`, phone conversation, one choice, and reflection. It reuses
Reality dialogue presentation and suspends environmental activation separately
from the Player's physics lock. On final dismissal it restores prior state and
requires input release before environmental interaction resumes.

The phone uses all 16 prepared transparent 640 × 1088 PNGs with a common viewport
center and uniform scale, instantaneous swaps, and a dimmer behind the artwork.
It may cover Albert. Visible-width differences and conservative edges are accepted
temporary-art limitations; no further normalization or regenerated artwork is
authorized by this decision. Choice hit regions and outline share its transform.

**State and entry boundaries:** `bedroom_intro_completed` means the entire story
introduction, including final reflection, was dismissed. It is session-only and
is not written at arrival, phone open/close, or selection. The chosen response
changes only the local phone branch and reflection, with no Sanity, relationship,
ending, or save effects. Completed story entry skips the introduction. Room travel
remains separate future work.

The ordinary Bedroom F6 laboratory remains exploration-only and does not write
completion. A dedicated developer test scene instances the same story logic in
an explicit context that neither reads nor writes story completion. It contains
no second copy of the narrative or branches.

**Validation and acceptance:** Automated validation passed, including branch,
input, movement, session, and laboratory checks. Project Lead manual acceptance
was granted on October 20, 2026; Git publication remains pending. Final buzz audio
is pending and uses an explicit integration cue meanwhile. Final chapter flow, saves, and general NPC systems
are not part of this introduction.

## Open decisions and deferred work

| Question | Current status | Coordination required |
| --- | --- | --- |
| Opening → Bedroom publication | Implemented, validated, and accepted locally on October 20, 2026; Git publication pending | Project Lead with relevant scene/content owners |
| First connected chapter boundaries and room order | Unresolved | Project Lead and narrative/environment owners |
| Additional event identifiers and producer/consumer rules | One introduction flag approved; further events require agreement | Project Lead with relevant feature owners |
| Sanity inputs, outputs, and event dependencies | Unverified interface; no current integration | Christan and Project Lead |
| General character/NPC cinematic presentation and input handoff | Separate planned responsibility; contract unresolved | Relevant cinematic/dialogue owners before integration |
| Save storage and cross-launch persistence | Deferred outside V1 | Separate design/authorization |
| Final narrative, Garden symbolism, ending conditions, title | Proposed/unresolved as described in Game flow | Isabela and the team |
| Final audio/background replacements and font permission | Actual deliveries/permission not established by this source audit | Relevant asset owners and Project Lead |

These are open questions, not implementation tasks assigned by this document.
