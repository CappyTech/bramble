# Bramble: project brief

Living record of what is decided, what is only proposed, and what is still open.
**Rule: do not assume.** Anything not under *Decided* must be asked about before acting on it.

## Decided

### Identity
- Codename **Bramble**: used for the repo, package and internal identifiers.
- Final player-facing title: not chosen yet.
- Android package ID: `uk.cappylabs.bramble`. Fixed once published to Google Play.

### Platform and engine
- Target platform: Android.
- Engine: Godot 4.6.x, GDScript.
- Dev machine: Windows.
- Repo: `CappyTech/bramble` on GitHub.

### Game concept
- Genre: management game.
- Centre of the game: an allotment. Spin-offs may come later; the allotment remains the core.
- Visual style: 2D top-down.
- Time: the game progresses per day; the day ends when the player sleeps.
- Growing depth: start light (plant, water, wait, harvest) but structure data so soil, rotation,
  pests and frost can be added later.

### Family system
- At the start the player chooses a family. Examples:
  - Solo
  - Poor, but helpful
  - Rich, but doesn't do you any favours, and it's hard to get more money
- The family is a living party in the game, like the other parties:
  - banker
  - market
  - village council
  - allotment committee
- Generational play (plot passes to an heir): yes, but as DLC or an optional endgame restart,
  not part of the base game.

### Art
- Artwork is the main hindrance. Keep the art workload low.
- For now: placeholder shapes and colours only. Sourcing (packs, generated, commissioned) is undecided.

### Publishing and tooling
- Commercial release on Google Play.
- Godot MCP server: `satelliteoflove/godot-mcp` (playtesting with input injection and game-time
  stepping). Config in `.mcp.json`, editor addon in `addons/godot_mcp`.

## Proposals (not confirmed; check before building on them)
- Shared faction model: each party (family, committee, council, banker, market) has a standing,
  offers, demands and a personality. The family origin sets starting standings and personalities.
- Daily energy budget: limited energy per day; obligations to factions cost time as well as goods.
- Calendar rhythm:
  - daily: watering and harvesting
  - weekly: market day, family dinner
  - monthly: committee meeting, bank repayment
  - seasonal: village show, frost, annual plot fee
  - deliberate scheduling clashes between these
- Art sources: 16×16 pixel-art asset packs unified by a custom palette.
- Modern British setting, as opposed to fantasy-rustic.
- Additional MCP tooling: an ADB/Android MCP server for on-device screenshots; a Godot docs server.
- Screen orientation: the scaffold is set to landscape as a placeholder; not decided.

## Open questions
1. Time within a day: real-time ticking, fixed costs per action, or a hybrid? (Explicitly undecided.)
2. Art sourcing: asset packs, generated art, commissioned art, or a mix?
3. Monetisation model: paid app, free with in-app purchases, or ads?
4. Repo visibility and licence for a commercial project (Cairn uses AGPL-3.0; that may not suit).
5. Screen orientation: portrait or landscape?
6. Godot minor version: 4.6.3 is pinned in CI. Godot 4.7.2 is the current stable; upgrade or stay?
7. Google Play signing: upload keystore and who holds it.
