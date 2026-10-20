# Withering Away

Withering Away is the working title of a 2D psychological horror game being
developed by seven students for **Month of Horror #2: Withering Away**. The current
repository contains a scripted Dream opening, playable environment prototypes,
and shared gameplay foundations. The published Dream-to-Bedroom introduction connects
the opening to exploration; it is not yet a complete story chapter.

The Project Lead's current narrative premise follows **Albert as he begins his
first day of college**, with psychological deterioration and dream imagery as
the developing direction. The final title, full plot, and endings remain open.
See [game flow and narrative status](docs/GAME_FLOW.md) for the boundary between
the implemented sequence and proposed story concepts.

## The Theme — Withering Away

The official theme of [Month of Horror #2](https://itch.io/jam/month-of-horror-2)
is **Withering Away**. It can describe harm that settles in unnoticed, like a
parasite drawing vitality from its surroundings. As it grows stronger, what
supports it begins to decay. The theme also makes room for natural decline and
impermanence: things end, and renewal remains a possibility rather than a promise.

Our developing interpretation follows Albert, a first-year college student
dealing with perfectionism, expectations, and insecurity. His psychological
deterioration should build gradually; he does not start the story already
severely worn down. The Dream Garden and proposed Corpse Lily could give that
slow decline a symbolic form. Their exact meaning, the plot, and the ending
remain open. A complete Sanity system has not yet been confirmed as integrated into the published build.

The jam's optional challenges explore the passage from autumn into winter,
progressive decay, and a parasitic plant that thrives as other life fades.
These are prompts to consider, not requirements or completed features.

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
   [scenes/Dream.tscn](scenes/Dream.tscn). Expect black first, then typing after a
   short delay. E/Space reveals and advances Dream dialogue. The white Dream
   background is a placeholder. The opening then enters the playable Bedroom:
   waking dialogue, phone conversation, one choice, reflection, and exploration.
5. To test a room, open one of the laboratory scenes below and press **F6** to
   run that scene. Opening a room resource alone does not provide the laboratory's
   player and camera setup.
6. To test the Bedroom introduction without replaying Dream, open
   [bedroom_intro_test.tscn](scenes/tests/bedroom_intro_test.tscn) and press F6.
   It uses the actual story sequence without reading or writing its completion
   flag. Rerun it to test another branch. The ordinary Bedroom laboratory below
   still starts directly in exploration.

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
| Bedroom introduction dialogue | E, Space, or left click | Reveal the current line, then advance on a distinct press |
| Ordinary phone screen | E, Space, or left click anywhere | Advance one screen; the last branch screen waits for another press to close |
| Phone choices | W/S or Up/Down | Highlight one of three responses |
| Phone choices | Enter/Space, or click a response | Confirm once; E and clicks outside responses do not confirm |

These use the Input Map actions `ui_left`, `ui_right`, `ui_up`, `ui_down`, and
`dialogue_advance`. Release before pressing again: held keys and duplicate input
are guarded. Opening effects run their own timed sequence, so a press does not
skip an entire transition.

Player movement pauses during environmental dialogue and resumes after closing.
Repeat rules belong to each object: the Bedroom notebook can repeat while nearby,
the card completes once per loaded scene instance, and the Garden's Corpse Lily
starts automatically and repeats after leaving and returning. Dialogue placement
keeps Albert and the object clear, using a short camera pan when needed and feasible.

## Current implementation and publication status

The Dream-to-Bedroom introduction is **implemented, manually accepted, and
published** in [`fad8a76`](https://github.com/AzureZephyry/withering-away-jam/commit/fad8a76a309a181799374afa4855480af971906e).
Its original validation passed 156 checks, and the Project Lead accepted it on
October 20, 2026. The subsequent Dream dialogue signal repair was also manually
accepted and published in [`eef63da`](https://github.com/AzureZephyry/withering-away-jam/commit/eef63dadc673bf4a389c4ccf9e8d511e2d42fa47),
the current confirmed main baseline.

- **Initial Dream opening:** provisional dialogue, typewriter text, speaker names,
  eyelid animation, and glitch effects. Its waking fade hands off to the playable
  Bedroom. The three waking lines now belong to the Bedroom introduction.
  Final Dream artwork and audio remain unfinished.
- **Bedroom introduction:** Albert stands beside the bed while movement and
  environmental interactions are locked. Reality dialogue leads into a brief
  visual phone buzz, `!!!`, a centered prepared phone overlay, all three family
  conversation branches, and branch-specific reflection. Exploration returns
  after the final reflection. Final phone-buzz audio is still missing.
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
  Autoload. The `bedroom_intro_completed` flag records the entire story
  introduction only after its last reflection is dismissed. Choices have no
  lasting consequences. Sanity and persistent saves remain outside this system.

## Approved Sanity design — integration unverified

The approved direction uses one reversible integer deterioration score and three
playable Sanity stages, with Game Over at the terminal threshold. Environmental
changes follow narrative timing rather than necessarily appearing at each score
boundary. Session-only checkpoint retry and a compact top-right HUD are also
design directions; their implementation is not established. Christan's separate
development progress remains unverified. The existing phone choices stay neutral.
See [Sanity design](docs/SANITY_DESIGN.md) for the rules, art handoff, and unresolved details.

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

- **New contributor:** start with the [Git collaboration handbook](docs/GIT_WORKFLOW.md)
  for setup, branches, committing, publishing a development branch, and reviewed integration.
- **Existing contributor:** use the [existing-clone companion](docs/GIT_EXISTING_CONTRIBUTORS.md)
  to inspect local work, preserve it, synchronize deliberately, and handle conflicts.
  The parent handbook supplies the shared policies for both routes.
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

These are the seven members' confirmed development areas, not a list of completed features.

| Team member | Area |
| --- | --- |
| Prince | Project Lead / System Integrator; engineering coordination and Game State |
| Ali | Opening, UI, and relevant gameplay integration |
| Christan | Environmental dialogue development and Sanity engineering |
| Lawrence | Audio and sound |
| Isabela | Visual art, original character artwork, dialogue UI, narrative, and dialogue |
| Kayla | Visual art, environmental and map development |
| Wayne | Visual art; specific assignments and deliverables unconfirmed |

Wayne is our seventh member, contributing to visuals alongside Isabela and Kayla.
His specific assets, assigned scenes, deliverables, and implementation status have
not yet been confirmed.

## Contributing

Use the [Git handbook](docs/GIT_WORKFLOW.md) as the detailed contributor reference;
start with [existing-clone diagnosis](docs/GIT_EXISTING_CONTRIBUTORS.md) if you
already have local work. Branch names do not permanently limit responsibilities;
coordinate the current task and overlapping files before editing.

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

Room-to-room travel and persistent saves are not implemented. The approved
Sanity, session-checkpoint, and HUD directions are not yet confirmed integrated
into the published build. The phone images are accepted temporary placeholders
with differing visible widths. Final narrative content, Dream backgrounds,
audio, and font redistribution permission
still require follow-up. See [flow prerequisites](docs/GAME_FLOW.md#integration-prerequisites)
and [the status snapshot](docs/TEAM_PROGRESS.md) before planning integration.
