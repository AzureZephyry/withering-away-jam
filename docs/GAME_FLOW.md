# Game flow

[README](../README.md) · [Project structure](PROJECT_STRUCTURE.md) ·
[Team progress](TEAM_PROGRESS.md) · [Design decisions](DESIGN_DECISIONS.md)

## Scope and evidence

This guide describes the local Dream-to-Bedroom integration and existing room
prototypes. The introduction is **implemented and accepted locally**: all 156
automated checks passed, and the Project Lead granted manual acceptance on
October 20, 2026. Git publication is still pending. The previous published runtime snapshot was
`590184b`; its record remains in [Development history](DEVELOPMENT_HISTORY.md).

**Published** means present in the inspected main history. **Prototype** means an
implemented experiment, not a complete chapter. **Planned** describes intended
integration; **proposed/unresolved** describes choices that still need agreement.
For milestone evidence, see [Development history](DEVELOPMENT_HISTORY.md).

## F5: the actual application flow

The configured main scene is [scenes/Dream.tscn](../scenes/Dream.tscn).
`GameState` is available as an Autoload. The scene's
`OpeningSequence` Control runs [opening_sequence.gd](../scripts/opening_sequence.gd).
There is no movable overworld Player in this scene.

### Execution overview

```text
F5: Dream.tscn
    black text -> eyes opening -> Dream dialogue/effects
    -> waking fade to black -> playable Bedroom
    -> waking lines -> buzz/shake -> !!! -> phone -> choice -> selected branch
    -> reflection -> exploration

F6: choose one independent test entry point
    Bedroom laboratory: camera_lab.tscn
    Garden laboratory:  garden_camera_lab.tscn
    School laboratory:  school_camera_lab.tscn
    These are separate runs, not connected room transitions.

Developer F6 entry: tests/bedroom_intro_test.tscn
    Actual Bedroom introduction -> reflection -> exploration
    No story-completion reads or writes; rerun to test another branch.
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
| `wake_0630` | Fade to black, stop deterioration, hide glitch visuals, emit waking/alarm cues, and briefly hold black | Bedroom owns the following reveal, 6:30 AM clock, and waking dialogue |
| `complete` | Set local `is_complete`, emit `sequence_finished`, and defer scene replacement until the callback unwinds | Load the story Bedroom; Dream does not set introduction completion |

The individual glitches are single smooth pulses. Their duration/intensity and
the deterioration/fade timing are provisional settings, not finalized direction.
The white view is a Dream artwork placeholder; it is not
[garden_room.tscn](../scenes/prototypes/rooms/garden_room.tscn). The old waking
placeholder is no longer used for Albert's three waking lines.

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

## Bedroom introduction

[bedroom_story.tscn](../scenes/story/bedroom_story.tscn) instances the existing
laboratory. Its [bedroom_intro.gd](../scripts/bedroom_intro.gd) controller owns
story progression, movement locking, and environmental suspension until the
last reflection is dismissed. Albert stands beside the bed in his existing
idle pose; the room, sprite, and collisions are reused.

| Stage | Behavior |
| --- | --- |
| Arrival | Reveal Bedroom under a short fade with the 6:30 AM context |
| Waking | Silver Reality panel: `What…the….`, `*sigh* what was that weird dream...`, `It felt… more vivid than usual..?` |
| Buzz | Brief visual camera shake restores its original offset; `audio_cued("phone_buzz")` exposes the pending audio integration point |
| Reaction | Albert's `!!!` uses the same silver panel; dismissal opens Screen 01 |
| Phone | Prepared transparent PNGs appear instantly, centered above a subtle background dimmer |
| Decision | Screen 04 selects one local branch |
| Reflection | Phone/dimmer close; Albert's branch-specific Reality lines appear |
| Finish | Final dismissal records story completion, then restores movement and interactions without moving Albert |

E, Space, or left click reveal/advance Bedroom dialogue. A typing line reveals
first; a distinct press advances. One event visits one stage only. Opening the
phone cannot advance Screen 01; choice confirmation cannot advance its first
branch screen; closing the phone cannot dismiss the reflection.

### Phone screens and choices

Ordinary screens accept E, Space, or left click anywhere in the viewport. There
are no timers or backwards navigation. Common screens run **01 → 02 → 03 → 04**.

Screen 04 starts with response 1 highlighted. W/S or Up/Down changes selection;
Enter/Space confirms. Hover highlights a response, and clicking it confirms.
E and clicks outside responses do not confirm. The outline and mouse regions
share the prepared-image transform.

| Response meaning | Phone screens | Albert's reflection |
| --- | --- | --- |
| `Thank you.` | 05 → 06 → 07 | `Okay, big day.` |
| `Don't worry, I got this.` | 08 → 09 → 10 → 11 | `I got this.`, then a separate `...` |
| `I'm a little nervous, ma.` | 12 → 13 → 14 → 15 → 16 | `...It's fine, it's just the first day.` |

The final branch PNG waits for one additional advance input before closing.
Placeholder image wording does not change this semantic mapping. The choice
affects only this branch and reflection: no lasting flags, Sanity, relationships,
endings, or save data change.

