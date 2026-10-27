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
