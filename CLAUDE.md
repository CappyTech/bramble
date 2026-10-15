# Bramble — notes for Claude Code

Bramble is a 2D top-down allotment management game for Android, built in Godot 4.7 with GDScript.

## Rule for this project: do not assume
Anything not listed under **Decided** in `docs/brief.md` must be asked about before acting on it.
Proposals in that file are suggestions, not decisions. Open questions are open.

## Conventions
- Engine: Godot 4.7.x (4.7.2 pinned in CI), GDScript, static typing (`var x: int`, `-> void`), tabs for indentation.
- Android package ID: `uk.cappylabs.bramble` (fixed; never change).
- Layout: `scenes/` for `.tscn`, `scripts/` for `.gd`, `assets/` for art and audio, `tests/` for
  headless checks, `docs/` for design notes, `addons/` for editor plugins.
- Art: Minifantasy 8x8 pixel art (Krishna Palacio), licensed and non-redistributable; never commit the
  asset files to a public repo. Placeholder shapes/colours are fine until packs are imported.
- Keep `export_presets.cfg` committed, but never commit keystores or `export_credentials.cfg`.

## Validation
CI runs `godot --headless --path . --import`, then `godot --headless --path . --script tests/ci_check.gd`,
then `godot --headless --path . --script tests/test_allotment.gd` and `tests/test_save.gd` (unit tests).
Run the same locally before pushing.

## Tooling
`.mcp.json` registers the `godot-mcp` server (satelliteoflove/godot-mcp). The matching editor addon
lives in `addons/godot_mcp` and is enabled in `project.godot`. It needs the Godot editor open on the
dev machine to do anything; CI does not use it.
