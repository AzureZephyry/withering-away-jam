# Environmental interaction prototype

This system handles objects in the playable world. The cinematic opening keeps
its own sequence and input handler. Nothing here connects the opening to a room.

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

## Current examples

- `scenes/prototypes/garden_camera_lab.tscn`: Lily, automatic/re-entry, Dream skin,
  radius 84. `garden_lily_interaction.gd` is a compatibility adapter preserving
  the existing script reference. Garden scenery and idle animation are retained.
- `scenes/prototypes/camera_lab.tscn`: Bedroom, fixed camera. The notebook on the
  desk is manual/keypress, radius 92, Real skin. The card on the lower-left dresser
  is manual/one-time, radius 76, Real skin. All new text is placeholder description.

Run either laboratory with F6, not the project's main opening. In the Bedroom,
approach the desk from its right/front side or the dresser from above. Follow the
E/Space prompt. Complete the notebook twice without leaving; complete the card,
then leave and return to confirm it stays unavailable until the next run. In the
Garden, approach the large central Lily, finish its three lines, remain nearby,
then leave its radius and return. Approach from several sides to compare panel
placement and the temporary pan. Neither laboratory implements room transitions.

The Bedroom drawings are temporary native geometry. Solid furniture uses scene
collision shapes; the rug and small surface decorations do not block movement.
The room remains 512 by 384 with a fixed 2.5x camera and the closed right doorway.
