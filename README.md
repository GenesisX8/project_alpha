# Project Alpha

Godot 2D desktop game (GDscript) — edited with Visual Studio Code.

Getting started
- Open this folder in Godot (use Godot editor) and set `Editor -> Editor Settings -> Text Editor -> External` to Visual Studio Code.
- From VSCode install recommended extensions (see `.vscode/extensions.json`).

Common commands
- Open Godot and run the main scene (e.g., `scenes/Prototype2D.tscn`).

Create a GitHub repository and push
- Create a new repo at https://github.com/new and follow instructions, or use the GitHub CLI:

```bash
gh repo create <owner>/project_alpha --public --source . --remote origin --push
```

Or add remote and push manually:

```bash
git remote add origin git@github.com:<owner>/project_alpha.git
git branch -M main
git push -u origin main
```

License
- MIT (see LICENSE)
