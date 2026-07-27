---
name: godot
version: 1.3.0
description: Develop, test, and build Godot 4.x desktop games. Includes GdUnit4 for GDScript unit tests, headless test running, desktop exports (Windows/Mac/Linux), and CI pipelines.
---

# Godot Skill

Develop, test, and build Godot 4.x games.

> **Project Alpha notes** (see [CLAUDE.md](../../../CLAUDE.md)):
> - Engine is **Godot 4.7.1**. gdUnit4's latest *stable* release (v6.1.3) supports
>   only 4.5–4.6.3; 4.7 support currently lives on the unreleased master/v6.2
>   branch. **Do not install gdUnit4 until v6.2 ships** unless you deliberately
>   accept pinning to a branch.
> - Target is **desktop only** (Windows/Mac/Linux). Ignore web-export advice.
> - Primary language is **GDScript**. Do not add C# scripts without asking.

## Quick Reference

```bash
# GdUnit4 - Unit testing framework (GDScript, runs inside Godot)
godot --headless --path . -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd --run-tests

# Validate the project imports cleanly (no editor window)
godot --headless --path . --quit

# Export a desktop build (requires a matching preset in export_presets.cfg)
godot --headless --export-release "Windows Desktop" ./build/game.exe
```

---

## Testing Overview

GdUnit4 is the testing framework for this project: GDScript tests that run
inside Godot, headless, driven from the CLI. Because the rules engine is
designed to be UI-agnostic, most tests should exercise game state directly
rather than driving scenes.

---

## GdUnit4 (GDScript Tests)

GdUnit4 runs tests written in GDScript directly inside Godot.

### Project Structure

```
project/
├── addons/gdUnit4/          # GdUnit4 addon
├── test/                    # Test directory
│   ├── game_test.gd
│   └── player_test.gd
└── scripts/
    └── game.gd
```

### Setup

```bash
# Install GdUnit4
git clone --depth 1 https://github.com/MikeSchulze/gdUnit4.git addons/gdUnit4

# Enable plugin in Project Settings → Plugins
```

### Basic Unit Test

```gdscript
# test/game_test.gd
extends GdUnitTestSuite

var game: Node

func before_test() -> void:
    game = auto_free(load("res://scripts/game.gd").new())

func test_initial_state() -> void:
    assert_that(game.is_game_active()).is_true()
    assert_that(game.get_current_player()).is_equal("X")

func test_make_move() -> void:
    var success := game.make_move(4)
    assert_that(success).is_true()
    assert_that(game.get_board_state()[4]).is_equal("X")
```

### Scene Test with Input Simulation

```gdscript
# test/game_scene_test.gd
extends GdUnitTestSuite

var runner: GdUnitSceneRunner

func before_test() -> void:
    runner = scene_runner("res://scenes/main.tscn")

func after_test() -> void:
    runner.free()

func test_click_cell() -> void:
    await runner.await_idle_frame()

    var cell = runner.find_child("Cell4")
    runner.set_mouse_position(cell.global_position + cell.size / 2)
    runner.simulate_mouse_button_pressed(MOUSE_BUTTON_LEFT)
    await runner.await_input_processed()

    var game = runner.scene()
    assert_that(game.get_board_state()[4]).is_equal("X")

func test_keyboard_restart() -> void:
    runner.simulate_key_pressed(KEY_R)
    await runner.await_input_processed()
    assert_that(runner.scene().is_game_active()).is_true()
```

### Running GdUnit4 Tests

```bash
# All tests
godot --headless --path . -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd --run-tests

# Specific test file
godot --headless --path . -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd \
  --run-tests --add res://test/my_test.gd

# Generate reports for CI
godot --headless --path . -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd \
  --run-tests --report-directory ./reports
```

### GdUnit4 Assertions

```gdscript
# Values
assert_that(value).is_equal(expected)
assert_that(value).is_not_null()
assert_that(condition).is_true()

# Numbers
assert_that(number).is_greater(5)
assert_that(number).is_between(1, 100)

# Strings
assert_that(text).contains("expected")
assert_that(text).starts_with("prefix")

# Arrays
assert_that(array).contains(element)
assert_that(array).has_size(5)

# Signals
await assert_signal(node).is_emitted("signal_name")
```

### Scene Runner Input API

```gdscript
# Mouse
runner.set_mouse_position(Vector2(100, 100))
runner.simulate_mouse_button_pressed(MOUSE_BUTTON_LEFT)
runner.simulate_mouse_button_released(MOUSE_BUTTON_LEFT)

# Keyboard
runner.simulate_key_pressed(KEY_SPACE)
runner.simulate_key_pressed(KEY_S, false, true)  # Ctrl+S

# Input actions
runner.simulate_action_pressed("jump")
runner.simulate_action_released("jump")

# Waiting
await runner.await_input_processed()
await runner.await_idle_frame()
await runner.await_signal("game_over", [], 5000)
```

---

## Building

Project Alpha ships to **desktop only** (Windows/Mac/Linux). There is no web
build, so no web-host deployment step.

### Desktop Export

```bash
# Each name must match a preset in export_presets.cfg
godot --headless --export-release "Windows Desktop" ./build/windows/game.exe
godot --headless --export-release "Linux/X11"       ./build/linux/game.x86_64
godot --headless --export-release "macOS"           ./build/macos/game.zip
```

### Export Preset (export_presets.cfg)

```ini
[preset.0]
name="Windows Desktop"
platform="Windows Desktop"
runnable=true
export_path="build/windows/game.exe"
```

Note: `export_presets.cfg` is version-controlled in this project — see the
comment in `.gitignore` about keeping signing secrets out of it.

---

## CI/CD

### GitHub Actions Example

```yaml
- name: Setup Godot
  uses: chickensoft-games/setup-godot@v2
  with:
    version: 4.7.1
    use-dotnet: false  # this project uses the standard (non-.NET) editor build
    include-templates: true

- name: Run GdUnit4 Tests
  run: |
    godot --headless --path . \
      -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd \
      --run-tests --report-directory ./reports

- name: Upload Results
  uses: actions/upload-artifact@v4
  if: always()
  with:
    name: test-results
    path: reports/
```

---

## References

- `references/gdunit4-quickstart.md` - GdUnit4 setup
- `references/scene-runner.md` - Input simulation API
- `references/assertions.md` - Assertion methods
- `references/deployment.md` - Deployment guide
- `references/ci-integration.md` - CI/CD setup
