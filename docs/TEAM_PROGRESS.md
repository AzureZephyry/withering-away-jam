# Team progress

[README](../README.md) · [Game flow](GAME_FLOW.md) ·
[Project structure](PROJECT_STRUCTURE.md) · [Development history](DEVELOPMENT_HISTORY.md) ·
[Design decisions](DESIGN_DECISIONS.md)

## Delivery objective

The immediate team objective is a coherent playable game-jam submission or chapter
built from the existing foundations. The published introduction connects Dream
to Bedroom exploration; the remaining rooms do not yet form a connected chapter.

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
exploration-only. Branch choice has no lasting gameplay consequence.

**Status:** implemented, manually accepted, and published. The introduction passed
156 automated checks and received Project Lead acceptance on October 20, 2026;
it was published in [`fad8a76`](https://github.com/AzureZephyry/withering-away-jam/commit/fad8a76a309a181799374afa4855480af971906e).
The later Dream signal repair passed 57 Dream and 144 Bedroom runtime checks,
received Project Lead F5 acceptance, and was published in
[`eef63da`](https://github.com/AzureZephyry/withering-away-jam/commit/eef63dadc673bf4a389c4ccf9e8d511e2d42fa47),
the current confirmed main baseline. These are prior validation results; no
runtime tests were rerun for this documentation update. See [Game flow](GAME_FLOW.md)
for the contract and regression procedures. Final phone-buzz audio, final Dream
art, room travel, Sanity integration, and persistent saves remain unfinished.

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
| Prince | Project Lead / System Integrator; engineering coordination, Game State Management, integration oversight | Shared foundations and the accepted introduction/repair are published; future integration needs coordination |
| Ali | Opening, UI, and relevant gameplay integration | Opening/UI and the Bedroom handoff are published; assigned areas do not establish authorship of every integrated file |
| Christan | Environmental dialogue development and Sanity engineering | Published reusable environmental contract is available for his content; his current branch implementation/status was not verified |
| Lawrence | Audio and sound | Opening/typewriter expose audio hooks; main contains audio placeholder files, not finished audio integration; current delivery status is unverified |
| Isabela | Visual art, original character artwork, dialogue UI, narrative, and dialogue | Original Albert sheets and Dream/Real panel artwork are integrated; complete/final narrative approval is not established |
| Kayla | Visual art, environmental and map development | Prototype rooms exist on main; her current deliverables and branch status were not verified |
| Wayne | Visual art alongside Isabela and Kayla | Seventh member; specific assets, assigned scenes, deliverables, and implementation status are unconfirmed |

## Current development areas

| Area | Classification | Next evidence needed |
| --- | --- | --- |
| Existing laboratories and shared systems | Published prototypes/foundations | Validate affected scenes when their contracts change |
| Dream → Bedroom introduction | Accepted and published in `fad8a76`; accepted signal repair published in `eef63da` | Preserve the verified flow and test affected paths when changing it |
| Environmental descriptions beyond current examples | Assigned; additional progress unverified | Inspect Christan's actual content/interface and agree on scene ownership |
| Sanity | Assigned; no integration in inspected main | Christan's actual contract, approved inputs/outputs and event meanings |
| Environment/map expansion | Assigned; additional progress unverified | Kayla's confirmed deliverables and integration needs |
| Story event registration | One published introduction-completion flag approved and registered | Additional events require approved meanings, producers, and consumers |
| Connected room travel and chapter progression | Unresolved design/integration | Accepted room order, entry/exit behavior, and narrative boundaries |
| Save/load | Deferred outside GameState V1 | Separate requirements/design before implementation |
| Narrative proposals, final title/endings | Unresolved | Isabela/team decisions, not inference from prototypes |
| Central documentation set | Published implementation contracts linked to specialized guides | Keep local, accepted, and published status distinct when maintaining affected documents |

The central guides distinguish published implementation from proposed work.
Their presence alone does not establish new acceptance or publication.

## Integration dependencies and real constraints

- **Chapter flow:** the published Dream handoff loads the story Bedroom; room markers
  and doors still supply no travel logic. Later chapter connections need approved
  entry/travel rules and coordinated environment/narrative content.
- **Story state:** one published introduction-completion flag is registered. Unknown
  reads still return null and writes are rejected. Additional progression and
  Christan's Sanity interface need approved meanings and verified consumers.
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
3. Agree with Isabela on accepted progression/content and with Christan on the
   environmental/Sanity interfaces; approve real GameState event IDs as needed.
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
