# GameState V1

`GameState` is an Autoload for story progression and Boolean event flags during
one running game. It survives scene changes. Closing and starting the game
creates a fresh session with every registered flag set to `false`.

It does not manage sanity, dialogue playback, scenes, inventory, quests, or
save files. The published Bedroom introduction is the first story flag producer;
environmental repeat state still belongs to each loaded target. The accepted local
Scene 02 controller additionally records three approved preparation flags.

## Register an event

Add each approved, descriptive event name once to `REGISTERED_FLAGS` in
`scripts/game_state.gd`. This is the only production registry. Names are case-sensitive;
flags are never created by reads or writes. Restart the game after editing the
registry. Do not change `_flags` directly.

The name `approved_event_id` below is a documentation placeholder, not a
registered story event. Replace it with an approved name from the registry.

```gdscript
var accepted: bool = GameState.set_flag("approved_event_id", true)
var value: Variant = GameState.get_flag("approved_event_id")
if value == null:
	return # Unknown name: fix the caller or obtain approval to register it.
if value:
	print("The registered event is true.")
GameState.clear_flag("approved_event_id")
```

## Bedroom introduction completion

The `bedroom_intro_completed` flag, published in `fad8a76`, means the
whole Bedroom introduction finished, including the selected phone branch and
the final reflection. `scripts/bedroom_intro.gd` writes it only after the last
reflection is dismissed, immediately before returning exploration control.

Loading Bedroom, starting dialogue, opening/closing the phone, and selecting a
response do not set it. Later story entry reads it and skips the introduction
when true. The branch remains local to the sequence: there are no response flags,
relationship values or saved consequences. The local Sanity integration now
adds +1 for Option 3 only through the story controller; Options 1/2 stay neutral.
The introduction still records only whole-introduction completion; Scene 02
preparation has its own separate flags below.

The ordinary Bedroom F6 laboratory does not read or write this flag. The dedicated
`scenes/tests/bedroom_intro_test.tscn` entry reruns the same introduction without
reading or changing story completion. Restarting the application creates a fresh
session. No New Game UI exists yet; a future in-process New Game action should
coordinate both session services rather than bypassing their public APIs.

## Scene 02 preparation — accepted locally, publication pending

The three Boolean flags are `bedroom_schedule_checked`, `bedroom_id_checked`, and
`bedroom_medal_checked`. They mean the notebook, Student ID, and graduation medal
respectively finished successful inspection. `scripts/bedroom_scene02.gd` writes
only the matching flag after `interaction_finished(target, true)`; starting,
partial reading, cancellation, or failed framing does not complete a requirement.

All three are required in any order before the Bedroom door offers departure.
Repeat inspection stays available without duplicating progress. The controller
also reads current values for same-session re-entry and Return to Bedroom from
the temporary endpoint. Neither action resets flags or Sanity. There is no extra
door-completion flag, inventory, lateness consequence, or checkpoint API.

Like introduction completion, these flags survive scene changes within the running
application and default to false in a fresh session. `reset_session()` clears all
four registered flags; future reset/restoration coordination still has to account
for the independent SanityState service and room-local state. The shared
environmental controller and Object Focus presenter do not write these flags.

## API and validation

| Operation | Result |
| --- | --- |
| `set_flag(name, value)` | `true` for an accepted Boolean assignment, including an unchanged value; otherwise `false`. |
| `get_flag(name)` | A Boolean for a registered name; otherwise `null`. |
| `clear_flag(name)` | Sets a registered flag to `false`; returns whether accepted. |
| `reset_session()` | Resets all flags to `false`; returns nothing. |
| `flag_changed(name, value)` | Emitted after an actual value change. |

Names must be `String` values. `StringName`, numbers, `null`, and other types are
rejected with a warning. Values must be actual Booleans: `0`, `1`, and `"true"`
are not converted. Unknown reads warn and return `null`; invalid or unknown
writes warn, return `false`, and leave every flag unchanged. Invalid reads also
return `null`. Repeated assignments and clearing an already-false flag do not
emit a signal. Flags can be set both ways; permanent milestones are a caller
convention rather than a restriction imposed by GameState.

## React to changes

```gdscript
func _ready() -> void:
	GameState.flag_changed.connect(_on_flag_changed)

func _on_flag_changed(flag_name: String, value: bool) -> void:
	print(flag_name, ": ", value)
```

Connect scene-local listeners when needed and read the current value as well:
signals describe changes, not the entire session history. On session reset,
all values become false before notifications are emitted. Each flag that was
true emits one `(name, false)` notification, in registry order. An already-false
session emits none. Avoid changing flags from reset notifications unless that
behavior is intentional.

For a fresh playthrough within the same application, a future New Game coordinator
must reset Boolean flags with `GameState.reset_session()` and deterioration with
`SanityState.reset_session()`. Neither service resets automatically on scene change
or conversation replay. A future checkpoint/retry coordinator must respect both
services and relevant room-local state under the approved restoration rules;
GameState remains Boolean-only. No complete New Game or checkpoint/retry
coordinator exists yet.

Prince currently oversees gameplay mechanics and Sanity. `SanityState` is a
separate session service; GameState has no dependency on it and stores no Sanity
score. Approved consumers may read registered flags or subscribe to this signal.

## Local setup and review

Project Settings > Globals > Autoload must contain `GameState`, pointing to
`res://scripts/game_state.gd`, with the singleton enabled. Godot 4.7.2 saves this
registration as `GameState="*uid://c647p0ta1wljq"`, using the identity in
`scripts/game_state.gd.uid`. Keep that UID file with the script.

Run the normal opening with F6 on `scenes/Dream.tscn`, or F5. Check Remote >
GameState: `_flags` should contain `bedroom_intro_completed = false` before
the introduction finishes, and `true` after its final reflection.
Run the Bedroom or Garden laboratory with F6 to check existing gameplay.
Registered-flag behavior is validated using test-only identifiers in an isolated
fixture; no test events or debug scene are added to the gameplay flow.
