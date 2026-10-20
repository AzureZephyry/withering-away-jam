# Sanity system design

[README](../README.md) · [Design decisions](DESIGN_DECISIONS.md) ·
[Game flow](GAME_FLOW.md) · [Team progress](TEAM_PROGRESS.md)

## Scope and status

This is the primary reference for the Project Lead-approved Sanity design for
the currently untitled psychological horror game. Withering Away is the working
title and the jam theme. These are design decisions, not evidence of a completed
Sanity implementation.

| Area | Current status |
| --- | --- |
| Score, three stages, recovery, and failure threshold | Approved design; implementation and shared integration not established |
| Narrative-dependent environmental transformations | Approved direction; exact triggers, timing, and asset specifications unresolved |
| Session-only checkpoint retry | Approved design; locations, restoration contract, and implementation unresolved |
| Sanity HUD | Approved compact top-right direction; mockup is concept/reference only, not implemented or approved production art |
| GameState V1 and first family phone conversation | Existing published functionality; preserved without new Sanity effects |
| Christan's separate Sanity development | Current implementation, interface, and integration status unverified |

The technical target remains Godot 4.7.2 with GDScript. This document approves no
new scripts, nodes, Autoloads, APIs, or concrete checkpoint schema. Architecture
requires a separate implementation review with the relevant owners.

## Score and stages

Use one underlying **integer deterioration score**, initially **0**, with a
minimum of **0**. Higher values mean greater deterioration.

| Stage | Name | Deterioration score | Meaning |
| --- | --- | --- | --- |
| Level 1 | Sane | 0–1 | Albert is relatively psychologically stable |
| Level 2 | Moderately Sane | 2–3 | Albert experiences noticeable psychological deterioration |
| Level 3 | Insane | 4–5 | The most severely deteriorated playable stage |
| Game Over | Failure state | 6 | Terminal deterioration threshold |

These are fictional gameplay labels, **not clinical diagnoses**. Game Over is a
failure state, not a fourth Sanity stage or a fourth environmental transformation.
Level 3 remains playable and recoverable. Only three major visual states are
required; movement within a band does not require another visual variant.

### Discrete, reversible decisions

| Explicitly classified decision/event | Change to the same score |
| --- | --- |
| Relevant negative or destabilizing decision | +1 |
| Relevant positive or restorative decision | −1, stopping at 0 |
| Neutral decision | 0 |

Changes are discrete and decision/event-driven. There is no continuous or
time-based drain, passive regeneration, fractional change, or separate positive
and negative streak counter. Both directions use the accumulated integer value.
Intra-stage progression is hidden; whether the final HUD exposes the integer
remains unresolved.

For example: **0 → 1 → 2 → 3 → 2 → 1 → 0**. One restorative decision reverses
one point, not necessarily a whole stage. At Level 3:

- **4 → 5 → 6:** two destabilizing decisions lead to Game Over.
- **5 → 4:** one restorative decision leaves Albert in Level 3.
- **4 → 3:** one restorative decision returns Albert to Level 2.
- A restorative decision at **0** leaves the score at **0**.

### Story decision boundaries

Only decisions/events explicitly classified by narrative and gameplay design
affect the score. Not every dialogue option has a Sanity consequence. Specific
future choices, event identifiers, and their mapping remain unapproved.

