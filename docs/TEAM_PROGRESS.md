# Team progress

[README](../README.md) · [Game flow](GAME_FLOW.md) ·
[Project structure](PROJECT_STRUCTURE.md) · [Development history](DEVELOPMENT_HISTORY.md) ·
[Design decisions](DESIGN_DECISIONS.md)

## Delivery objective

The minimum intended story scope is **Chapter 1 — Year One**. The published
Dream-to-Bedroom introduction and Scene 02 preparation are retained. Accepted
Bedroom departure now reaches School Exterior free exploration, with Level 1
lighting, shadows, fog and HUDs. Scene 03 narrative remains unimplemented. Garden
and School Interior are independent laboratories. Isabela is revising the
proposed screenplay; later dialogue, scene order and ending remain unapproved.

**Project Lead-reported deadline:** November 9, 2026. This date is attributed to
the Project Lead and has not been independently verified against an organizer
schedule in this snapshot.

## Current introduction status — published

The Project Lead approved implementation of Dream → Bedroom awakening → visual
phone buzz/shake → reaction → centered family conversation → one of three branches
→ reflection → exploration. The published files implement that sequence using the
existing Bedroom, Player, Reality panel, environmental system, and GameState.

All three phone branches are present. `bedroom_intro_completed` records only the
last reflection dismissal in story context. The developer introduction test uses
the same logic without reading/writing completion; ordinary Bedroom F6 remains
exploration-only. The accepted Sanity extension now adds +1 for Option 3 only;
Options 1/2 stay neutral, with story completion behavior unchanged.

