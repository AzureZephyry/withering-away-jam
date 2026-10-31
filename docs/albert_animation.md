# Albert's directional animations

The shared `scenes/player.tscn` uses Isabela's original PNGs in
`assets/characters/albert/`. Keep these source images unchanged.

## Frame layout

The idle sheet is 94 by 122 pixels; walking is 94 by 123. Each has four
columns and five rows, with a 24-pixel pitch. Do not divide the whole image
evenly into a four-by-five grid.

`albert_frames.tres` defines 22-by-24 AtlasTexture regions. For zero-based
column `c` and row `r`, idle starts at `(24*c, 24*r)` and walking at
`(24*c, 24*r + 1)`. That one-pixel difference aligns their feet. All source
character pixels fit inside these regions; no copied or redrawn PNG is needed.

Rows are down, down-right, right, up-right, and up. Each animation plays its
four frames left to right. Idle loops at 3 fps; walking loops at 8 fps.
These playback speeds can be tuned after playtesting.

## Player integration

`scripts/albert_animation.gd` chooses one of eight facing sectors and mirrors
the three left-facing directions on the sprite only. Stopping keeps the last
facing direction. Turning within idle or walking keeps the animation phase.
Pressing into an obstacle faces that direction but idles when fully blocked.

The movement controller passes input and actual displacement to `update_motion()`
after moving. Its speed, input, and collision calculations remain unchanged.
Interactions call `show_idle()` while player physics is paused.

The sprite uses nearest filtering, a uniform 2x visual scale, and offset
`(0, -9)` on a centered 22-by-24 frame. The usual feet baseline lands at the
player origin. The up-right walking gait includes a one-source-pixel foot lift;
this is preserved from the artwork. The collision remains 24 by 40 at `(0, -20)`.

Dialogue placement merges the visible bounds of every idle frame and applies
the sprite's scale and flip, so breathing and facing do not move Albert under
the panel. The Bedroom, Garden, School, and original game share this player.

## Replaced placeholder files

The Player no longer uses the 2x Farmer idle/walk sheets or the embedded
placeholder animations. Those two sheets and their import files were removed
after checking references. The unused root-level `player.gd` platformer controller
and its UID were also removed; `scripts/player_movement.gd` is the active controller.
The remaining unused sample-character library is removed after path/UID
dependency checks and verified external backup.
Albert's PNGs and frames remain together, behavior stays in `scripts/`, and the
shared Player stays in `scenes/`. No active character resource was moved or changed.

## NPC-001 animation reuse

`scenes/characters/npc_001.tscn` reuses the directional animation script and
ActorShadow2D without changing Albert. Its sheets use full 24-by-24 cells,
2x scale and offset `(0, -12)` so the standing soles meet the actor origin.
Idle loops at 3 fps and walking at 8 fps. The externally driven
`scripts/npc_character.gd` exposes `set_move_direction(Vector2)` and
`face_direction(Vector2)`; zero movement retains the last facing direction.
There are no player-input bindings or dialogue.

One instance starts beside the west courtyard path in the School Exterior
playable host, also inherited by its story wrapper. Existing foreground depth
sorting applies, but automatic foreground transparency still tracks Albert only.
NPC-001's animation, roaming and maintenance behavior are approved.

### Courtyard waypoint roaming

The School instance adds `scripts/npc_waypoint_roaming.gd` as a child controller.
It sends directions to the existing character; movement and animation stay in
their original controllers. Five `Marker2D` children of `JanitorRoute` define
the ordered loop. The School instance walks at 55 world units/second, stops
within 2 units, idles for 2–4 seconds, and retains its last facing direction.

After 0.35 seconds without forward progress it idles in a blocked state. Every
1.25 seconds it checks the next step with the actual character physics shape;
movement resumes when clear. It does not teleport, disable collision or find
alternate paths. A permanent obstruction therefore leaves it waiting safely.
The route and pause timings are editable in the School scene.
Visible sweeping and dialogue remain unimplemented.

### Contextual maintenance stops

The southeast walkway corner and northwest courtyard edge keep their original
route coordinates and add `scripts/npc_maintenance_stop.gd`. At these markers,
the roaming controller faces the configured work direction, enters WORKING for
6–10 seconds, then RESTING for 2–4 seconds before advancing. Other route stops
retain their normal pauses. Neither work nor rest moves the character.

The character exposes `begin_activity(direction, animation_name)` and
`end_activity()`. A maintenance marker can name a future human-authored work
animation. An empty or unavailable name uses existing directional Idle without
a missing-animation warning. No broom or sweeping artwork has been integrated;
WORKING currently represents a stationary maintenance pause, not visible sweeping.
Wayne's existing trash-bin sprite is environmental artwork, not a broom or work
animation. Visible sweeping requires a compatible human-authored animation and,
if needed, a broom prop.

## Mang Arnel character integration

Isabela's original guard sheets remain unchanged under
`assets/characters/mang_arnel/`. Idle is 94 by 122 pixels and Walk is 94 by 123.
Their SpriteFrames use Albert's 22-by-24 regions at 24-pixel pitch: Idle starts
at `(24*c, 24*r)` and Walk at `(24*c, 24*r + 1)`. Rows are down, down-right,
right, up-right and up; left directions mirror. All 40 frames are retained.
Idle loops at 3 fps and Walk at 8 fps. Partial source alpha is preserved.

`scenes/characters/mang_arnel.tscn` reuses `npc_character.gd`,
`albert_animation.gd` and ActorShadow2D. The sprite is 2x with offset `(0, -9)`
and a 14-by-10 feet collider. One stationary, south-facing guard stands just
inside the south entrance north of the gatehouse at `(605.3063, 1396.5074)`, outside
the pedestrian opening. There is no roaming or maintenance controller.

The child `Interaction` reuses OverworldInteractable with a 64-unit manual
radius. Its standalone scene leaves dialogue empty; the School host supplies the
first-time Scene 03 conversation through `school_guard_interaction.tscn`.
See [Environmental interactions](overworld_interactions.md) for choices,
completion state and input. No Sanity consequences are added. Foreground sorting
applies; automatic foreground fading still follows Albert only.
The character and Scene 03 dialogue integration are manually accepted.