**All three branches of the accepted first family phone conversation remain
Sanity-neutral.** Their existing local branch/reflection behavior and GameState
completion behavior stay unchanged. Do not retroactively attach consequences.
See the existing [phone flow](GAME_FLOW.md#phone-screens-and-choices).

### Game Over

Reaching **6** triggers Game Over; scores **4–5** do not. Exact presentation,
narrative dialogue/consequences, animations, audio, transitions, and any
relationship to an ending remain unresolved. This threshold does not establish
an ending or authorize new narrative content.

## Environmental presentation

The visual team—**Isabela, Kayla, and Wayne**—will provide environmental artwork
and stage variants as workload permits. These directions are thematic guidance,
not finalized asset specifications or a claim that the artwork exists:

| Stage | Visual direction |
| --- | --- |
| Level 1 | Generally healthy, recognizable, stable surroundings; subtle unease may remain |
| Level 2 | Noticeable deterioration; possible wilting vegetation, altered atmosphere, or stronger unsettling details |
| Level 3 | Strong deterioration; possible parasitic imagery, decay, and oppressive atmosphere |

Garden/Dream symbolism and the Corpse Lily's meaning still require approved
narrative decisions. Proposed symbolism is not finalized canon. Different rooms
need not transform identically.

### Option C: narrative-dependent transformations

**Option C — Narrative-Dependent Environmental Transformations** is approved.
A score crossing does not require the environment to change immediately.
Keep three concepts distinct:

1. Albert's authoritative current Sanity stage, derived from the score.
2. The environment's currently presented visual state.
3. The narrative timing of a visual transition.

A transformation may be witnessed during gameplay, occur during a scene
transition, appear through a Dream reveal, or become visible on a return visit.
The same rule applies to recovery. Environmental presentation should eventually
reflect the appropriate state within its approved narrative context. Exact
triggers and timing remain unresolved; a delayed visual change does not delay
the authoritative score/stage change.

### Art handoff and integration

Artists intend to supply **both full-map visual references and individual modular
environmental assets**. A full-map reference communicates composition; it is not
automatically a complete playable map. Three separate complete maps are not a
delivery requirement.

A shared layout with replaceable or stage-specific visuals is a **possible
engineering approach**, not an approved implementation architecture. Integration
may involve sprite placement, environmental layers, object alignment,
stage-specific appearance and visibility, and visual checks for each stage.
Verify uncertain placements through visual review rather than assuming them.
Preserve appropriate collisions, camera boundaries, and existing Bedroom,
Garden, and School behavior.

No specific per-room asset assignment or completed deliverable is established
here. Wayne's specific deliverables remain unconfirmed. Coordinate actual asset
handoff and scene ownership before implementation.

## Session-only checkpoints

Checkpoints are **temporary, in-memory state for the current application
session**. After Game Over, the intended retry returns to the most recent
applicable checkpoint. Locations, activation conditions, and frequency are not
yet decided; no checkpoint implementation is established by this design.

Closing the game discards checkpoint information and story/session progress.
The next application launch begins again at the **Dream opening**, with score
**0**, **Level 1**. This scope includes neither persistent disk saves nor a
Load Game system.

### Restoration responsibilities

A checkpoint must restore a consistent playable state. Conceptually relevant
information may include scene/location, Player position, deterioration score and
corresponding stage, necessary story progression, relevant session event flags,
and state needed for consistent environmental presentation. Because visual
transitions can be delayed, score alone may not describe the currently displayed
environment.

Exact snapshot structure, state ownership, and restoration order/responsibilities
require engineering review. This is not a concrete save schema or API.

### Boundary with existing GameState V1

[GameState V1](game_state.md) is the already published session-based Boolean
story/event flag registry. It is not the new Sanity or checkpoint manager.
Sanity calculations and checkpoint restoration are not established parts of its
current contract. Do not silently combine these responsibilities into a general
manager or invent event names. Any interface with existing flags needs explicit
coordination and review.

### Unresolved checkpoint details

- Locations, activation triggers, and frequency.
- Visual/audio activation feedback and exact retry UI.
- Game Over before any checkpoint exists.
- Which checkpoint is applicable in each narrative context.
- Detailed restoration behavior, snapshot ownership, and coordination with flags
  and environmental presentation.

## Sanity HUD direction

The intended HUD is a small element in the **top-right of the gameplay screen**.
It should be legible at **1280 × 960**, distinguish the three Sanity stages,
support discrete changes, minimally obstruct gameplay, and fit the pixel-art
psychological horror presentation and original team-created artwork.

The discussed generated mockup is **CONCEPT / VISUAL REFERENCE ONLY**. It is not
implemented in Godot, approved production artwork, or an authorized final HUD
asset. No reference image is added by this documentation. Adding it to the game
or repository requires separate approval. Artists may use it for inspiration
without reproducing it. Respect the jam's restrictions on generated production
assets; see the [project theme and jam reference](../README.md#the-theme--withering-away).

Final visual treatment, indicators, dimensions, and whether to display the hidden
integer score remain unresolved. No specific HUD-art assignment is established.

## Responsibilities and remaining review

Prince coordinates design/integration as Project Lead. Christan owns the
Sanity-related engineering area; his separate progress must be verified before
planning integration. Isabela contributes narrative and visual decisions, with
Kayla and Wayne contributing visuals. Ali's opening/UI integration and Lawrence's
audio responsibilities require coordination where affected; this design does
not transfer their systems or prove new deliveries. See
[confirmed responsibilities](TEAM_PROGRESS.md#confirmed-responsibilities).

Before implementation, resolve specific story classifications, the concrete
Sanity/checkpoint interfaces, narrative visual triggers, actual art handoffs,
Game Over/retry presentation, and final HUD details. Preserve the accepted
Dream-to-Bedroom sequence, neutral phone branches, existing GameState behavior,
and standalone room behavior while reviewing those interfaces.

Future implementation validation should cover every score boundary in both
directions, the lower bound, Level 3 recovery, failure at 6, neutral choices,
narrative-timed deterioration/recovery visuals, consistent checkpoint retry,
and a fresh launch at Dream/0/Level 1. These are **future test requirements**, not
completed runtime results for the newly designed systems.
