# Clearlake Christmas Radio

A self-hosted internet radio station and companion app — owned end to end.

Clearlake Christmas Radio broadcasts the music behind the **Clearlake Christmas Light Spectacular**, a 20-year holiday light display. This project replaces a paid third-party streaming platform with self-owned infrastructure: a home-hosted radio backbone plus a cross-platform listener app.

## What it is
- **Live radio** — 24/7 Christmas music, show-time broadcasts, and a family podcast, streamed from a self-hosted [AzuraCast](https://www.azuracast.com/) station.
- **On-demand library** — a personal, browse-and-play music experience (private, friends & family) backed by Plex.
- **Companion app** — one codebase (PWA + Capacitor) targeting web, iOS, and Android, with background audio, lock-screen controls, and car-Bluetooth now-playing metadata.
- **Live cutover** — the app pulls listeners into the shared, synced live stream the moment a show goes on-air, then hands them back to their own playlist afterward.

## Architecture (high level)
```
Garage NUC (ZaraRadio 1.6) --> FM transmitter/antenna  (synced physical light show)
                           \--> BUTT --> AzuraCast (Unraid VM) --> NginxProxyManager --> listeners
                                                                          |
Companion app --> AzuraCast REST API (live)  .  Plex (on-demand)  .  Podcast RSS
```

## Status
Early. Architecture locked; infrastructure build starts at P0. See [`docs/`](docs/) for the full picture:
- [`PROJECT_INSTRUCTIONS.md`](docs/PROJECT_INSTRUCTIONS.md) — how the project runs
- [`DECISIONS.md`](docs/DECISIONS.md) — locked decisions
- [`BACKLOG.md`](docs/BACKLOG.md) — phased roadmap (P0–P6)
- [`HANDOFF.md`](docs/HANDOFF.md) — current state + next tasks
- [`SESSION_LOG.md`](docs/SESSION_LOG.md) — session history
- [`CHANGELOG.md`](docs/CHANGELOG.md)

---
*Not affiliated with AzuraCast, Plex, or any third-party service referenced above.*
