# Game flow

[README](../README.md) · [Project structure](PROJECT_STRUCTURE.md) ·
[Team progress](TEAM_PROGRESS.md) · [Design decisions](DESIGN_DECISIONS.md)

## Scope and evidence

This describes published runtime behavior at `590184b`, verified from
[project.godot](../project.godot), scenes, and their scripts. The narrative premise
and proposed concepts below are supplied by the Project Lead; they are not all
represented by gameplay code. No new runtime tests were performed for this
documentation inspection.

**Published** means present in the inspected main history. **Prototype** means an
implemented experiment, not a complete chapter. **Planned** describes intended
integration; **proposed/unresolved** describes choices that still need agreement.
For milestone evidence, see [Development history](DEVELOPMENT_HISTORY.md).

## F5: the actual application flow

The configured main scene is [scenes/Dream.tscn](../scenes/Dream.tscn).
`GameState` is available as an Autoload, with an empty event registry. The scene's
`OpeningSequence` Control runs [opening_sequence.gd](../scripts/opening_sequence.gd).
There is no movable overworld Player in this scene.

### Execution overview

```text
F5: Dream.tscn (one scene throughout)
    black text -> eyes opening -> Dream dialogue/effects
    -> waking placeholder -> opening controller completes
    -> no playable-room transition

F6: choose one independent test entry point
    Bedroom laboratory: camera_lab.tscn
    Garden laboratory:  garden_camera_lab.tscn
    School laboratory:  school_camera_lab.tscn
    These are separate runs, not connected room transitions.
```

At startup, centered text and the dialogue panel are cleared, the black backdrop
is visible, the white Dream placeholder is present behind it, and the waking-room
placeholder is hidden. After the default two-second delay, the first line begins
typing. A black initial view is expected behavior, not evidence of a failed room load.

### Opening sequence order

The `STEPS` array is the authoritative line/event order. This table summarizes it
without rewriting the draft dialogue.

| Stage | Implemented behavior | Input and presentation |
| --- | --- | --- |
| Initial black | Two mysterious opening lines appear as centered typewriter text | E/Space reveals typing, then requests the next step |
| `eyes_open` | The closed eyelid overlay starts before the black backdrop is removed; a hesitant opening/blink reveals white | The sequence waits for the eyelid's `completed` signal |
| Albert's reaction | The standalone `...` line is shown with speaker Albert | Dream World panel; the reaction is attributed to Albert |
| Mysterious speaker dialogue | Following lines use `???`, preserving the hidden identity in the presentation | Same Dream skin; speaker identity does not select the world skin |
| `screen_glitches` | First individual glitch, immediately after “Top of everything” | Timed effect before “always ahead of everyone around you.” |
| `glitch` | Second individual glitch, immediately after “always ahead of everyone around you.” | Timed effect before “Don't think I didn't see all of it.” |
| `garden_slowly_glitches` | Gradual deterioration begins after “As long as you stay like this.” | Its onset is awaited; its tail continues behind “I will love you…” |
| `wake_0630` | Fade to black; stop the deterioration tween, hide glitch visuals, swap backgrounds/skin under black, and fade into the waking placeholder | Clock reads 6:30 AM; the next three lines are Albert's waking reaction in the Real World panel |
| `complete` | Set the opening controller's local `is_complete = true` and emit `sequence_finished` | No subsequent scene is loaded and no production GameState event is written; the placeholder remains the current scene |

The individual glitches are single smooth pulses. Their duration/intensity and
the deterioration/fade timing are provisional settings, not finalized direction.
The white view is a Dream artwork placeholder; it is not
[garden_room.tscn](../scenes/prototypes/rooms/garden_room.tscn). Likewise the waking
placeholder is not the playable Bedroom.

This completion state belongs only to `OpeningSequence`. It is not a shared
GameState flag or a record that a production story event has occurred.

### Dialogue input and audio hooks

[text_Type.gd](../scripts/text_Type.gd) owns reveal/advance input for active opening
Labels. A fresh E/Space press reveals the current line if typing; a later press
emits `advance_requested`. The sequence advances only while not busy or complete.
Held-key echoes and duplicate presses are guarded. Timed transitions are not an
input-controlled scene skip.

The opening exposes `event_cued`, `audio_cued`, and `character_revealed` signals.
Music start/stop, individual/gradual glitches, the waking transition, and the alarm
have named cues, but there are no finished music/sound assets or playback nodes
connected here. Revealing a whole line does not emit a burst of per-character
typing sounds. Lawrence's future integration must use the agreed audio contract;
a signal alone is not audible playback.

## F6: standalone exploration prototypes

These are alternative test entry points, not destinations reached from F5. Open
the laboratory, not just its room resource, and press F6. Each laboratory supplies
the shared Albert Player and a camera; room resources supply scenery/collisions.

