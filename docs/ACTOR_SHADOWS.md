# Actor shadows

Reusable ground shadows for animated and stationary characters.

[ActorShadow2D](../scenes/components/actor_shadow_2d.tscn) gives a character a
subtle feet contact and a flattened silhouette of its current animation frame.
The shared [Player scene](../scenes/player.tscn) includes it. It binds in the
School Exterior and remains hidden and inactive in other current environments.
It owns no movement, collisions, dialogue, clock or gameplay state.

## Rendering and lighting

[actor_shadow_2d.gd](../scripts/actor_shadow_2d.gd) reads the **effective** direction,
length ratio and opacity from [school_sun_shadows.gd](../scripts/school_sun_shadows.gd).
It therefore follows the existing sunrise/elevation model and the same interrupted
0.6-second story-time blends. There is no second phase schedule. Morning projects
west/down, noon is short, afternoon/sunset east/down; solar coverage fades at the
horizon. Night keeps only contact. Dawn returns gradually after sunrise.

The component moves its two drawing proxies into the School's existing offscreen
mask, using its map transform. [actor_shadow_mask.gdshader](../shaders/actor_shadow_mask.gdshader)
adds only red (solar) and green (contact) coverage. It leaves the receiver's blue
ground channel and alpha static-replacement channel intact. Existing map/underlay
materials apply the mask, so roofs/faces stay excluded, foregrounds retain their
depth/fade behavior, and Albert and screen UI receive no shadow overlay.

The cast uses the current `AnimatedSprite2D` frame texture, offset, centering,
scale and flips. `Sprite2D` sources also support regions and sprite-sheet frames.
Textures and SpriteFrames are reused without editing or copying their image data.
A small five-sample alpha filter softens the silhouette on the native map-pixel
grid. Each instance has independent material parameters.

## Attaching future characters

1. Instance `scenes/components/actor_shadow_2d.tscn` beneath the actor.
2. Set **Visual Source Path**, relative to the component, to an AnimatedSprite2D
   or Sprite2D. No particular script, animation name or artwork filename is required.
3. Set **Feet Anchor Path** to a Node2D at ground level, plus **Feet Offset** in
   that anchor's local coordinates. Defaults target the sibling AnimatedSprite2D
   and actor origin, matching Albert's established feet.
4. Tune `height_scale` (default 0.75), `ground_depth` (0.12), `cast_strength`
   and `contact_strength` (both 0.8), and `contact_size` (18 × 6 world units).
   Height is derived from the current visual relative to the feet; a badly placed
   anchor will detach the shadow. Keep character visuals upright.

Initial binding is deferred until the scene is ready. The first node in group
`actor_shadow_receiver` is used. If there are multiple environments, explicitly
call `bind_receiver(environment)` to choose one. A new environment adapter must
provide `attach_actor_shadow(visual)`, `request_actor_shadow_redraw()`,
`get_actor_shadow_map()`, and effective `sun_direction`, `length_ratio`,
`sun_opacity`, `prototype_enabled` properties. It must composite the same channels
through a suitable ground stencil. Register the group only after it is ready.

On removal the proxy returns to its actor; re-entry binds again. Freeing an actor
also frees its proxy. Replacing a receiver while retaining actors requires an
explicit rebind. Missing/freed visuals disable drawing safely.

## Cost, testing and limits

There is one existing map-sized viewport, **not one viewport per actor**. Each
actor contributes a sprite and a small contact quad. Animation resources are
shared; transforms/materials are independent. Small projection changes are
thresholded, unchanged poses avoid redraw requests, and no CPU alpha-image work
is performed by the component. Moving/animating actors necessarily redraw the
shared mask more often than static environmental geometry alone.

Short moving/animating-group samples in the full School on Intel UHD 620 / Vulkan
gave the following results after two seconds of warm-up, measured for three seconds:

| Actors | Observed FPS | Mean total draw calls |
| --- | ---: | ---: |
| 1 | 59.8 | 160 |
| 4 | 60.3 | 165 |
| 20 | 60.0 | 194 |

These are capped, short local observations, not a guaranteed frame budget or
cross-hardware benchmark. CPU/GPU attribution was not measured reliably. The test
actors reuse existing artwork and exist only during the probe.

Run [actor_shadow_tests.tscn](../scenes/tests/actor_shadow_tests.tscn) with F6 for
focused probes and runtime-only copies of the existing character. Captures and
results default to `user://actor_shadow_tests`. The suite quits when finished.
It covers phases, override replacement, eight-direction movement, frame/flip
sync, feet anchoring, receiver preservation, multiple actors, and removal/re-entry.
The generic editor linter reports the unassigned Cast Sprite2D texture, repeated
for scenes instancing Player: it is intentionally supplied from the source's
current frame at runtime, rather than a missing asset.

This is a bounded ground-plane projection, not volumetric or multi-light shadowing.
It stops at existing receiver stencils rather than climbing walls. There are no
lamp/headlight casts, mutual actor occlusion, or height-aware terrain. Contact uses
the existing restrained environmental opacity at night. At the School's fractional
1.1475× scale, the established map-pixel grid still has uneven physical pixel widths.
Visual acceptance and longer hardware profiling remain separate from test passes.
