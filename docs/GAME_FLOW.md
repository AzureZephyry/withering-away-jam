# Game flow

[README](../README.md) · [Project structure](PROJECT_STRUCTURE.md) ·
[Team progress](TEAM_PROGRESS.md) · [Design decisions](DESIGN_DECISIONS.md)

## Scope and evidence

This guide covers the published Scene 02 milestone (`b40ab47`) and the accepted
School Exterior release. The earlier `863678e` Sanity baseline was verified on
main during the October 23, 2026 audit. The introduction
passed 156 automated checks, received Project Lead acceptance on October 20, 2026,
and was published in `fad8a76`. Its later Dream signal repair was also manually
accepted and published in `eef63da`. The earlier `590184b` snapshot remains a
historical reference in [Development history](DEVELOPMENT_HISTORY.md).

**Published** means present in the inspected main history. **Prototype** means an
implemented experiment, not a complete chapter. **Planned** describes intended
integration; **proposed/unresolved** describes choices that still need agreement.
For milestone evidence, see [Development history](DEVELOPMENT_HISTORY.md).

Scene 02 was published in `b40ab47`. The accepted handoff now connects Bedroom
departure to School Exterior free exploration. The 1.1475× environment and Level 1
atmosphere have passed Project Lead visual review. Scene 03 narrative is not
implemented.

## F5: the actual application flow

