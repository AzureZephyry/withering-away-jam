# Sanity system design

[README](../README.md) · [Design decisions](DESIGN_DECISIONS.md) ·
[Game flow](GAME_FLOW.md) · [Team progress](TEAM_PROGRESS.md)

## Scope and status

This is the primary Sanity reference for the currently untitled psychological
horror game. Withering Away remains the working title and jam theme.

The first playable integration is **published** in
[`863678e`](https://github.com/AzureZephyry/withering-away-jam/commit/863678e92e27e59450b8ebf2d11b950d2d91c546),
after automated validation and the Project Lead's accepted manual playtest.
This covers the foundation, adaptive combined HUD, and initial phone consequence;
it does not mark the deferred features below complete.

| Area | Status |
| --- | --- |
| Integer deterioration, stages, recovery, failure, reset | Published and Project Lead-accepted; focused automated validation passed |
| Combined HUD and first phone consequence | Published and Project Lead-accepted |
| Narrative-dependent environmental transformations | Approved design; not implemented |
| Psychological text manifestations | Approved future direction; wording, triggers, timing, and intensity unresolved; not implemented |
| Session-only checkpoints and fixed-score retry | Approved design; not implemented |
| GameState V1 | Existing published Boolean registry, unchanged by Sanity implementation |

Prince directly oversees gameplay mechanics, Sanity engineering, and integration.
Christan is temporarily assisting Lawrence with audio; do not assume a separate
current Sanity implementation by Christan. Isabela supplies the HUD artwork.
Isabela, Kayla, and Wayne contribute visuals; Wayne's School Exterior artwork
is now integrated. The atmospheric clock does not alter Sanity. Ali retains opening/UI integration responsibilities.

The target is Godot 4.7.2 and GDScript. This checkpoint introduces no environmental
switching, checkpoint storage, retry UI, New Game coordinator, or persistent saves.

## Score, playable stages, and HUD mapping

Use one integer deterioration score, initially 0, bounded from 0 to 6.
Stage and bars are derived, never independently mutable counters.

| Score | State | Bars remaining | Combined texture |
| --- | --- | --- | --- |
| 0 | Level 1 — Sane | 6 | sanity_06.png |
| 1 | Level 1 — Sane | 5 | sanity_05.png |
| 2 | Level 2 — Moderately Sane | 4 | sanity_04.png |
| 3 | Level 2 — Moderately Sane | 3 | sanity_03.png |
| 4 | Level 3 — Insane | 2 | sanity_02.png |
| 5 | Level 3 — Insane | 1 | sanity_01.png |
| 6 | Game Over | 0 | sanity_00.png |

The labels describe fictional gameplay states, not clinical diagnoses.
Game Over is not a fourth playable level or a fourth environmental transformation.
Level 3 remains playable and recoverable. There are three major stage appearances,
with seven bar-count images; no separate portrait-switching system is needed.

### Discrete, reversible decisions

- Explicitly approved destabilizing decision: +1.
- Explicitly approved restorative decision: −1, stopping at 0.
- Neutral decision: 0.

Both directions affect the same accumulated value. There is no time-based drain,
passive regeneration, fractional change, or positive/negative streak counter.
For example: **0 → 1 → 2 → 3 → 2 → 1 → 0**.
**5 → 4** stays Level 3; **4 → 3** restores Level 2; **2 → 1** restores Level 1.
**5 → 6** enters Game Over. Ordinary effects are rejected after failure until
an explicit reset or a future authorized restoration.

Numeric consequences are hidden before a choice is committed. The HUD communicates
bars afterward; the raw deterioration number is not displayed by this implementation.
Not every dialogue choice or environmental interaction affects Sanity.

## Session service and API

[sanity_state.gd](../scripts/sanity_state.gd) is the separate SanityState Autoload.
Its required UID sidecar accompanies the script. The project registration uses
that UID. It survives ordinary scene changes and starts at 0 on a new application.
There is no file storage and no automatic reset when Dream or a room loads.

| API | Contract |
| --- | --- |
| get_score() -> int | Read authoritative deterioration |
| get_stage() -> Stage | SANE, MODERATELY_SANE, or INSANE at scores 0–5; NONE at failure |
| is_failed() -> bool | True exactly at score 6 |
| apply_effect(effect: Variant) -> bool | Accept only actual integers −1, 0, +1; reject incompatible values and ordinary effects after failure |
| reset_session() -> bool | Explicitly return to 0 / SANE / non-failed |

The internal score is not exported and has no public arbitrary-score setter.
Callers use the methods rather than changing internal fields. Floats, Booleans,
strings, unsupported integers, and other incompatible values are rejected without
mutation. Neutral effects and recovery at zero are accepted without numerical
change notifications. Mutation requests during a notification batch are rejected,
including reset requests, so callbacks cannot interrupt the announced transition.

### Notifications and order

All authoritative values are updated before callbacks run.

1. score_changed(previous: int, current: int) after an actual numerical change.
2. stage_changed(previous: Stage, current: Stage) if entering a different playable
   stage. Failure uses NONE internally and does not emit a fourth-level change.
3. game_over() when entering failure, once per entry.

Examples: 1 → 2 emits score then stage; 2 → 3 emits score only; 4 → 3 emits score
then stage; 5 → 6 emits score then failure. Reset from failure emits score 6 → 0
then stage NONE → SANE. Reset within Level 1 emits only a score change if needed;
reset at 0 emits nothing. Reset clears failure and allows a later failure entry.
Consumers query current state during initialization, then subscribe to changes.

GameState V1 remains the published Boolean story/event flag registry. SanityState
neither stores those flags nor resets them. No general manager or event bus is
introduced. Coordinating an eventual New Game action remains separate work.

## First consequential family phone choice

The first implementation supersedes the earlier all-neutral phone decision.

| Visible option | Established response meaning | Effect |
| --- | --- | --- |
| 1 | Thank you. | Neutral, 0 |
| 2 | Don't worry, I got this. | Neutral, 0 |
| 3 | I'm a little nervous, ma. | Destabilizing, +1 |

The existing phone maps selected_choice + 1 to branch identity; branch 3 starts
at Screen 12. Prepared screenshot wording does not redefine the established
branch meanings. Dialogue, choices, phone screens, and reflections are unchanged.

[phone_conversation.gd](../scripts/phone_conversation.gd) emits
choice_committed(branch: int) only after committing a choice and switching away
from the choice screen. The [Bedroom story controller](../scripts/bedroom_intro.gd)
owns the consequence and guards it once per conversation occurrence. Highlighting,
typing, ordinary advances, branch completion, and GameState notifications do not
apply it. There is no generalized global decision-occurrence registry.

On a fresh run, Option 3 gives **0 → 1**, **six → five bars**, and remains Level 1.
The existing bedroom_intro_completed flag is still written only after the final
reflection. Completed story re-entry skips the phone and cannot repeat its effect.
The dedicated introduction test entry uses the real Sanity consequence but still
bypasses story-completion reads/writes; restart that test for a fresh session.

No other narrative or environmental consequence is introduced. In particular,
the Garden Lily's repeatable test conversation stays neutral.
Normal story play therefore reaches only score 0 or 1. Higher stages, recovery,
and terminal failure exist at the system level and in tests, without additional
production choices making them naturally reachable yet.

## Combined HUD artwork and lifecycle

Isabela's seven complete images live at these exact paths:

- res://assets/ui/sanity/sanity_06.png
- res://assets/ui/sanity/sanity_05.png
- res://assets/ui/sanity/sanity_04.png
- res://assets/ui/sanity/sanity_03.png
- res://assets/ui/sanity/sanity_02.png
- res://assets/ui/sanity/sanity_01.png
- res://assets/ui/sanity/sanity_00.png

The bar is on the left and Albert's portrait on the right in the normal stage
images. Each is one combined PNG; never split or independently reposition them.
Filename numbers mean bars remaining: **visible_bars = 6 − deterioration_score**.

The reusable [sanity_hud.tscn](../scenes/UI/sanity_hud.tscn) and
[sanity_hud.gd](../scripts/sanity_hud.gd) select one texture directly from the
current score, including on scene entry, recovery, and failure. One instance is
authored in each Bedroom, Garden, and School laboratory. The story Bedroom
inherits its laboratory HUD; it does not add another. Dream has no gameplay HUD.
Scene replacement frees the departing HUD and the next one reads session state.

The HUD is screen-space CanvasLayer 3. It ignores mouse input, uses nearest
filtering, and fits the entire image without cropping or stretching. At 1280 × 960,
the default slot is 426 × 136 with 24-pixel viewport margins; smaller widths
shrink the slot proportionally. Normal 213 × 43 images display at 2× within it.
The story fade and phone dimmer are above this layer; the HUD remains visible
during the phone choice with the same dimming as the room.

### Final zero-bar artwork

Isabela's final `sanity_00.png` replaces the earlier temporary image. Its original
220 × 59 RGBA bytes are unchanged, with
true transparency. Visible content occupies `Rect2(0, 6, 213, 44)`.
[The AtlasTexture](../assets/ui/sanity/sanity_00_display.tres) omits only transparent
canvas padding at display time. It presents the full text and portrait at 426 × 88
inside the existing 426 × 136 slot; the other six images remain 426 × 86 at 2×.
No PNG was cropped, repainted or resized, and no Game Over behavior changed.

For a display-only development preview, run a laboratory and select **Remote →
SanityHUD → Development preview → Preview Zero Sanity**. Disable it to return to
the live image. The debug-only option does not change session score, emit Game
Over or create a checkpoint. `sanity_00` means zero remaining bars at internal
score 6; internal score 0 still displays six bars (`sanity_06.png`).

### Dialogue-aware placement and feedback

| Actually displayed dialogue | Combined HUD corner |
| --- | --- |
| None | Upper-right |
| Bottom | Upper-right |
| Top | Lower-right |

The shared dialogue panel joins the dialogue_panels group. Each scene-local HUD
binds to the existing panels after scene initialization, using their visibility
and rectangle-change signals. It checks the actual visible panel rectangle,
including camera-aware environmental placement and Bedroom story dialogue.
Changes are coalesced; unrelated UI events do not move it. Closing dialogue
returns the HUD to the upper-right. Dynamically introduced panel lifecycles would
need a separate review; no universal dialogue manager is added.

Corner changes briefly fade out, reposition the whole component, then fade in
(0.10 seconds each direction by default). A score change switches the image
immediately and adds one dark modulation pulse, returning over 0.24 seconds.
Stage transitions and failure use a deeper 0.42-second pulse. No flashing loop,
new shader, generated visual asset, input block, or camera effect is introduced.
The Project Lead accepted the current gameplay presentation; timing and sizing
remain tunable through future approved changes.

## Environmental transformations — approved, not implemented

Only three major environmental states are required. Isabela, Kayla, and Wayne
intend to supply full-map visual references plus individual modular assets as
workload permits. References communicate composition; they are not automatically
playable maps, and three complete replacement maps are not required.

Level 1 is generally healthy/recognizable/stable with possible subtle unease.
Level 2 may show wilting, altered atmosphere, and noticeable deterioration.
Level 3 may show stronger decay, parasitic imagery, and oppressive atmosphere.
These are thematic directions, not final asset specifications or narrative canon.
Garden/Lily symbolism still needs narrative approval.

Option C — Narrative-Dependent Environmental Transformations remains approved.
Authoritative Sanity, current environmental presentation, and narrative transition
timing are distinct. Deterioration and recovery visuals may change during play,
scene transitions, Dream reveals, or return visits rather than immediately on
crossing a score band. Presentation should eventually match its approved context.
Exact triggers remain unresolved; not every room must transform identically.

A shared layout with stage-specific visual components is a possible approach,
not a delivered transformation engine. Preserve collisions, camera limits,
interactables, and visual review of uncertain placements when integrating assets.

## Future session-only checkpoints and retry

Checkpoints remain planned in-memory state, discarded when the application closes.
A fresh launch starts at Dream, score 0, Level 1. There is no disk save or Load Game.

The newly approved retry rule supersedes restoring the checkpoint's old score:
retry rewinds narrative progress and post-checkpoint decisions, restores appropriate
interaction completion and environmental presentation, and sets deterioration
to **exactly 4**, **two bars**, **Level 3**. Decisions after the checkpoint can
be played again. Mandatory penalties must not create an unavoidable immediate
Game Over loop; recovery or a different meaningful decision must be possible.

Locations, activation conditions/frequency, applicability, activation feedback,
retry UI, the no-checkpoint case, and the detailed restoration contract remain
unresolved. Scene/location and Player position also need consistent restoration.
No checkpoint storage, respawn, restoration API, or retry UI is implemented here.

## Deferred manifestations and asset boundaries

Chaotic/intrusive on-screen text and narrative visual disturbances are approved
future directions. Their wording, intensity, triggers, and timing remain unresolved.
No such text, effect system, or new narrative content is implemented.

The earlier generated HUD mockup remains concept/reference only and is not
imported. This implementation uses Isabela's supplied images and accepted updated
direction. Preserve original art; do not generate, crop, recolor, or replace
production artwork without explicit approval. Respect the jam's restrictions on
generated production assets.

Failure currently provides the terminal state, notification, and zero-bar image.
It does not add a Game Over menu, scene handoff, gameplay pause, or retry controls.
The final failure presentation still requires its own approved integration.

## Validation and manual review

The focused Godot-native test entry is
[sanity_tests.tscn](../scenes/tests/sanity_tests.tscn), driven by
[sanity_tests.gd](../scenes/tests/sanity_tests.gd). Run it headlessly from the project
with Godot 4.7.2. Add -- --fresh-session-probe for the independent initial-state check.

Coverage includes boundaries/recovery, invalid effects, notification order/state,
failure/reset, actual texture selection, scene lifetime, adaptive panel placement,
phone branches and duplicate input, normal Dream handoff, and environmental
interaction regressions. The accepted implementation previously passed 163
Godot-native checks plus 2 fresh-process checks; Godot scene/script validation
reported 17 scenes and 21 scripts with no errors or warnings, alongside an earlier
170-link/anchor check. Publication validation of the public candidate reran the
163 checks and 2 fresh-process checks and verified 330 documentation links/anchors.
These are historical results, not gameplay tests rerun for this documentation update.

The Project Lead has since manually accepted the Dream-to-Bedroom sequence, all
three phone choices and Option 3's consequence, adaptive Garden HUD placement,
and relevant interactions, reporting no unusual gameplay behavior. Isabela has
since delivered the final zero-bar artwork; it is integrated with a padding-only AtlasTexture.

For regression review, launch F5 from a fresh game: complete Dream, reach the phone,
choose Option 3, and check six → five bars while Level 1 portrait remains.
Finish the reflection and explore. Repeat fresh launches for Options 1/2: both
keep six bars. Run Garden with F6 and approach the Lily from north and south to
check opposite dialogue/HUD corners and restoration after closing. Inspect the
corner fade, dark pulse, readability, and temporary failure artwork separately
using controlled test state; no extra story consequences or debug controls are added.
