# Project Alpha

Godot 4.7 2D desktop game (GDScript). Turn-based party RPG with an additive
card layer — see [docs/design/gdd.md](docs/design/gdd.md).

## Current state

Pre-alpha. The battle screen exists as a **visual mock-up only** — no battle
logic is wired up yet.

- `scenes/BattleScene.tscn` — party of three (placeholder rectangles) on the
  left, three enemies on the right, over a 480×270 pixel-art background.
- `shaders/` — a library of runtime silhouette effects. The art direction under
  evaluation is flat white silhouettes recoloured entirely in-engine, which is
  how a two-person team with no dedicated artist expects to ship a roster. See
  [docs/tech/vfx-catalog.md](docs/tech/vfx-catalog.md).
- `scenes/Prototype2D.tscn` — older logic-node prototype, no visuals.

Roadmap and build order: [docs/design/build-plan.md](docs/design/build-plan.md).

## Getting started

1. Open this folder in the Godot 4.7 editor (standard build — **not** Mono/.NET).
2. Optional: point `Editor → Editor Settings → Text Editor → External` at VS Code,
   then install the recommended extensions (see `.vscode/extensions.json`).
3. Open `scenes/BattleScene.tscn` and press **F6** to run just that scene.

The project renders at a 480×270 base resolution scaled up with integer-only
stretch. Those settings are load-bearing for pixel art — see
[docs/design/gdd.md](docs/design/gdd.md#battle-scene-presentation) before
changing anything under Display or Rendering.

## Headless checks

Compiles shaders and rebuilds import caches; prints `SHADER ERROR:` on failure:

```bash
godot --headless --path . --import
```

Instantiates a scene for a few frames to surface missing resources:

```bash
godot --headless --path . res://scenes/BattleScene.tscn --quit-after 5
```

## License

MIT — see [LICENSE](LICENSE).
