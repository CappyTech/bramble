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
- Engine: Godot 4.7.x, GDScript. 4.7.2 is pinned in CI; decided 2026-10-15.
- Dev machine: Windows.
- Repo: `CappyTech/bramble` on GitHub.

### Game concept
- Genre: management game.
- Centre of the game: an allotment. Spin-offs may come later; the allotment remains the core.
- Visual style: 2D top-down.
- Time: the game progresses per day; the day ends when the player sleeps.
- Growing depth: start light (plant, water, wait, harvest) but structure data so soil, rotation,
  pests and frost can be added later.
- Player avatar (decided 2026-10-15): the player is a visible character on the plot. Tapping a tile
  with a tool selected walks the character there, plays a working pose, and only then applies the
  action. Sleeping fades to night and back. This says nothing about how time passes within a day
  (open question 1).

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
- Source: **Minifantasy** by Krishna Palacio (https://krishna-palacio.itch.io/), 8x8 pixel art.
  Decided 2026-10-15. The owner already holds most of the collection; packs most relevant here:
  Farm (crops in growth stages, field hydration states, fences, action icons), Wildlife,
  Forgotten Plains (free; grass and ground), Towns I and II, Builders, Crafting And Professions
  I and II (work animations), A Myriad Of NPCs (layered character generator), User Interface,
  Creatures, Maps, Ancient Forests, Tiny Overworld I and II.
- Not owned but on-theme: Plants & Foliage, Meadow Of Seasons, Modern Town, UI Overhaul,
  Portrait Generator.
- Licence (per pack page): commercial use and editing allowed; redistribution of the assets, altered
  or not, is forbidden; Krishna Palacio must be credited in the game credits and sent a link to the
  finished project. Consequence: the asset files must never sit in a public repository. See open
  question 3.
- Until the packs are imported, placeholder shapes and colours remain acceptable.

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
- Render scale for the 8x8 Minifantasy tiles on phone screens (currently 8x on the 1280x720 canvas,
  which is not a decision) and whether a unifying
  custom palette is applied over the packs.
- Where the licensed asset files live: gitignored `assets/minifantasy/`, or a private repo.
- Modern British setting, as opposed to fantasy-rustic.
- Additional MCP tooling: an ADB/Android MCP server for on-device screenshots; a Godot docs server.
- Screen orientation: the scaffold is set to landscape as a placeholder; not decided.

## Open questions
1. Time within a day: real-time ticking, fixed costs per action, or a hybrid? (Explicitly undecided.)
2. Monetisation model: paid app, free with in-app purchases, or ads?
3. Repo visibility and licence for a commercial project (Cairn uses AGPL-3.0; that may not suit).
   Minifantasy assets cannot be redistributed, so a public repo must exclude them.
4. Screen orientation: portrait or landscape?
5. Google Play signing: upload keystore and who holds it.
