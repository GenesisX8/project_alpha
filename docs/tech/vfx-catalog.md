# VFX Catalog — silhouette shaders

Status: **experimental.** Everything here exists to evaluate the flat-silhouette
art direction (see [gdd.md](../design/gdd.md#battle-scene-presentation)). Nothing
is committed to the shipping game yet. Live demo: `scenes/BattleScene.tscn`,
node `EffectDemoStrip`.

## What is currently on screen

`BattleScene.tscn` was cut back to a clean six-actor mock-up. Only three
shaders are placed:

| Enemy | Shader |
|---|---|
| Wolf | `datamosh` |
| Wraith | `materialise` |
| Scorpion | `wave_warp` |

The other twelve are **not** in the scene — the earlier demo strip of loose
idols and the `ground_pool` / `reflection` flourishes were removed to keep the
mock-up readable. Every file is retained and compiles.

To try any of them: select an `AnimatedSprite2D`, drag the `.gdshader` onto its
**Material** slot (creating a new `ShaderMaterial`), then tune it under
**Shader Parameters**. Restoring the full demo strip is a `git` history lookup
away — see the commit that introduced this catalogue.

Two are known-weak and would be dropped first: **`phase_bands`** (visually
redundant with `hologram` — see the stripe-family note below) and **`mosaic`**
(block-snapping is too subtle to read on a 52px sprite, and it overlaps
conceptually with `datamosh`).

## The core idea

We have no dedicated artist. The bet is that **AI generation only ever has to
produce a shape**, and everything else — colour, state, mood, damage feedback —
is decided at runtime in the engine.

That bet rests on one technical fact:

> `modulate` and shader tinting are **multiplicative**. Black × anything = black.
> **White × anything = anything.**

So source sprites are authored (or converted) to **pure white on transparent**.
White can still produce black, so nothing is given up. From one white silhouette
you get faction colours, status tints, hit flashes, death animations, boss
recolours and enemy-family variants with no additional art.

## Authoring rules the shaders depend on

Break these and effects fail in ways that look like engine bugs.

| Rule | Why |
|---|---|
| Silhouettes are **pure white**, `#FFFFFF` | Anything darker cannot be tinted upward |
| **Binary alpha only** — 0 or 255, no anti-aliased fringe | Partial alpha breaks the dither and threshold effects |
| **64×64 uniform cells**, laid out horizontally | `AtlasTexture` regions assume it |
| **≥6px empty padding** on every side of the art inside its cell | Several shaders sample *outside* the pixel; padding is what stops them reading the neighbouring animation frame |
| **Feet on a fixed row in every frame** | Actors are positioned by their feet; drift shows as bobbing |

The padding rule is the sharp edge. `outline`, `contour_bands`, `datamosh`,
`echo_trail` and `wave_warp` all sample beyond the current texel. Each file
documents its own maximum reach in an `ATLAS WARNING` comment.

Black source art can be converted to white losslessly (walk the pixels, force
RGB to white where alpha ≠ 0). The generator does not need to change.

## The catalog

All files live in [`shaders/`](../../shaders/). Every parameter is live-editable:
select the node → **Material → Shader Parameters** → drag while the game runs.

### Structural — change what the shape reads as

| Shader | Effect | Key params |
|---|---|---|
| `outline.gdshader` | Solid body + 1px rim. Setting `body_color` alpha to 0 turns it into a hollow wireframe — one shader, two looks. | `body_color`, `outline_color`, `width` |
| `contour_bands.gdshader` | Concentric colour rings measured inward from the edge. **The only effect here that adds real information** — thin limbs stay rim-coloured, thick masses reveal a core, so the body reads as having volume. | 4 band colours, `band_px` |
| `gradient_fill.gdshader` | Vertical ramp quantised into `bands` steps so it stays posterised. | `top_color`, `bottom_color`, `bands` |
| `plasma_flow.gdshader` | Scrolling value noise through a 3-stop ramp. Varies on both axes, so it does not read as stripes. | ramp colours, `noise_scale`, `speed`, `levels` |

### Transparency — all dither-based, never partial alpha

| Shader | Effect | Key params |
|---|---|---|
| `dither_ghost.gdshader` | Punches holes on a 4×4 Bayer grid. Every pixel stays fully opaque or fully gone, so it never softens at scale. This is how 16-bit hardware faked transparency. | `amount` (1 = solid, 0 = gone) |
| `materialise.gdshader` | Dithered wipe from the feet up. Tween `level` 0→1. | `level`, `softness` |
| `ember_dissolve.gdshader` | Per-texel noise eats the sprite; pixels at the burn threshold flare. Tween `progress` 0→1. | `progress`, `edge_width` |
| `reflection.gdshader` | Wet-floor mirror. Needs a **second sprite** with `flip_v = true`, offset so the mirrored feet meet the real feet. See `Actors/Enemies/Wolf/Reflection`. | `strength` |

### Distortion and glitch

| Shader | Effect | Key params |
|---|---|---|
| `datamosh.gdshader` | Random scanlines shift sideways, colour channels separate into fringes. | `amount` (≤3), `speed`, `density` |
| `wave_warp.gdshader` | Travelling sine displaces each row sideways. Displacement is `floor()`ed to whole pixels so the shape stays on-grid. | `amp`, `freq`, `speed` |
| `mosaic.gdshader` | Snaps sampling to a coarse block grid that breathes over time. Reads as low-res / still rendering. | `block`, `pulse` |
| `echo_trail.gdshader` | Two fading whole-shape afterimages. Negative `spacing` throws the trail the other way. | `spacing`, echo alphas |

### Stripe family — **overlapping, pick one**

| Shader | Effect |
|---|---|
| `hologram.gdshader` | Static scanlines + flicker |
| `phase_bands.gdshader` | Scrolling alpha bands |

These two look nearly identical in motion; only the colour and scroll differ.
They should be merged or one dropped.

Both derive scanlines from the **texel row**, not `FRAGCOORD`. Deriving from
screen pixels is what makes most scanline shaders shimmer at non-native scales —
at 4× a "2px" screen scanline is half a game pixel.

### Not sprite-based

| Shader | Effect |
|---|---|
| `ground_pool.gdshader` | Neon light pool on a bare `ColorRect`, no texture at all. Quantised radial falloff. Grounds an actor and fixes the floating look silhouettes tend to have. |

## Proposed mapping to game state

Effects earn their place when each one *means* something. Nothing below is
implemented — it is the argument for keeping each shader.

| State | Effect |
|---|---|
| Target selected / acting this turn | `outline` — animate `width` or swap `outline_color` |
| Summon, revive, teleport in | `materialise` |
| Death | `ember_dissolve` |
| Ethereal or cloaked enemy type | `dither_ghost` |
| Untargetable / evading | `phase_bands` or `hologram` |
| Hit reaction, corrupted enemy family | `datamosh` |
| Fast / multi-hit attacker | `echo_trail` |
| Elemental or energy creature | `plasma_flow` |
| Enemy standing in water or on wet street | `reflection` |

Distinct enemy *families* fall out of this for free: one silhouette plus one
shader each, no extra art.

## Adding a shader

1. New `.gdshader` in `shaders/`, `snake_case`.
2. Header comment: what it does, what drives it, and an `ATLAS WARNING` line if
   it samples outside the current texel.
3. Expose everything tunable as a `uniform` with a sensible default — the point
   is dialling it in from the Inspector, not editing code.
4. Keep the pixel discipline: quantise gradients into bands, `floor()`
   displacements to whole pixels, derive scanlines from texel rows, and prefer
   Bayer dithering over partial alpha.
5. Add a row to the catalog above.

## Verifying shaders without opening the editor

`--import` **does** compile shaders and reports failures, so this catches
errors headlessly:

```bash
godot --headless --path . --import
```

A compile failure prints `SHADER ERROR:` followed by the reason. In-game a
broken shader shows as a solid magenta box.

Then confirm the scene still instantiates:

```bash
godot --headless --path . res://scenes/BattleScene.tscn --quit-after 5
```

## Known gotcha

Shader built-ins (`TEXTURE`, `UV`, `TIME`, …) exist only inside the shader stage
that declares them. Passing `TEXTURE` into a custom function fails with
`Unknown identifier in expression: 'TEXTURE'`. Either inline the sampling in
`fragment()` (what `contour_bands` does) or declare the parameter as `sampler2D`.