**Status:** implemented, manually accepted, and published. The introduction passed
156 automated checks and received Project Lead acceptance on October 20, 2026;
it was published in [`fad8a76`](https://github.com/AzureZephyry/withering-away-jam/commit/fad8a76a309a181799374afa4855480af971906e).
The later Dream signal repair passed 57 Dream and 144 Bedroom runtime checks,
received Project Lead F5 acceptance, and was published in
[`eef63da`](https://github.com/AzureZephyry/withering-away-jam/commit/eef63dadc673bf4a389c4ccf9e8d511e2d42fa47),
the published Dream signal-repair baseline. These are prior validation results; no
runtime tests were rerun for this documentation update. See [Game flow](GAME_FLOW.md)
for the contract and regression procedures. Final phone-buzz audio, final Dream
art, room travel, and persistent saves remain unfinished. Sanity's first playable
integration is implemented and manually accepted; later Sanity features remain planned.

## First playable Sanity integration — published

Published commit:
[`863678e92e27e59450b8ebf2d11b950d2d91c546`](https://github.com/AzureZephyry/withering-away-jam/commit/863678e92e27e59450b8ebf2d11b950d2d91c546)
— `feat: integrate sanity system and adaptive HUD`.

The separate SanityState service provides integer deterioration, three playable
stages, recovery, failure notification, and explicit reset. Isabela's seven supplied
HUD images are integrated with adaptive dialogue-aware corners and short visual
feedback. Phone Options 1/2 remain neutral; Option 3 adds +1 exactly once. It is the
only consequential production choice, so normal story play reaches score 0 or 1.
Higher stages/failure are available in the service/tests, not yet the story route.

The Project Lead manually accepted Dream-to-Bedroom, all phone options and Option
3's consequence, adaptive Garden HUD placement, and relevant interactions, reporting
no unusual gameplay behavior. Publication validation reran **163 Godot-native
checks and 2 fresh-process checks**, and verified **330 documentation links/anchors**
against the public candidate. These are historical publication results, not tests
newly executed for this documentation update. Full failure presentation,
checkpoints/retry, transformations, psychological text, and further story
consequences remain unimplemented; sanity_00.png remains temporary.

## Scene 02 — First Morning: published

The Project Lead manually playtested and accepted both the implementation and
refinement. The story Bedroom now requires successful notebook, Student ID, and
graduation medal inspections in any order, with a checklist and diamond markers.
Object Focus artwork is centered horizontally and adapts vertically to Reality
dialogue and HUD clearance. All three inspections remain repeatable. The gated
door offers Yes / Not Yet. The initial temporary endpoint is superseded by the
accepted School Exterior handoff; session flags and Sanity are preserved.
Scene 03 narrative is not implemented.

Reported refinement validation passed **849 Scene 02 checks**, **163 existing
Dream/phone/Sanity checks**, and **2 fresh-session checks**, all without failures.
Reported project lint covered **21 scenes and 24 scripts**, with no errors or
warnings. Responsive UI checks covered 1280 × 960, 960 × 720, and 1600 × 900;
live visual checks were at 1280 × 960. These are historical refinement results,
not fresh tests claimed by this documentation update. Manual acceptance is
separate evidence. Scene 02 publication is verified in `b40ab47`.

The item illustrations and medal representation are replaceable placeholders.
No new final artist/audio deliveries or physical Bedroom NPCs are claimed.
See [Scene 02 flow](GAME_FLOW.md#scene-02--first-morning) for the implemented
boundary and [Object Focus](overworld_interactions.md#object-focus) for ownership.

## Earlier verified published snapshot

**Implementation verified at published commit:** `590184baf43a43410e7f6288258d1ef080d17967` —
`feat: add session-based game state management`.

The main reference matched this baseline during that earlier documentation
inspection. The table below records that earlier state and predates the now-published
introduction described above. That inspection covered main and its meaningful history,
the existing system guides, and the Project Lead's confirmed context/assignments.
This is not a live status report on every teammate branch. Other branches were
not audited for current functionality, acceptance, or integration readiness.

### Status vocabulary

| Status | Meaning |
| --- | --- |
| Published | Verified as included in shared main |
| Accepted locally | Reviewed/accepted work that is not necessarily committed or published |
| Implemented but unverified | Code exists, but required validation or acceptance has not been established |
| Prototype | Implemented experiment, not automatically a final system or chapter; may also be published |
| Assigned | Confirmed responsibility, without proof of completion |
| Proposed | Suggested direction; implementation authorization is not implied |
| Planned | Intended work whose completion is not established |
| Deferred | Deliberately outside the current scope |
| Blocked | A confirmed impediment prevents required progress; record the evidence and needed action |
| Unresolved | A decision, contract, or material fact is still unknown or unsettled |

Categories can apply together. An assigned responsibility is not completed work;
an implemented branch is not necessarily accepted or published. No completion
percentages are inferred.

## Published work at that earlier snapshot

| Area | What is available | Boundary |
| --- | --- | --- |
| Initial Dream opening | Provisional Scene 1 lines, typewriter, speaker presentation, eyelids, glitch/deterioration, waking placeholder | No playable Bedroom handoff; final backgrounds/audio/narrative remain unfinished |
| Display and controls | 1280 × 960 target, `canvas_items` stretch, WASD/arrows, E/Space dialogue action | Release platforms/hardware baseline not established here |
| Bedroom | Fixed-camera 512 × 384 room, furniture/wall collisions, notebook/card interactions | Standalone prototype; right door closed, no travel |
| Garden | Exploration/collisions, limited follow camera, overhead fading, Corpse Lily example | Standalone prototype; temporary dialogue and no story-state wiring |
| School | Exploration/collisions and limited continuous-follow camera | Standalone prototype; no dialogue controller attached in its laboratory |
| Environmental interactions | Reusable targets/controller/overlay, activation/repeat options, movement locking, safe placement | Separate from cinematic NPC work; completion stored per target instance |
| Albert | Original directional idle/walk sprites, shared Player, eight-direction animation integration | Shared resource changes require checks in every hosting scene |
| GameState V1 | Session Autoload, strict registry/API, change signal/reset | Empty production event registry; no story callers, Sanity, or saves |

Detailed behavior belongs in [Game flow](GAME_FLOW.md) and the three system guides;
verified commit milestones belong in [Development history](DEVELOPMENT_HISTORY.md).

## Confirmed responsibilities

The current team has seven members. Assignments below come from the Project Lead;
they do not prove completion or assign authorship to every file in a shared system.

| Person | Confirmed responsibility | Verified implementation and limits |
| --- | --- | --- |
| Prince | Project Lead / System Integrator; gameplay, Sanity engineering, Game State Management, integration oversight | Shared foundations and the accepted introduction/repair are published; future integration needs coordination |
| Ali | Opening, UI, and relevant gameplay integration | Opening/UI and the Bedroom handoff are published; assigned areas do not establish authorship of every integrated file |
| Christan | Environmental dialogue; temporarily assisting Lawrence with audio | Current Sanity engineering is overseen by Prince; do not assume an independent current Sanity implementation |
| Lawrence | Audio and sound | Opening/typewriter expose audio hooks; main contains audio placeholder files, not finished audio integration; current delivery status is unverified |
| Isabela | Visual art, original character artwork, dialogue UI, narrative, and dialogue | Original Albert sheets and Dream/Real panel artwork are integrated; complete/final narrative approval is not established |
| Kayla | Visual art, environmental and map development | Prototype rooms exist on main; her current deliverables and branch status were not verified |
| Wayne | Environmental pixel art alongside Isabela and Kayla | School Exterior ZIP and Krita sources delivered; corrected artwork integrated and Level 1 environment accepted; source/export differences remain documented |

## Current development areas

| Area | Classification | Next evidence needed |
| --- | --- | --- |
| Existing laboratories and shared systems | Published prototypes/foundations | Validate affected scenes when their contracts change |
| Dream → Bedroom introduction | Accepted and published in `fad8a76`; accepted signal repair published in `eef63da` | Preserve the verified flow and test affected paths when changing it |
| Environmental descriptions beyond current examples | Assigned; additional progress unverified | Inspect Christan's actual content/interface and agree on scene ownership |
| Sanity | Foundation/HUD and first phone consequence accepted and published in `863678e` | Further outcomes need separate approval; current story score is only 0 or 1 |
| Session-only checkpoint retry | Approved design; implementation not established | Locations, activation, retry behavior, and restoration ownership |
| Sanity HUD | Isabela's seven combined images integrated and Project Lead-accepted, with adaptive corners and dark pulse | sanity_00.png remains an approved unfinished placeholder; final delivery/review pending |
| Environment/map expansion | Bedroom plus independent Garden/School Interior labs and accepted School Exterior | Continue approved Scene 03 development; retain the complete map as visual authority |
| Story event registration | One introduction-completion flag and three published success-only preparation flags | Further events require approved meanings, producers, and consumers |
| Connected room travel and chapter progression | Accepted Bedroom-to-School Exterior departure; Scene 03 narrative unimplemented | Approve Scene 03 NPCs, dialogue and objectives separately |
| Save/load | Deferred outside GameState V1 | Separate requirements/design before implementation |
| Chapter 1 — Year One narrative, final title/endings | Minimum chapter scope confirmed; screenplay under revision, final flow/content unresolved | Isabela's revised script and team approval; no draft NPC/event/ending promoted into canon |
| Central documentation set | Published implementation contracts linked to specialized guides | Keep local, accepted, and published status distinct when maintaining affected documents |

[Sanity design](SANITY_DESIGN.md) records the newly approved mechanics,
narrative-dependent visual timing, session-only checkpoints, and HUD direction.
The foundation, HUD, and first phone consequence are accepted and published;
environmental transformations, psychological text, and session retry
remain unimplemented. Isabela supplied the seven HUD images. Isabela, Kayla, and
Wayne form the visual team; environmental references/modular assets remain intended
as workload permits, without assigning unconfirmed deliverables.

Previously reported validation passed 163 Godot-native checks, 2 fresh-process
checks, Godot scene/script validation on 17 scenes/21 scripts with no errors or warnings, and 170
documentation links/anchors. The Project Lead subsequently tested Dream-to-Bedroom,
all phone options and Option 3's consequence, adaptive Garden HUD placement, and
relevant interactions, reporting no unusual gameplay behavior. These are accepted
prior results, not newly executed tests recorded by this status update.

The central guides distinguish published implementation from approved design and
proposed work. Their presence alone does not establish implementation or publication.

## Integration dependencies and real constraints

- **Chapter flow:** the published Dream handoff loads the story Bedroom; room markers
  and doors still supply no travel logic. Later chapter connections need approved
  entry/travel rules and coordinated environment/narrative content.
- **Narrative revision:** Isabela's revised Chapter 1 screenplay and approved OW/VN
  sequence are pending verification. The earlier proposal is not finalized canon.
- **Environment deliveries:** the existing School Interior is not the required
  School Exterior. Wayne's artwork is integrated in the
  [asset library](../assets/environments/school_exterior/README.md); source files
  are archived externally. The exterior supports accepted free exploration;
  separate road and family-house scenes remain future work. Other deliveries and new assignments are not inferred.
- **Story state:** one published introduction-completion flag and three published
  preparation flags have distinct meanings. Unknown
  reads still return null and writes are rejected. Sanity remains separate:
  the local phone Option 3 consequence adds +1 without changing completion flags.
  Further outcomes require coordinated review with Prince and narrative owners.
- **Dialogue ownership:** environmental content can reuse
  [the published interaction contract](overworld_interactions.md). Future NPC
  cinematics require separate coordination with the opening/sequence owner.
- **Visibility:** panel placement has limited free space and respects camera
  limits. New text, art, camera setups, or room layouts need tests; impossible
  placement deliberately cancels instead of covering a subject.
- **Shared assets:** changing the Player, font, panel, or typewriter affects
  multiple consumers. Preserve original art and test both the opening and labs
  relevant to the change.
- **Assets/content:** Dream artwork and phone screenshots remain placeholders;
  waking dialogue now appears over the real Bedroom. Audio cues are not playback,
  and font redistribution permission is unresolved. Confirm actual
  artwork/content decisions and Lawrence's audio deliveries before integration.
  See [font permission](DESIGN_DECISIONS.md#d05--world-specific-supplied-dialogue-artwork-and-a-shared-typewriter)
  before public build distribution.
- **Later mechanics:** complete Game Over presentation and session checkpoint/retry
  need separate approved implementation; their design is not evidence of delivery.

These are verified gaps, dependencies, or documented limits. No new runtime
failure was reproduced during this documentation-only inspection. Unknown
teammate progress is not labeled a confirmed technical blocker.

## Current introduction review boundary

The introduction is complete: all 156 automated checks passed, and the Project
Lead manually tested and accepted it on October 20, 2026. Publication of the
introduction (`fad8a76`) and its accepted signal repair (`eef63da`) is verified.

The contract is recorded in [Game flow](GAME_FLOW.md#opening-to-bedroom-contract).
The completed validation and manual acceptance covered:

- The existing Dream order/effects and approved waking handoff, with the three
  waking lines appearing once over the playable Bedroom.
- A valid bedside spawn with Albert visible, idle, and locked for the story.
- Deliberate movement/input lock release and control handoff, with opening
  dialogue/effect cleanup and no competing input owners.
- Correct camera initialization/framing and functional destination dialogue.
- All three phone branches, reflections, centered artwork, keyboard/mouse choices,
  and one-action-per-press boundaries.
- Completion written only after final reflection in story context, re-entry
  skipping completed introduction, and developer tests isolated from that state.
- Actual Godot 4.7.2 runtime verification of the handoff and subsequent exploration.
- No regression in F5 opening behavior or independent F6 laboratory entry points,
  movement, collisions, dialogue, or camera behavior.

The checkpoint and repair are published; new changes still require their own
review, acceptance, and publication authorization. Later chapter flow
also depends on verified Christan/Kayla/Lawrence deliverables and approved narrative
and state contracts; those assignments alone establish no current readiness.

## Proposed next priorities

This is a recommended coordination order, not newly approved implementation or
a schedule. The Project Lead and responsible teammates must confirm it.

1. Review this knowledge base, especially unresolved narrative/flow and ownership
   assumptions; keep status wording tied to the inspected source.
2. Preserve the accepted, published introduction and signal repair when planning
   further chapter integration; test affected input, movement, and camera behavior.
3. Agree with Isabela on progression/content and with Prince on further Sanity
   integration; approve real GameState event IDs as needed.
4. Coordinate Kayla's room deliverables and Lawrence's actual audio assets with
   that flow. Resolve font permission and final placeholder replacements.
5. Once connections exist, validate the complete path, including control/camera
   restoration, room collisions, event lifetime, and transitions, rather than
   relying only on independent laboratory checks.

## Updating this snapshot

Update the baseline and relevant rows when a meaningful accepted milestone is
verified on main, ownership changes, an integration blocker is confirmed/resolved,
a priority changes, or teammate work becomes verified. State whether evidence is
published source, a reviewed branch, a local implementation, or a confirmed team
update; do not promote one category to another silently.

Keep this a current reference, not a chronological archive. Move enduring
milestones into [Development history](DEVELOPMENT_HISTORY.md) and approved
constraints/reasons into [Design decisions](DESIGN_DECISIONS.md). Follow the
[README documentation rule](../README.md#keeping-the-documentation-accurate),
including checking publication before marking it complete. Routine tests, minor
edits, and unverified branch rumors do not need new tracker entries.
