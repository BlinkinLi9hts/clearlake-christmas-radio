# Clearlake Christmas Radio — Project Instructions
**Read this at the start of every session.**

---

## Session Startup — Claude Must Do This First, Every Session

Brian will say something like "Good morning" or "New session" or "Let's go".

Claude must immediately, without being asked:

1. **Read these files in order via filesystem MCP:**
   - `C:\Projects\clearlake-christmas-radio\docs\PROJECT_INSTRUCTIONS.md` (this file)
   - `C:\Projects\clearlake-christmas-radio\docs\SESSION_LOG.md`
   - `C:\Projects\clearlake-christmas-radio\docs\BACKLOG.md`
   - `C:\Projects\clearlake-christmas-radio\docs\DECISIONS.md`
   - `C:\Projects\clearlake-christmas-radio\docs\HANDOFF.md`

2. **Post a ready confirmation** in this exact format:

```
Good morning Brian.

Project: Clearlake Christmas Radio
Phase: PX — [name] ([status])
Last session: [one line summary]
Top priority: [top backlog item]
Open gates: [current phase gate]

Ready.
```

3. **Do not ask Brian any questions** until the ready confirmation is posted.
4. **Do not wait** for Brian to tell you what to read — just read and report.

**No zip file. No checkpoint. The repo IS the source of truth.**

---

## Who Brian Is
- Technical Product Manager (PMP certified, ~30 years experience)
- Believes in extensive testing cycles throughout development
- Christmas light enthusiast — 20 years running the Clearlake Christmas Light Spectacular
- Username: BlinkinLi9hts

## The Project
**Clearlake Christmas Radio** — Brian's self-hosted internet radio station + companion app, owned end to end.
- **Heritage:** The light display has been the *Clearlake Christmas Light Spectacular* for 20 years, named for Clearlake Way (Brian's original street). The station pays homage to those roots.
- **Why now:** Zeno FM (prior internet distribution layer) raised rates. This project replaces Zeno entirely with self-owned infrastructure — no recurring platform fees.
- **Standalone:** This is its own repo and its own project. Not a BlinkinLights Studio product. Personal-first, with a deliberate path to grow if desired.

## The Stack (locked — see DECISIONS.md)
- **Host:** Existing Unraid homelab — Lenovo ThinkServer TS440, Xeon E3-1245 v3 (4c/8t), 32 GB RAM, 950 Mbps symmetric fiber.
- **Backbone:** AzuraCast (self-hosted radio-in-a-box: Liquidsoap AutoDJ, Icecast, Web DJ, REST API, listener analytics).
- **AzuraCast deployment:** Ubuntu Server VM on Unraid running AzuraCast's official Docker installer. NOT a Windows VM. NOT a native Unraid container. Isolated from the existing *arr Docker stack so it self-updates cleanly and a station update can never disturb Plex.
- **Exposure:** Behind existing NginxProxyManager (`radio.{domain}`), reusing existing certs. Cloudflare Tunnel optional/deferred.
- **App:** Single codebase → three targets. PWA core + Capacitor wrap for iOS/Android. Background audio, lock-screen controls, car-Bluetooth now-playing metadata.
- **On-demand backend:** Plex (already running on the homelab).
- **Podcast:** Self-hosted (Castopod direction — real RSS feed).

## The Two Listening Modes (the core product insight)
- **LIVE mode** (shared, synced): One AzuraCast stream everyone hears together — 24/7 music, show time, the light show, live podcast. Cannot skip or reorder, by design — that is what keeps it in sync with the physical lights.
- **ON-DEMAND mode** (personal, "like Amazon Music"): Each listener browses the Christmas library and picks / skips / shuffles their own way. Plex-backed. Private by design (see licensing note in DECISIONS).

## The Existing Physical Setup (do not disturb)
- Garage **NUC** runs **ZaraRadio 1.6** (free) as the 24/7 playout brain.
- ZaraRadio feeds two paths: (1) **FM transmitter + antenna** for cars at the display — near-zero latency, this is what keeps the lights synced for the physical audience; (2) **BUTT** as the Icecast source client, previously → Zeno FM.
- **Cutover = repoint BUTT** from Zeno to AzuraCast. ZaraRadio and the FM path are NOT touched in the first cut.

## Working Preferences
- Always read this file and the session docs before responding.
- Discuss changes before building anything.
- Stand up / prove in isolation before exposing or cutting over — never break the running station.
- Validate against a phase gate before advancing. No skipping gates.
- Present test checklists as numbered Y/N lists.
- Keep explanations brief and to the point.
- **Testing workflow:** Claude proves the internal/technical pass first (config, LAN test, load test where relevant) → hands Brian a functional + regression checklist → Brian does the real-world confirmation (real listeners, car radio, audio feel).
- **The FM/physical light show is sacred** — any change that could affect it is flagged and gated separately.

## Session Types
| Type | Scope |
|---|---|
| STRATEGIC | Direction, scope, tiering, roadmap — no build |
| INFRA | VM, AzuraCast, NPM, networking, homelab — server work |
| APP DEV | PWA / Capacitor app build — mockup first, validate always |
| CONTENT | Library, playlists, scheduling, podcast production |
| BRANDING | Naming, logo, identity, station imaging — no build |

Respect hard boundaries between session types.

## Filesystem
- Repo root: `C:\Projects\clearlake-christmas-radio`
- Never overwrite existing files without confirmation.
- Check directory structure before creating new files.
- **Write via the filesystem MCP tools** (they reach the Windows host). The native file-creation tools write to a sandbox container and will NOT land in this repo.

## Infra Access (available to Claude)
- **Unraid MCP** — homelab overview, Docker, VM, array, notifications.
- **SSH to Unraid** — shell access to the host.
- Claude has **no shell to Brian's Windows machine** — `git init`, remotes, and Windows-side file plumbing are Brian's.

## Session Closeout
- At session end, say "closeout".
- Claude updates `docs/CHANGELOG.md`, `docs/SESSION_LOG.md`, `docs/BACKLOG.md`, and `docs/HANDOFF.md` directly.
