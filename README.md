# Bramble

A 2D top-down allotment management game for Android, built with Godot 4.6.
`Bramble` is the codename; the player-facing title is not chosen yet.

## Status
Scaffold only. The project opens, imports and runs a placeholder title scene. No game systems yet.
See [`docs/brief.md`](docs/brief.md) for what is decided, proposed and open.

## Getting started (Windows)
1. Install [Godot 4.6.3](https://godotengine.org/download/) (standard build, not .NET).
2. Clone this repo and open `project.godot` in the editor.
3. Press F5 to run. You should see the Bramble title on a brown background.

### Android export
1. Install Android Studio or the command-line SDK, plus a JDK 17. Set the paths in
   Editor > Editor Settings > Export > Android.
2. Install the Gradle build template: Project > Install Android Build Template.
   This creates `android/`, which is git-ignored.
3. The `Android` preset in `export_presets.cfg` builds an AAB with package ID
   `uk.cappylabs.bramble`, arm64 only. Signing uses a keystore configured in the editor;
   keystores and `export_credentials.cfg` are never committed.

## Validation
CI (`.github/workflows/validate.yml`) imports the project headlessly and runs `tests/ci_check.gd`,
which loads the main scene and every script under `scripts/`. Run the same locally:

```
godot --headless --path . --import
godot --headless --path . --script tests/ci_check.gd
```

## AI tooling
`.mcp.json` registers the [godot-mcp](https://github.com/satelliteoflove/godot-mcp) server for
Claude Code. The matching editor addon is in `addons/godot_mcp` and enabled in project settings.
With the editor open, the server can edit scenes, inject input into the running game and step
game time for playtesting. Requires Node.js 20+.

## Layout
```
scenes/    .tscn scenes
scripts/   .gd scripts
assets/    art, audio (placeholder/ for temporary shapes)
tests/     headless checks run by CI
docs/      design notes and the project brief
addons/    editor plugins
```