The shared [GameClock](../scripts/game_clock.gd) is a separate session-only
Autoload: it begins at 06:30, advances one game minute every real second,
wraps after 24 hours and survives scene changes and dialogue. Explicit
`set_time(hour, minute)` overrides resume normal ticking; ordinary transitions do
not reset it. Only School Exterior currently uses its seven-phase atmospheric
lighting. It triggers no story events or Sanity changes and does not replace
scripted alarm text. This implementation is runtime-validated and manually
accepted; see the
[School prototype guide](SCHOOL_EXTERIOR_PROTOTYPE.md#session-clock-and-atmosphere).
The Time HUD is instanced in both Bedroom and School laboratories. The Bedroom
story keeps it hidden until exploration begins; its scripted wake-up alarm label
and introduction remain separate. School also instances the existing adaptive
Sanity HUD. Neither display resets the shared clock during departure.

The configured main scene is [scenes/Dream.tscn](../scenes/Dream.tscn).
`GameState` and `SanityState` are available as separate Autoloads. The scene's
`OpeningSequence` Control runs [opening_sequence.gd](../scripts/opening_sequence.gd).
There is no movable overworld Player in this scene.

### Execution overview

```text
F5: Dream.tscn
    black text -> eyes opening -> Dream dialogue/effects
    -> waking fade to black -> playable Bedroom
    -> waking lines -> buzz/shake -> !!! -> phone -> choice -> selected branch
    -> reflection -> Bedroom exploration -> three required object inspections
    -> right door Yes -> fade -> School Exterior sidewalk arrival -> free exploration
    Scene 03 narrative is not implemented.

F6: choose one independent test entry point
    Bedroom laboratory: camera_lab.tscn
    Garden laboratory:  garden_camera_lab.tscn
    School Interior:    school_camera_lab.tscn
    School Exterior:    school_exterior_lab.tscn (original laboratory spawn)
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
keeps its existing branch/reflection and completion behavior. The Sanity
integration adds +1 only when Option 3 is committed; Options 1/2 stay neutral.
No response flags, relationship, ending, or persistent save consequences are added.

All 16 canvases come from `assets/ui/phone/prepared/`, at 640 × 1088. One viewport
center and uniform scale are used across screens. At 1280 × 960, the default 0.75
scale displays 480 × 816; smaller viewports reduce the common scale to fit with
16-pixel margins. Filtering is nearest. Accepted visible-width differences remain.

## Scene 02 — First Morning

The story wrapper's [bedroom_scene02.gd](../scripts/bedroom_scene02.gd) takes over
objectives after the introduction releases exploration. It does not replace the
introduction, environmental controller, or shared Player. The initial objective
is **Get ready for your first day.** Its checklist requires the study
planner/notebook, Student ID, and graduation medal, in any order.

Only a matching successful `interaction_finished(target, true)` completes an
inspection. Starting, partly reading, cancelling, or failing placement does not.
The session flags are `bedroom_schedule_checked`, `bedroom_id_checked`, and
`bedroom_medal_checked`; `bedroom_intro_completed` still means final introduction
reflection dismissal. Reinspection is allowed and does not duplicate completion.

Small diamond markers identify unfinished required objects, then disappear on
completion without disabling those objects. Scripted/modal presentation hides
the markers and objective UI. The ordinary E/Space proximity prompt is separate.
Object Focus displays replaceable item illustrations above or below Reality
dialogue, centered horizontally in the entire viewport and fitted clear of the
dialogue and adaptive Sanity HUD. It owns visuals only; see
[Object Focus](overworld_interactions.md#object-focus).

After all three inspections, the checklist collapses to **Head out for school.**
The door becomes the marked destination. Near the right door, E/Space shows:

- Before completion: **Finish getting ready before leaving.**
- After completion: **Would you like to leave your dorm?**, with **Yes / Not Yet**.

Not Yet is selected initially and returns to exploration. W/S or Up/Down selects;
a fresh E/Space/Enter reveals typing first, then confirms on a later press.
Buttons also support clicking. Yes locks further departure input, fades to black,
and loads [school_exterior_story.tscn](../scenes/story/school_exterior_story.tscn).
That wrapper instances the existing exterior laboratory, places Albert at
`SchoolArrivalSpawn` `(183.6, 1484.865)` on the lower-left outside sidewalk, updates
the bounded camera under black, and fades in before restoring movement. The
introduction/preparation flags and Sanity Autoload state survive the handoff.
The Bedroom endpoint and Return to Bedroom UI are not carried into School. The
physical Bedroom door collision remains closed; this is a scene change, not a
physical opening or a save checkpoint.

Same-session story re-entry also preserves preparation. Fresh application sessions
start with all four GameState flags false. No lateness, physical Bedroom NPCs,
additional Sanity consequences, Scene 03, or new narrative sequence is introduced.

## F6: standalone exploration prototypes

These remain independent exploration test entries. The story wrapper reuses
Bedroom's laboratory, but running the laboratory itself does not start the story. Open
the laboratory, not just its room resource, and press F6. Each laboratory supplies
the shared Albert Player and a camera; room resources supply scenery/collisions.

| Scene | Available experience | Current limits |
| --- | --- | --- |
| [camera_lab.tscn](../scenes/prototypes/camera_lab.tscn) | Walk through the Bedroom, collide with solid furniture/walls, inspect notebook/Student ID/medal with Object Focus; fixed room camera | Right door closed; direct entry skips the introduction and never writes its flag |
| [garden_camera_lab.tscn](../scenes/prototypes/garden_camera_lab.tscn) | Explore the Garden with limited continuous camera follow, overhead fading, and automatic Corpse Lily dialogue | Conversation is temporary test content; no story-state effect or exit transition |
| [school_camera_lab.tscn](../scenes/prototypes/school_camera_lab.tscn) | Explore the School Interior with classrooms, library, lobby/study areas, collisions, and bounded continuous follow | No environmental dialogue controller or connected School story progression; not the required School Exterior |
| [school_exterior_lab.tscn](../scenes/prototypes/school_exterior_lab.tscn) | Explore Wayne's complete School Exterior with editable collisions, foreground objects and bounded 2× follow | Original F6 testing spawn; the local story wrapper supplies sidewalk arrival after Bedroom departure; no Scene 03 narrative; see the [prototype guide](SCHOOL_EXTERIOR_PROTOTYPE.md) |
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
The shared controller writes no GameState flags. The story-only Scene 02 listener
records its three approved preparation flags after matching successful completion.

### Current repetition examples

| Object | Activation and presentation | After successful completion |
| --- | --- | --- |
| Bedroom desk notebook | Manual, radius 92, Real World panel + Object Focus | Keypress repeat; story reinspection uses the completed schedule response |
| Bedroom Student ID | Manual, radius 76, Real World panel + Object Focus | Keypress repeat; story preparation completion remains idempotent |
| Bedroom graduation medal | Manual, radius 72, Real World panel + Object Focus | Keypress repeat; story preparation completion remains idempotent |
| Garden Corpse Lily | Automatic, radius 84, Dream World panel | Re-entry: staying nearby does not reopen it; leave and return to repeat |

These lines are development descriptions/conversation, not finalized story.
Restarting/reloading the scene recreates these target-local completion states.
There is no persistent or cross-scene completion record for them yet.

GameState does not automatically record object examination. Scene 02 explicitly
connects its approved targets to preparation flags; target-local one-time behavior
does not provide that integration for other scenes.

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

## Sanity integration and planned retry flow

The Sanity foundation, combined HUD, and phone Option 3 consequence are now
**implemented, validated, Project Lead-accepted, and published in `863678e`**.
Environmental transformations and retry remain planned. Use
[Sanity design](SANITY_DESIGN.md) for the current API and full specification.

An explicitly classified decision changes the shared deterioration score by
+1, −1, or 0, with a minimum of 0. The score determines one of three playable
stages. Level 3 remains recoverable; reaching 6 instead triggers Game Over,
not a fourth stage. Phone Options 1/2 remain neutral; Option 3 now adds +1.
Its existing narrative sequence and GameState completion behavior are unchanged.

This is the only consequential production choice. Normal story play reaches
score 0 or 1; recovery, higher stages, and failure are implemented in the service
and exercised by tests, without further story choices making them reachable yet.
Failure currently supplies state, notification, and the temporary zero-bar HUD,
not a complete Game Over presentation, gameplay pause, or scene transition.

Option C separates the current stage from the environment currently shown.
An approved narrative moment may reveal deterioration or recovery during play,
a transition, a Dream, or a return visit; crossing a score boundary need not
immediately replace the visuals.

Game Over retry is intended to restore the most recent applicable in-memory
checkpoint, rewinding later decisions and restoring deterioration to exactly 4
(two bars, Level 3). Mandatory penalties must not create an unavoidable death loop.
Snapshot/restoration details and the no-checkpoint case remain unresolved.
Closing the game discards checkpoint/story progress; the next launch begins at
the Dream opening with score 0, Level 1. There is no persistent save or Load Game
system in this design. Existing GameState V1 remains the Boolean event registry,
not an implemented Sanity/checkpoint manager.

## Transition inventory

| Connection | Current status | Owner or required decision |
| --- | --- | --- |
| Black → eyes opening → Dream dialogue/effects | Existing opening retained | Opening sequence/controller |
| Opening completion → playable Bedroom | Accepted and published in `fad8a76`; signal repair in `eef63da` | Deferred handoff from opening controller |
| Bedroom introduction → exploration | Accepted and published in `fad8a76` | Story controller writes completion after final reflection |
| Potential connections among existing room prototypes | **Undesigned or unimplemented; chapter travel order is not approved** | Agree on narrative order, entry/exit rules, and scene ownership first |
| Scene 02 preparation → Bedroom door | Accepted preparation/choice behavior retained; manually accepted local Yes handoff reaches School Exterior | Bedroom-specific controller; Not Yet resumes exploration and the physical doorway remains closed |
| Bedroom → School Exterior free exploration | Implemented and manually accepted | Thin story wrapper reuses the existing laboratory and named exterior sidewalk marker; no Scene 03 narrative |
| F6 → selected laboratory | Published editor test entry point | Developer chooses the standalone scene |
| Classified decision/event → Sanity response | Accepted phone Option 3 integration published in `863678e` | Prince oversees Sanity; further outcomes require approval |
| Session → persistent save | Deferred | Separate save/load design and authorization |

## Intended direction and narrative uncertainty

The confirmed minimum objective is **Chapter 1 — Year One**. Its revised scene
flow awaits team approval; the published introduction is not a complete chapter.

**Confirmed protagonist:** Albert James Dimapilis, 18, is a first-year BSCS student
in a Philippine setting. A former valedictorian and top student from a small town,
he carries pressure to succeed. He values quiet study places, routine, academic
achievement, and personal status; he fears failure, judgment, crowded environments,
and falling behind. His deterioration should develop gradually rather than
starting at its most severe level. These are approved character facts, not a claim
that every detail is already conveyed in the implemented dialogue.

**Confirmed horror direction:** Dream Garden, Corpse Lily, intrusive thoughts,
psychological temptation, academic/family expectations, roots, spores, parasites,
decay, withering, and Sanity-dependent environmental/perceptual horror. The last
of these remains planned rather than a delivered transformation system.

**Narrative secret for implementation coordination:** the mysterious opening
voice is intended to be the Corpse Lily. Its player-facing speaker remains `???`.
This does not finalize the Lily's symbolism or wider supernatural explanation.

**Draft boundary:** Isabela is correcting/revising the earlier proposed chapter
screenplay. No finalized revision was found in the inspected repository. Its
suggested NPCs, relationships, academic events, dialogue, climax, and ending are
not approved canon. Do not use that proposal as the official route or confirmed
cast. Multiple endings and detailed Garden symbolism also remain unresolved.

### Confirmed locations versus implemented maps

| Location | Current repository status |
| --- | --- |
| Bedroom | Implemented story room; local Scene 02 Yes departure continues to School Exterior free exploration through the manually accepted handoff |
| Dream Garden | Independent playable laboratory with temporary Corpse Lily dialogue; Dream's opening still reveals white |
| School Interior | Independent prototype with classrooms, library, lobby/study areas; not School Exterior |
| School Exterior | Existing standalone prototype plus local Bedroom-to-sidewalk handoff; corrected perimeter collision and foreground separation retained; Scene 03 narrative remains unimplemented |
| Roads and family house | Future locations discussed; no integrated scenes found |

Absence from the repository does not establish whether off-repository artist work
is complete. Confirm deliveries and approved scene use with the team.

### Overworld and Visual Novel presentation

**OW** covers player exploration, object inspection, NPC proximity interactions,
and eventual map navigation. **VN** covers scripted conversations, important
choices, limited backgrounds, audio cues, fades, and short effects. Reuse existing
idle/walk artwork and lightweight presentation rather than requiring extra sitting,
writing, sleeping, phone-holding, or other minor-action animations.

The current components support environmental conversations and specific scripted
sequences. Map navigation, a general branching dialogue framework, and a complete
NPC cinematic system are not supplied merely by adopting these presentation forms.

## Integration prerequisites

### Opening-to-Bedroom contract

The Project Lead approved this introduction's endpoint, playable destination,
bedside arrival, whole-sequence lock, all branches, completion timing, and separate
test entry. The introduction passed automated validation, received Project Lead
acceptance on October 20, 2026, and was published in `fad8a76`. Its accepted Dream
signal repair is published in `eef63da`.

| Requirement | Published implementation |
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
The introduction and signal repair are accepted and published; future changes
require their own review and authorization.

### Connected-chapter dependencies

- Preserve the accepted introduction contract during chapter integration;
  provisional content is not automatically final narrative.
- Agree on room entry/exit behavior and chapter order before implementing travel.
  Preserve standalone laboratory testing while integrating scenes.
- Approve descriptive production event names and their meanings before adding
  GameState callers; define who sets/resets each event and who consumes it.
- Coordinate environmental content with the published interaction contract.
  Prince oversees current Sanity integration; Christan is temporarily helping
  Lawrence with audio. Define cinematic NPC interfaces before connecting them.
- Integrate approved background artwork and Lawrence's actual audio resources;
  maintain Dream/Real world styling and correct reveal/advance behavior.
- Test the connected path repeatedly, including restored controls/camera after
  dialogue, collisions, event lifetime, and transitions. Standalone success alone
  does not establish a complete chapter.

These are integration dependencies, not authorization to implement them now.

## Flow validation guidance

The current paths below can be tested now. These are procedures/expected behavior
from published source and accepted gameplay milestones, not a record of newly executed tests.

| Current testable path | Focus |
| --- | --- |
| F5 Dream → Bedroom | Dream cue order, safe handoff, bedside lock, one copy of waking lines, all branches, reflection, and exploration |
| F6 room laboratories | Movement/animations, collisions, camera; Bedroom skips introduction without writing completion |
| Developer introduction entry | Repeated branch testing using the same logic without story-state changes |
| Phone and input boundaries | Keyboard/mouse choices, holds, resize alignment, final-screen dwell, and no event acting twice |
| Session entry | Completion timing, completed re-entry skip, fresh-session reset |
| Bedroom objects | All three repeat; success-only preparation flags, any order, markers, centered Object Focus and HUD clearance |
| Scene 02 door | Early reminder, Yes / Not Yet, School arrival after fade, duplicate-input protection and retained session progress; the local handoff has focused runtime coverage |
| Garden Lily | Automatic approach, no immediate reopening while nearby, and repetition after leaving/re-entering |
| Dialogue close/cancellation | Restored movement/idle behavior, a shifted camera returning, finish outcome, and no double input action |

**Validation status:** the introduction passed 156 automated checks and received
Project Lead acceptance on October 20, 2026 before publication in `fad8a76`.
The accepted signal repair in `eef63da` passed 57 Dream and 144 Bedroom runtime
checks. The matrix above remains a regression guide; no tests were rerun for
that documentation update. Full chapter travel remains future work. Sanity's
focused tests previously passed 163 checks plus 2 fresh-process checks; the Project
Lead has now manually accepted the relevant Dream, phone, HUD, and interaction flow;
see [Sanity validation](SANITY_DESIGN.md#validation-and-manual-review).

## Unresolved flow questions

1. Which rooms and events form the rest of the first chapter, in what order?
2. Which future descriptions repeat locally, and which approved events must survive
   room changes or be restored on checkpoint retry? Cross-launch progress is
   outside the approved session-only design.
3. Which additional decisions/events affect Sanity, beyond the accepted phone
   Option 3 integration, and when should their outcomes commit?
4. What owns future general character/NPC cinematic input, locking, and camera use?
5. Which narrative proposals, ending conditions, final art, and audio are approved?

Record approved answers in [Design decisions](DESIGN_DECISIONS.md), then update
this flow only when the corresponding intent or implementation is confirmed.
