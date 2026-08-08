# Clearlake Christmas Radio — Changelog

---

## 2026-08-07 (evening) — P1 Complete — Exposure + public stream live
- Added NPM proxy host `radio.clearlakechristmasradio.com` → `10.4.1.2:80` with websocket support and `proxy_buffering off; proxy_read_timeout 3600s;` for Icecast passthrough.
- Added Cloudflare A record `radio.clearlakechristmasradio.com → 199.187.202.175` (DNS only, grey cloud).
- Let's Encrypt cert provisioned (npm-16, expires 2026-11-06).
- Updated AzuraCast Site Base URL to `https://radio.clearlakechristmasradio.com`.
- Fixed Liquidsoap `media_path` (was hardcoded to default station dir; regenerated via `azuracast_cli azuracast:radio:restart 1` → now `/var/azuracast/storage/music`).
- Added 614-track library to `Christmas Rotation` playlist; set 24/7 schedule. AutoDJ confirmed playing.
- Added NPM Custom Location `/live` → `return 302` to full listen URL. Public stream URL: `https://radio.clearlakechristmasradio.com/live`.
- Load test: 50 concurrent streams confirmed by Icecast (~9.6 Mbps, ~1% of 950 Mbps uplink).
- **P1 gate PASSED**: external listener confirmed from phone on mobile data.

## 2026-08-07 — P2 partial — Music library imported into AzuraCast
- Created `docker-compose.override.yml` in `/tmp` to bind-mount `/mnt/music` into the AzuraCast container at `/var/azuracast/storage/music`.
- Added `/var/azuracast/storage/music` as a Local Filesystem storage location in AzuraCast (Admin → Storage Locations).
- Switched station Media Storage Location from the default AzuraCast dir to `/var/azuracast/storage/music`.
- AzuraCast scanned and indexed 614 audio files (library contains mixed MP3/FLAC + Windows metadata artifacts; ~117 non-audio files skipped).
- Brian confirmed: AutoDJ not a priority — ZaraRadio remains the playout brain; AzuraCast library is a fallback/future use.
- Discussed ZaraRadio migration off the Christmas lights NUC — added to parking lot for off-season.
- BUTT repoint from Zeno → AzuraCast is the remaining P2 task.

## 2026-08-06/07 — P0 Infra complete — AzuraCast live on LAN
- Registered domain: `clearlakechristmasradio.com`. Target: `radio.clearlakechristmasradio.com`.
- Ubuntu Server 24.04.2 LTS VM created on Unraid (`azuracast`, `10.4.1.2`, 2 vCPU / 4 GB / 50 GB, SeaBIOS).
- 9p music share mounted at `/mnt/music` (persistent via `/etc/fstab`).
- Docker 29.7.2 + AzuraCast Rolling Release installed via official `docker.sh`.
- Station `Clearlake Christmas Radio` configured: Icecast `/radio.mp3` mount, AutoDJ (Liquidsoap), `Christmas Rotation` playlist, 10 test tracks.
- **P0 gate PASSED**: stream heard on a second LAN device at `http://10.4.1.2/listen/clearlake_christmas_radio/radio.mp3`.

## 2026-07-17 — Project inception
- Project created: self-owned internet radio station + companion app to replace Zeno FM.
- End-to-end architecture locked (hosting, backbone, cutover, app, two listening modes, tiering) — see `DECISIONS.md`.
- Docs scaffolded on the host repo: `PROJECT_INSTRUCTIONS`, `DECISIONS`, `BACKLOG`, `SESSION_LOG`, `HANDOFF`, `CHANGELOG`, `README`, `.gitignore`.
- Monetization & Product Strategy logged: white-label companion-app **SaaS** route (sell tools, not hosting), branded under BlinkinLights Studio, cross-sold with Maestromia. Managed music-hosting AaaS ruled out. Strategic/GTM/financials owned in the Business Claude project.
- `BACKLOG` P3 gained a forward-compat line to keep app auth multi-tenant-capable (preserves the SaaS path at zero cost).
- **Session startup primer** added to the top of `HANDOFF.md` for fast cold-starts.
- Added resident auto-commit tray watcher: `clearlake-watch.ps1` + `clearlake-watch.bat` (ported from Maestromia, Christmas-themed; commits locally when no remote is set; no deploy step yet).
- No infrastructure or code built yet. Existing Zeno / ZaraRadio / FM setup untouched.
