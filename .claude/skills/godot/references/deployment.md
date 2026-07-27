# Godot Desktop Build Guide

> **Scope:** Project Alpha ships to **desktop only** (Windows/Mac/Linux),
> single-player, PC. The upstream version of this document covered web
> (HTML5/WASM), Vercel, GitHub Pages, itch.io, Netlify, and mobile exports —
> all removed as inapplicable. If the target platforms ever change, see
> [Godot's export docs](https://docs.godotengine.org/en/stable/tutorials/export/index.html).

## Prerequisites

Export templates must match the editor version **and** build flavor. This
project uses the **standard** build of Godot 4.7.1, so you need the standard
export templates, not the Mono/.NET ones.

```bash
# Confirm version and flavor before exporting
godot --version

# Install templates from the editor:
#   Editor → Manage Export Templates → Download and Install
```

## Export Presets

Exports are driven by named presets in `export_presets.cfg`. The name passed to
`--export-release` must match the preset's `name` exactly.

```ini
[preset.0]
name="Windows Desktop"
platform="Windows Desktop"
runnable=true
export_path="build/windows/game.exe"
```

`export_presets.cfg` is version-controlled in this project — see the comment in
`.gitignore`. Keep signing keys, keystore passwords, and script encryption keys
out of it.

## Command Line Export

```bash
# Release builds
godot --headless --export-release "Windows Desktop" ./build/windows/game.exe
godot --headless --export-release "Linux/X11"       ./build/linux/game.x86_64
godot --headless --export-release "macOS"           ./build/macos/game.zip

# Debug build (larger, includes the remote debugger)
godot --headless --export-debug "Windows Desktop" ./build/windows/game_debug.exe
```

Note: exporting for a platform generally requires that platform's templates to
be installed; cross-compiling from Windows to macOS also has code-signing
caveats if you intend to distribute.

## Troubleshooting

### Export templates not found

Version mismatch is the usual cause — templates are per-version *and* per-flavor
(standard vs Mono/.NET). Re-download templates after every engine upgrade.

### Large build size

1. Enable texture compression in export settings
2. Exclude unused resources via the preset's export filters
3. Use PCK compression

### Export succeeds but the binary won't launch

Check that `run/main_scene` in `project.godot` resolves — a stale `uid://`
reference to a deleted scene fails at runtime, not at export time.
