# Withering Away

Withering Away is the working title of a 2D psychological horror game being
developed by six students for **Month of Horror #2: Withering Away**. The current
repository contains an initial scripted opening, playable environment prototypes,
and shared gameplay foundations. It is still in development; the prototypes do
not yet form a connected story chapter.

The Project Lead's current narrative premise follows **Albert as he begins his
first day of college**, with psychological deterioration and dream imagery as
the developing direction. The final title, full plot, and endings remain open.
See [game flow and narrative status](docs/GAME_FLOW.md) for the boundary between
the implemented sequence and proposed story concepts.

## Technology

- **Engine:** Godot 4.7.2.
- **Language:** GDScript.
- **Renderer:** Forward Plus, as configured in the project.
- **Display target:** 1280 × 960 (4:3), using `canvas_items` stretch mode.
- **Presentation:** 2D pixel art, including Albert's original directional sprites
  and separate Dream World and Real World dialogue artwork.

Release platforms and minimum hardware requirements have not been established
in the verified project material. The 4:3 viewport is the design target; it is not
a claim that every resized window is forced to that aspect ratio.

## Getting started

1. Clone [the repository](https://github.com/AzureZephyry/withering-away-jam), or
   obtain a copy from the team:

   ```sh
   git clone https://github.com/AzureZephyry/withering-away-jam.git
   ```

2. In Godot 4.7.2's Project Manager, choose **Import**, select `project.godot` from
   your copy, and open the project.
3. Wait for Godot to finish importing resources before running a scene.
4. Press **F5** to run the configured main scene,
   [scenes/Dream.tscn](scenes/Dream.tscn). This runs the scripted opening, not a
   playable room. Expect black first, then typing after a short delay. Focus the
   running game window and use E/Space to reveal and advance lines. The white Dream
   background and later waking-room view are intentional placeholders.
5. To test a room, open one of the laboratory scenes below and press **F6** to
   run that scene. Opening a room resource alone does not provide the laboratory's
   player and camera setup.

| Standalone prototype | Scene to open | Current camera |
| --- | --- | --- |
| Bedroom | [camera_lab.tscn](scenes/prototypes/camera_lab.tscn) | Fixed room view, 2.5× zoom |
| Dream Garden | [garden_camera_lab.tscn](scenes/prototypes/garden_camera_lab.tscn) | Continuous follow with room limits, 2.5× zoom |
| School | [school_camera_lab.tscn](scenes/prototypes/school_camera_lab.tscn) | Continuous follow with room limits, 2.5× zoom |

## Controls

| Context | Input | Behavior |
| --- | --- | --- |
| Playable scenes | WASD or arrow keys | Move Albert in eight directions; diagonals are normalized |
| Manual environmental interaction | E or Space while the prompt is shown | Start the selected nearby object's dialogue |
| Automatic environmental interaction | Enter its configured radius | Start dialogue without an activation key |
| Dialogue is typing | E or Space | Reveal the current line |
| Dialogue is fully revealed | E or Space | Advance; close after the final environmental line |

These use the Input Map actions `ui_left`, `ui_right`, `ui_up`, `ui_down`, and
`dialogue_advance`. Release before pressing again: held keys and duplicate input
are guarded. Opening effects run their own timed sequence, so a press does not
skip an entire transition.

Player movement pauses during environmental dialogue and resumes after closing.
Repeat rules belong to each object: the Bedroom notebook can repeat while nearby,
the card completes once per loaded scene instance, and the Garden's Corpse Lily
starts automatically and repeats after leaving and returning. Dialogue placement
keeps Albert and the object clear, using a short camera pan when needed and feasible.

## Current published implementation

- **Initial Dream opening:** provisional dialogue, typewriter text, speaker names,
  eyelid animation, glitch effects, and a waking-up placeholder. It does not yet
  transition into the playable Bedroom. Backgrounds and audio integration remain
  unfinished.
- **Environment prototypes:** Bedroom, Garden, and School layouts with movement,
  collisions, and their own camera setups. The Bedroom includes notebook and card
  interactions; the Garden includes the Corpse Lily interaction prototype.
- **Environmental interactions:** reusable object configuration and a scene-local
  controller support automatic proximity triggers, manual E/Space activation,
  keypress/re-entry/one-time repeat rules, movement locking/restoration, and
  camera-aware dialogue placement. Cinematic opening dialogue has its own controller.
- **Albert:** the shared Player/controller owns movement and collisions; a separate
  animation helper supplies eight-direction facing, directional idle animations,
  and directional walking animations. It mirrors the original right-facing art
  for left-facing presentation on the sprite only. Selection follows input and
  actual movement; stopping preserves facing.
- **GameState V1:** validated, session-based Boolean event flags through an
  Autoload. The production event registry is currently empty; story progression
  events and Sanity mechanics are not implemented by this foundation.

## Project navigation

`scenes/` contains the opening, shared Player, and UI. `scenes/prototypes/`
contains standalone laboratories, room resources, and drawing helpers.
`scripts/` holds shared behavior; `assets/` holds artwork, animation resources,
fonts, and audio placeholders. Use the structure guide for exact dependencies.

## Documentation

### Orientation and runtime

- [README: project overview, setup, and controls](README.md) — this entry point.
- [Project structure](docs/PROJECT_STRUCTURE.md) — file navigation, scene roles,
  dependencies, and unfinished integration.
- [Game flow](docs/GAME_FLOW.md) — actual runtime sequences, missing transitions,
  and clearly separated narrative intentions.

### Continuity and coordination

- [Development history](docs/DEVELOPMENT_HISTORY.md) — meaningful published
  milestones and their verified commits.
- [Team progress](docs/TEAM_PROGRESS.md) — verified status, responsibilities,
  dependencies, and proposed next priorities.
- [Design decisions](docs/DESIGN_DECISIONS.md) — accepted constraints, known
  rationale, provisional choices, and unresolved questions.

### System usage

- [Environmental interactions](docs/overworld_interactions.md) — scene setup,
  activation rules, dialogue placement, and current examples.
- [Albert animations](docs/albert_animation.md) — sprite resources, frame layout,
  directional animation, and player integration.
- [GameState V1](docs/game_state.md) — event registration, API, validation, and
  session reset behavior.

## Team responsibilities

These are development areas, not a list of completed features.

| Team member | Area |
| --- | --- |
| Project Lead | Engineering coordination, Game State, and integration oversight |
| Ali | Opening cinematic, Scene 1, and integration toward the playable Bedroom |
| Christan | Environmental dialogue development and Sanity System |
| Kayla | Environment and map development |
| Isabela | Narrative, dialogue, original character artwork, and dialogue UI artwork |
| Lawrence | Audio and sound |

## Contributing

Develop in your assigned branch, fetch updates before planning integration, and
coordinate before editing another teammate's area or shared resources. Keep
shared `main` stable and preserve teammates' work. Review changed files and verify
affected scenes in Godot before proposing integration. Publish only reviewed,
authorized changes. Preserve original artwork/audio and required resource and
UID files when adding or moving resources.

### Keeping the documentation accurate

Documentation is part of meaningful accepted work. Understand and implement the
approved change, validate it, obtain required review, and update only the affected
documents. Verify the descriptions against the implementation and review code and
documentation together before an authorized commit/publication. Verify publication
before calling a feature published.

| Change | Detailed reference to update |
| --- | --- |
| Setup, controls, or main entry point | This README |
| Architecture, dependencies, or public file locations | [Project structure](docs/PROJECT_STRUCTURE.md) and affected system guide |
| Approved narrative/runtime progression | [Game flow](docs/GAME_FLOW.md) |
| Important accepted decision or supersession | [Design decisions](docs/DESIGN_DECISIONS.md) |
| Meaningful published milestone worth preserving | [Development history](docs/DEVELOPMENT_HISTORY.md) |
| Confirmed ownership, blocker, or priority change | [Team progress](docs/TEAM_PROGRESS.md) |
| Interaction, animation, or state contract | The corresponding specialized guide above |

Committed source defines implemented behavior; verified Git history defines
published changes. Approved decisions define intended constraints, not proof of
implementation. Team assignments do not prove completion. Mark material unknowns
explicitly and distinguish proposed, implemented locally, tested, accepted,
published, deferred, and superseded work. Keep important superseded reasoning in
the decision/history records when it is known.

Use one detailed source per topic and cross-link it. Do not rewrite every guide
for a routine test run, temporary debugging, a failed experiment, or a cosmetic
internal edit. Avoid extra history entries that merely repeat a commit hash.

## Known limits

There is no connected opening-to-Bedroom handoff or room-to-room travel yet.
GameState has no registered story events; Sanity and persistent saves are outside
its current implementation. Narrative content, final backgrounds, audio, and font
redistribution permission still require follow-up. See [flow prerequisites](docs/GAME_FLOW.md#integration-prerequisites)
and [the status snapshot](docs/TEAM_PROGRESS.md) before planning integration.
