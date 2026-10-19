# Team progress

[README](../README.md) · [Game flow](GAME_FLOW.md) ·
[Project structure](PROJECT_STRUCTURE.md) · [Development history](DEVELOPMENT_HISTORY.md) ·
[Design decisions](DESIGN_DECISIONS.md)

## Delivery objective

The immediate team objective is a coherent playable game-jam submission or chapter
built from the existing foundations. The current opening and independent rooms
do not yet meet that connected-playable objective.

**Project Lead-reported deadline:** November 9, 2026. This date is attributed to
the Project Lead and has not been independently verified against an organizer
schedule in this snapshot.

## Last-verified snapshot

**Implementation verified at published commit:** `590184baf43a43410e7f6288258d1ef080d17967` —
`feat: add session-based game state management`.

The main reference was checked against the remote and matched this baseline during
the documentation inspection. The scope is published main, its meaningful history,
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

## Verified published work

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

Assignments below come from the Project Lead. They do not prove completion or
assign authorship to every file in a shared/integrated system.

| Person | Confirmed responsibility | What can be said from this inspection |
| --- | --- | --- |
| Project Lead | Engineering coordination, Game State Management, integration oversight | GameState V1 and the shared engineering foundations above are on main; future integration needs coordination |
| Ali | Opening cinematic, Scene 1, integration toward playable Bedroom | Initial opening is on main; opening-to-room handoff is absent in the inspected runtime |
| Christan | Environmental dialogue development and Sanity System | Published reusable environmental contract is available for his content; his current branch implementation/status was not verified |
| Kayla | Environment and map development | Prototype rooms exist on main; her current deliverables and branch status were not verified |
| Isabela | Narrative/dialogue, original character artwork, dialogue UI artwork | Original Albert sheets and Dream/Real panel artwork are integrated; complete/final narrative approval is not established |
| Lawrence | Audio and sound | Opening/typewriter expose audio hooks; main contains audio placeholder files, not finished audio integration; current delivery status is unverified |

## Current development areas

| Area | Classification | Next evidence needed |
| --- | --- | --- |
| Existing laboratories and shared systems | Published prototypes/foundations | Validate affected scenes when their contracts change |
| Opening → playable Bedroom | Assigned/planned; pending implementation/integration on main | Approved handoff behavior and Ali's verified implementation |
| Environmental descriptions beyond current examples | Assigned; additional progress unverified | Inspect Christan's actual content/interface and agree on scene ownership |
| Sanity | Assigned; no integration in inspected main | Christan's actual contract, approved inputs/outputs and event meanings |
| Environment/map expansion | Assigned; additional progress unverified | Kayla's confirmed deliverables and integration needs |
| Production story event registration | Pending team decisions | Approved descriptive IDs, setting/resetting owners, and consumers |
| Connected room travel and chapter progression | Unresolved design/integration | Accepted room order, entry/exit behavior, and narrative boundaries |
| Save/load | Deferred outside GameState V1 | Separate requirements/design before implementation |
| Narrative proposals, final title/endings | Unresolved | Isabela/team decisions, not inference from prototypes |
| Central documentation set | Six central guides describing the implementation verified at `590184b`, with links to the three specialized references | Maintain affected guides when meaningful accepted changes alter implementation, responsibilities, or decisions |

The central guides describe project knowledge and continuity at the verified
implementation baseline. Their presence does not establish new gameplay or the
completion of pending integrations.

## Integration dependencies and real constraints

- **Chapter flow:** the opening emits completion but no scene loader consumes it.
  Room markers and doors supply no travel logic. A connected chapter needs an
  agreed handoff from Ali's scene work, Isabela's accepted narrative endpoint,
  suitable environment content coordinated with Kayla, and approved entry/travel rules.
- **Story state:** the registry is empty. Callers cannot safely use invented
  event names; unknown reads return null and writes are rejected. Decide meanings
  and ownership before connecting progression or Christan's Sanity implementation;
  his actual consuming interface must be verified rather than assumed.
- **Dialogue ownership:** environmental content can reuse
  [the published interaction contract](overworld_interactions.md). Future NPC
  cinematics require separate coordination with the opening/sequence owner.
- **Visibility:** panel placement has limited free space and respects camera
  limits. New text, art, camera setups, or room layouts need tests; impossible
  placement deliberately cancels instead of covering a subject.
- **Shared assets:** changing the Player, font, panel, or typewriter affects
  multiple consumers. Preserve original art and test both the opening and labs
  relevant to the change.
- **Assets/content:** Dream and waking views are placeholders, audio cues are not
  playback, and font redistribution permission is unresolved. Confirm actual
  artwork/content decisions and Lawrence's audio deliveries before integration.
  See [font permission](DESIGN_DECISIONS.md#d05--world-specific-supplied-dialogue-artwork-and-a-shared-typewriter)
  before public build distribution.

These are verified gaps, dependencies, or documented limits. No new runtime
failure was reproduced during this documentation-only inspection. Unknown
teammate progress is not labeled a confirmed technical blocker.

## Proposed next integration milestone

**Proposal:** connect the existing opening presentation to an approved playable
Bedroom entry. This is a coordination objective, not an assertion that Ali has
completed/committed the transition or authorization to implement it. Confirm owner
readiness and implementation approval first.

The unresolved contract is recorded in
[Game flow](GAME_FLOW.md#unresolved-opening-to-bedroom-contract). Proposed evidence
for treating a future implementation as integration-ready is:

- An accepted Scene 1 endpoint, with narrative and technical responsibilities
  coordinated rather than treating scene implementation as narrative approval.
- The correct agreed playable destination and approved spawn/facing.
- Deliberate movement/input lock release and control handoff, with opening
  dialogue/effect cleanup and no competing input owners.
- Correct camera initialization/framing and functional destination dialogue.
- A decision on whether shared story events are needed; any required event IDs
  are approved, registered, and written explicitly.
- Actual Godot 4.7.2 runtime verification of the handoff and subsequent exploration.
- No regression in F5 opening behavior or independent F6 laboratory entry points,
  movement, collisions, dialogue, or camera behavior.
- Review of the implementation and relevant documentation before integration
  into main; publication verified before reporting it as published.

These are proposed acceptance criteria, not completed tests. Later chapter flow
also depends on verified Christan/Kayla/Lawrence deliverables and approved narrative
and state contracts; those assignments alone establish no current readiness.

## Proposed next priorities

This is a recommended coordination order, not newly approved implementation or
a schedule. The Project Lead and responsible teammates must confirm it.

1. Review this knowledge base, especially unresolved narrative/flow and ownership
   assumptions; keep status wording tied to the inspected source.
2. Agree with Ali on the Scene 1 endpoint and opening-to-Bedroom entry contract,
   then inspect/test the actual handoff implementation before integration.
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