| Scene | Available experience | Current limits |
| --- | --- | --- |
| [camera_lab.tscn](../scenes/prototypes/camera_lab.tscn) | Walk through the Bedroom, collide with solid furniture/walls, inspect notebook/card; fixed room camera | Right door is closed; no transition or full waking gameplay sequence |
| [garden_camera_lab.tscn](../scenes/prototypes/garden_camera_lab.tscn) | Explore the Garden with limited continuous camera follow, overhead fading, and automatic Corpse Lily dialogue | Conversation is temporary test content; no story-state effect or exit transition |
| [school_camera_lab.tscn](../scenes/prototypes/school_camera_lab.tscn) | Explore the School with collisions and limited continuous camera follow | No environmental dialogue controller or complete School narrative progression attached |
| [game.tscn](../scenes/game.tscn) | Earlier movement/camera sandbox with 4× dead-zone camera | Not the configured main scene or a connected chapter |

Move with WASD/arrows. The active controller preserves speed 150 and normalized
diagonals; the shared animation helper handles directional walking/idle visuals.
See [Player architecture](PROJECT_STRUCTURE.md#shared-player-and-albert-animations)
for the file connections.

## Environmental interaction lifecycle

This is the runtime flow of the shared environmental system. Its full authoring
contract and trigger/repeat matrix are in
[overworld_interactions.md](overworld_interactions.md).

1. **Explore and observe.** Each physics update observes targets in the controller's
   Player-parent scope. Distance to the target origin determines range. Empty
   dialogue or an exhausted repeat rule makes a target unavailable. This does not
   test line of sight through scenery.
2. **Select and activate.** A valid selection is retained; otherwise the nearest
   eligible target is chosen, with node path breaking a tie. Manual targets show
   an E/Space prompt when it can be placed clearly. Automatic targets begin when
   eligible without a keypress.
3. **Lock and present.** Beginning marks the target active, selects its Dream/Real
   skin, stores Player's prior physics-processing state, disables movement,
   clears velocity, and calls `show_idle()`. The first line starts typing.
4. **Find safe framing.** The controller checks the full panel artwork against
   Albert's idle bounds and the object's configured visual bounds. It tries
   top/bottom positions and, if needed, a feasible short camera pan within limits.
   Input waits while placement is busy. If framing fails, the panel closes with
   a warning and control is restored.
5. **Read.** Fresh E/Space reveals a typing line, advances a revealed line, or
   closes the final line. The controller owns this input, disabling the body's
   independent key handler to avoid double advancement.
6. **Complete and restore.** Successful completion updates the target's local
   repeat state. The panel clears/hides, velocity is cleared, and Player's prior
   physics state returns. A shifted camera returns before another interaction
   can begin. `interaction_finished(target, completed)` then reports the outcome.

`interaction_started` is emitted before placement is guaranteed. Consumers must
not infer success from that signal alone. Impossible placement does not consume
successful one-time completion; leave the radius and return before retrying.
The controller currently writes no GameState flags.

### Current repetition examples

| Object | Activation and presentation | After successful completion |
| --- | --- | --- |
| Bedroom desk notebook | Manual, radius 92, Real World panel | Keypress repeat: E/Space can start it again while Albert stays nearby |
| Bedroom dresser card | Manual, radius 76, Real World panel | One-time: unavailable for that loaded instance, including after leaving/re-entering |
| Garden Corpse Lily | Automatic, radius 84, Dream World panel | Re-entry: staying nearby does not reopen it; leave and return to repeat |

These lines are development descriptions/conversation, not finalized story.
Restarting/reloading the scene recreates these target-local completion states.
There is no persistent or cross-scene completion record for them yet.

GameState does not automatically record object examination. Future story-linked
interactions must explicitly register and write approved events; target-local
one-time behavior does not provide that integration.

## Runtime state lifetime

`GameState` is an Autoload across scene changes within one application. Its explicit
registry is currently empty, and no opening/interaction caller sets story flags.
It cannot yet determine which narrative stage Albert has reached.

Approved registered flags default to false; valid writes can set them either way.
`reset_session()` returns them to false. A new application starts a new session.
Changing scenes does not call reset automatically, and target-local one-time
completion is separate from Autoload state. Save/load and Sanity are not part of
this system. See [GameState V1](game_state.md) before introducing event callers.

## Transition inventory

| Connection | Status at the inspected baseline | Owner or required decision |
| --- | --- | --- |
| Black → eyes opening → Dream dialogue → waking placeholder | Published, inside the same opening scene | Opening sequence/controller |
| Opening completion → playable Bedroom | **PLANNED; not implemented** | Ali's assigned integration, coordinated with the Project Lead |
| Potential connections among existing room prototypes | **Undesigned or unimplemented; chapter travel order is not approved** | Agree on narrative order, entry/exit rules, and scene ownership first |
| Room marker/door → destination | No scene router or travel behavior established | A marker or door visual is not a transition |
| F6 → selected laboratory | Published editor test entry point | Developer chooses the standalone scene |
| Registered event → Sanity response | Planned extension boundary, no current wiring | Approved event IDs and Christan's actual Sanity interface |
| Session → persistent save | Deferred | Separate save/load design and authorization |

## Intended direction and narrative uncertainty

**Project Lead context:** Albert begins his first day of college. Psychological
deterioration, unsettling environments, and dreams are the developing narrative
direction. Ali is assigned Scene 1 and integration toward playable Bedroom
gameplay. This supports planning an opening-to-room handoff; it does not establish
the full chapter's route or final dialogue.

**Previously proposed, not settled canon or implemented mechanics:** Albert
initially appearing relatively stable; progressive deterioration reflected by
dreams; a Garden representing his internal state; a Corpse Lily associated with
intrusive criticism, self-blame, and corruption; links between dream experience
and waking presentation; and multiple endings. The current Garden prototype and
opening are not proof that these concepts have been implemented as a dynamic
psychological system. Isabela and the team retain narrative decisions.

## Integration prerequisites

### Unresolved opening-to-Bedroom contract

These questions are not settled by the existing laboratory defaults. Coordinate
with the relevant owners; this table does not approve a destination or handoff.

| Requirement | What still needs agreement |
| --- | --- |
| Final opening endpoint | Which accepted Scene 1 moment hands off, and whether the current placeholder ending remains; coordinate narrative with Isabela and scene behavior with Ali |
| Destination playable scene | Which approved playable Bedroom scene should load; a room resource alone lacks the laboratory's Player/controller/camera setup |
| Spawn | Approved position/facing and how entry data is supplied; the current F6 spawn is not automatically the story-entry contract |
| Player control handoff | When input/movement locks end, when the destination becomes controllable, and how an advance press is prevented from acting twice |
| Camera ownership | Which scene/controller owns the post-handoff camera and how its initial framing is established |
| Dialogue cleanup | Who clears/hides the opening text, panels, effects, and input handlers before exploration |
| Scene transition ownership | Who consumes `sequence_finished`, loads/replaces the scene, and handles the lifetime of the old scene |
| GameState events | Whether the handoff needs shared events; if so, approve names, meanings, producers, and reset rules before registration/writes |

The [proposed milestone evidence](TEAM_PROGRESS.md#proposed-next-integration-milestone)
describes how a future implementation could be reviewed. No such handoff has been
verified on the current published baseline.

### Connected-chapter dependencies

- Agree on the accepted Scene 1 script, its endpoint, and the playable Bedroom's
  entry state/spawn. Wire a deliberate handoff from opening completion; do not
  silently replace the current main scene or assume the placeholder is a room.
- Agree on room entry/exit behavior and chapter order before implementing travel.
  Preserve standalone laboratory testing while integrating scenes.
- Approve descriptive production event names and their meanings before adding
  GameState callers; define who sets/resets each event and who consumes it.
- Coordinate Christan's environmental content with the published interaction
  contract, and define cinematic NPC/Sanity interfaces before connecting them.
- Integrate approved background artwork and Lawrence's actual audio resources;
  maintain Dream/Real world styling and correct reveal/advance behavior.
- Test the connected path repeatedly, including restored controls/camera after
  dialogue, collisions, event lifetime, and transitions. Standalone success alone
  does not establish a complete chapter.

These are integration dependencies, not authorization to implement them now.

## Flow validation guidance

The current paths below can be tested now. These are procedures/expected behavior
from the published source, not newly executed test results.

| Current testable path | Focus |
| --- | --- |
| F5 Dream opening | Startup delay, reveal versus advance, cue order, waking placeholder, local completion without a room load |
| F6 room laboratories | Eight-direction movement/animations, wall/furniture collisions, camera framing and limits |
| Bedroom objects | Notebook keypress repeats; card stays completed for that loaded instance and resets on reload |
| Garden Lily | Automatic approach, no immediate reopening while nearby, and repetition after leaving/re-entering |
| Dialogue close/cancellation | Restored movement/idle behavior, a shifted camera returning, finish outcome, and no double input action |

**Future acceptance requirements, not passed checks:** opening-to-playable-room
transition, approved story-event progression, Sanity integration, and chapter
transitions require implementations/contracts that are not present here. Test the
complete connected path once those are approved and implemented; laboratory
success cannot stand in for that evidence.

## Unresolved flow questions

1. What is the final Scene 1 ending and exact opening-to-Bedroom handoff contract?
2. Which rooms and events form the first connected chapter, in what order?
3. Which descriptions repeat locally, and which approved events must persist
   across room changes? Should any be restored after quitting?
4. What are the approved narrative event IDs and Sanity inputs/outputs?
5. What owns future character/NPC cinematic input, Player locking, and camera use?
6. Which narrative proposals, ending conditions, art, and audio cues are finalized?

Record approved answers in [Design decisions](DESIGN_DECISIONS.md), then update
this flow only when the corresponding intent or implementation is confirmed.
