# Environmental interaction prototype

This system handles objects in the playable world. The cinematic opening keeps
its own sequence and input handler. The story Bedroom introduction reuses the
dialogue presentation, not this proximity-based conversation lifecycle.

## Scene setup

1. Add one Node2D with `scripts/overworld_interaction.gd` to the playable scene.
2. Set `player_path` to the existing Player. The default is `../Player`.
3. Instance `scenes/UI/overworld_overlay.tscn` below the controller, named
   `DialogueLayer`. It reuses the existing panel, typewriter, font and both skins.
4. Add a Node2D with `scripts/overworld_interactable.gd` below each object.
   Place it at the desired proximity center. It must share the Player's scene.
5. Configure its radius, trigger, repeat mode, presentation, lines and speakers.
   A missing speaker entry leaves the name blank.
6. Set `visual_path` and `visual_bounds` around the complete visible object.
   Bounds are local to the visual node, not the interaction center. Include the
   full envelope of idle animation. The default visual path is the parent.
7. Optionally set `focus_texture` to a replaceable item illustration. With no texture,
   the same overlay uses ordinary dialogue without an illustration or dimmer.

The controller expects the current Player's `AnimatedSprite2D` with its
`albert_animation.gd` helper. `show_idle()` keeps the last facing direction.
Placement includes every frame of the `idle_` animations. The controller pauses
and restores physics processing. Keep one controller per playable scene.

## Activation and repeats

| Trigger | Keypress repeat | Re-entry repeat | One-time |
| --- | --- | --- | --- |
| Manual | E/Space each time, including while staying nearby | E/Space; leave and return before the next activation | E/Space; unavailable after completion |
| Automatic | First entry starts; later activations require a fresh E/Space | Entry starts; leave and return to repeat | First entry starts; unavailable after completion |

One-time state belongs to the loaded object during this prototype run. Restarting
the scene resets it. Cross-scene persistence and save data are outside this system.
Failed placement does not count as completion; leave and return before retrying.

The nearest available object is selected, with node path breaking distance ties.
That selection stays until it becomes unavailable, preventing prompt flicker.
Only one conversation is active. Another eligible object can be selected after
closing; an automatic object may then start without a keypress.

E/Space reveals typing, advances a revealed line, and closes the final line.
Entry-frame input, held keys, echoes and same-frame duplicate presses are ignored.
Movement resumes when dialogue closes; another interaction waits for camera
restoration. `interaction_started` and `interaction_finished(target, completed)`
are available for later scene-local hooks.

## Scripted-story suspension

`set_suspended(value: bool) -> bool` temporarily suspends environmental detection,
prompts, placement updates, and input without changing target repeat state or
Player physics. It returns `false` if asked to suspend while a conversation is
open, closing, or still being placed. Finish that interaction before transferring
ownership. A repeated assignment to the current suspension state is accepted.

The Bedroom introduction saves the prior suspension state, suspends this
controller, and owns its separate movement lock. On completion it restores the
prior state. Resuming clears the selection and waits for E/Space and left mouse
release, then applies a frame guard before activation. This prevents the final story
dismissal from also activating the notebook or card.

Keep one movement/input owner during a scripted sequence. Disabling Player physics
alone does not suspend environmental activation. The ordinary F6 laboratories
remain unsuspended unless another controller explicitly acquires this contract.

## Placement

The prompt stays inside the viewport and avoids the configured object bounds.
The dialogue protects both Albert's visible Idle sprite and the object, including
the panel's decorative artwork. Top/bottom positions are evaluated in screen
space. If needed, the camera pans by the smallest feasible amount over 0.25 seconds
and returns afterward, respecting limits. Existing zoom and offsets are retained.

Temporary pans support the current unrotated cameras with drag disabled. With
other camera configurations, an already-clear panel position can still work.
An impossible layout cancels with a warning and restores control rather than
covering a subject. Large objects, new player art, viewport sizes and different
camera setups need their own placement review.

## Object Focus

The Scene 02 extension was automatically validated, manually accepted and
published in `b40ab47`. The shared overlay now instances
`scenes/UI/object_focus_overlay.tscn` behind DialoguePanel. Its visual-only
`scripts/object_focus_presenter.gd` reads the active target's optional
`focus_texture: Texture2D` when an interaction starts, but shows only when the
actual dialogue panel becomes visible. This avoids artwork appearing during
camera placement. The panel's hide immediately hides the illustration/dimmer;
finish and target removal clear its references. The controller also cancels
safely if the active target leaves the scene and restores its movement/camera state.

The presenter uses nontransparent image bounds for display without changing the
source artwork. It preserves aspect ratio and nearest filtering, using integer
enlargement where it fits. The artwork's center X is half the entire viewport
width; its vertical slot changes with top/bottom dialogue placement and reserves
adaptive Sanity HUD clearance. It does not shift into a middle-left column.
If the texture is missing, empty, fully transparent, or there is no usable space,
ordinary dialogue remains available without Object Focus artwork.

Input, typewriter progression, movement locks, camera placement, and completion
remain with the environmental controller. The presenter writes no GameState or
Sanity values and does not implement inventory. Scene 02 separately listens for
successful required completions; repeat inspection does not duplicate progress.

## Current examples

- `scenes/prototypes/garden_camera_lab.tscn`: Lily, automatic/re-entry, Dream skin,
  radius 84. `garden_lily_interaction.gd` is a compatibility adapter preserving
  the existing script reference. Garden scenery and idle animation are retained.
- `scenes/prototypes/camera_lab.tscn`: Bedroom, fixed camera. The notebook on the
  desk is manual/keypress, radius 92, Reality skin. The Student ID on the lower-left
  dresser is manual/keypress, radius 76; the medal is manual/keypress, radius 72.
  All three use Object Focus and replaceable placeholder illustrations. The story
  wrapper adds objectives/markers and a separate door decision; the laboratory
  itself does not write preparation flags. The descriptions remain provisional.

Run either laboratory with F6, not the project's main opening. In the Bedroom,
approach the desk from its right/front side or the dresser from above. Follow the
E/Space prompt. Complete each Bedroom object twice without leaving; all remain
available. For the story objectives and door gate, run F5 or the story wrapper,
not the exploration-only laboratory. In the Garden, approach the large central Lily, finish its three lines, remain nearby,
then leave its radius and return. Approach from several sides to compare panel
placement and the temporary pan. Neither laboratory implements room transitions.

The Bedroom drawings are temporary native geometry. Solid furniture uses scene
collision shapes; the rug and small surface decorations do not block movement.
The room remains 512 by 384 with a fixed 2.5x camera and the closed right doorway.