All 16 canvases come from `assets/ui/phone/prepared/`, at 640 × 1088. One viewport
center and uniform scale are used across screens. At 1280 × 960, the default 0.75
scale displays 480 × 816; smaller viewports reduce the common scale to fit with
16-pixel margins. Filtering is nearest. Accepted visible-width differences remain.

## F6: standalone exploration prototypes

These remain independent exploration test entries. The story wrapper reuses
Bedroom's laboratory, but running the laboratory itself does not start the story. Open
the laboratory, not just its room resource, and press F6. Each laboratory supplies
the shared Albert Player and a camera; room resources supply scenery/collisions.

| Scene | Available experience | Current limits |
| --- | --- | --- |
| [camera_lab.tscn](../scenes/prototypes/camera_lab.tscn) | Walk through the Bedroom, collide with solid furniture/walls, inspect notebook/card; fixed room camera | Right door closed; direct entry skips the introduction and never writes its flag |
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

`GameState` survives scene changes. Its `bedroom_intro_completed` flag defaults to
false and becomes true only after the last story reflection is dismissed. Loading
Bedroom, opening/closing the phone, or choosing a branch does not complete it.

The story controller has `STORY`, `REENTRY`, and `DEVELOPER_TEST` contexts. Future
transitions can call `configure_entry(context, entry_position)` before adding the
instance to the tree, supplying a room-local entrance position. A completed
story entry skips the introduction and explores from that entrance; an incomplete
story entry runs it. Actual connected room travel is not implemented.

Ordinary Bedroom F6 does not read/write story completion. The dedicated test
context bypasses the flag without resetting it and runs the same introduction.

Approved registered flags default to false; valid writes can set them either way.
`reset_session()` returns them to false. A new application starts a new session.
Changing scenes does not call reset automatically, and target-local one-time
completion is separate from Autoload state. Save/load and Sanity are not part of
this system. See [GameState V1](game_state.md) before introducing event callers.

## Transition inventory

| Connection | Current status | Owner or required decision |
| --- | --- | --- |
| Black → eyes opening → Dream dialogue/effects | Existing opening retained | Opening sequence/controller |
| Opening completion → playable Bedroom | Implemented locally; unpublished | Deferred handoff from opening controller |
| Bedroom introduction → exploration | Implemented locally; unpublished | Story controller writes completion after final reflection |
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

### Opening-to-Bedroom contract

The Project Lead approved this introduction's endpoint, playable destination,
bedside arrival, whole-sequence lock, all branches, completion timing, and separate
test entry. The local implementation passed automated validation and received
Project Lead manual acceptance on October 20, 2026; Git publication is pending.

| Requirement | Local implementation |
| --- | --- |
| Dream endpoint | Waking fade/black hold after the final Dream line; waking dialogue belongs to Bedroom |
| Destination | Story wrapper instances the existing laboratory, keeping direct F6 exploration separate |
| Spawn | Room-local bedside position; future completed re-entry accepts an entrance position |
| Control | One story input owner; release guards before environmental activation resumes |
| Camera | Existing fixed Bedroom camera, with a brief restored-offset buzz shake |
| Dialogue | Shared Reality presentation and typewriter; story owns progression |
| Scene lifetime | Completion schedules the scene replacement after callbacks unwind |
| State | One registered session-completion flag after final reflection; local-only choice |

Spawn and visual tunables remain provisional implementation values; see
[the architecture guide](PROJECT_STRUCTURE.md#story-bedroom-and-phone-components).
This accepted integration remains local until Git publication is authorized and verified.

### Connected-chapter dependencies

- Preserve the accepted introduction contract during chapter integration;
  provisional content is not automatically final narrative.
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
from the local source, not a record of newly executed tests.

| Current testable path | Focus |
| --- | --- |
| F5 Dream → Bedroom | Dream cue order, safe handoff, bedside lock, one copy of waking lines, all branches, reflection, and exploration |
| F6 room laboratories | Movement/animations, collisions, camera; Bedroom skips introduction without writing completion |
| Developer introduction entry | Repeated branch testing using the same logic without story-state changes |
| Phone and input boundaries | Keyboard/mouse choices, holds, resize alignment, final-screen dwell, and no event acting twice |
| Session entry | Completion timing, completed re-entry skip, fresh-session reset |
| Bedroom objects | Notebook keypress repeats; card stays completed for that loaded instance and resets on reload |
| Garden Lily | Automatic approach, no immediate reopening while nearby, and repetition after leaving/re-entering |
| Dialogue close/cancellation | Restored movement/idle behavior, a shifted camera returning, finish outcome, and no double input action |

**Validation status:** the local introduction passed all 156 automated checks and
received Project Lead manual acceptance on October 20, 2026. Git publication is
pending. The matrix above remains a regression guide; no tests were rerun for
this documentation update. Full chapter travel and Sanity remain future work;
standalone laboratory success cannot establish them.

## Unresolved flow questions

1. Which rooms and events form the rest of the first chapter, in what order?
2. Which future descriptions repeat locally, and which approved events must persist
   across room changes? Should any be restored after quitting?
3. What are the additional approved event IDs and Sanity inputs/outputs?
4. What owns future general character/NPC cinematic input, locking, and camera use?
5. Which narrative proposals, ending conditions, final art, and audio are approved?

Record approved answers in [Design decisions](DESIGN_DECISIONS.md), then update
this flow only when the corresponding intent or implementation is confirmed.
