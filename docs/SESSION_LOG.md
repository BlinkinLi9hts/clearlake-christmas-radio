# Clearlake Christmas Radio — Session Log

---

## 2026-08-07 (evening) — P1 GATE PASSED — Exposure complete
**Session Type:** INFRA
**Deliverable:** AzuraCast publicly reachable over HTTPS; 50-concurrent load test passed; P1 gate closed.

### What Was Done

**NPM proxy host**
- Added `radio.clearlakechristmasradio.com` → `10.4.1.2:80` in NginxProxyManager with Websockets Support enabled.
- Added custom nginx config to the proxy host: `proxy_buffering off; proxy_read_timeout 3600s;` (required for live audio streaming).
- First cert attempt failed — domain had no DNS A record. Added `radio.clearlakechristmasradio.com → 199.187.202.175` (DNS only, grey cloud) in Cloudflare.
- Let's Encrypt cert provisioned successfully on retry. HTTPS live.

**AzuraCast base URL**
- Updated Site Base URL to `https://radio.clearlakechristmasradio.com` in Admin → System Settings.

**AutoDJ / Liquidsoap fix**
- Station showed "Station Offline" — Liquidsoap (station_1_backend) had stopped due to empty queue.
- Root cause: Liquidsoap config had `media_path` hardcoded to `/var/azuracast/stations/clearlake_christmas_radio/media` (default) rather than `/var/azuracast/storage/music` (custom mount). Config was generated before storage location was switched.
- Fix: `azuracast_cli azuracast:radio:restart 1` regenerated the Liquidsoap config with correct `media_path := "/var/azuracast/storage/music"`. Station came online. Full 614-track library now plays.
- Brian added all 614 tracks to the `Christmas Rotation` playlist and set a 24/7 schedule.

**Short stream URL**
- Added NPM Custom Location `/live` on the `radio.clearlakechristmasradio.com` proxy host.
- Gear-icon custom config (inside the location block): `return 302 https://radio.clearlakechristmasradio.com/listen/clearlake_christmas_radio/radio.mp3;`
- Public stream URL: `https://radio.clearlakechristmasradio.com/live`

**Load test**
- 50 concurrent curl connections held cleanly. Icecast confirmed 50 listeners at peak.
- Bandwidth: ~9.6 Mbps (50 × 192 kbps) = ~1% of 950 Mbps uplink. Ample headroom.

**P1 Gate: PASSED**
- External listener confirmed from phone on mobile data ✅
- SSL valid, stream plays ✅
- 50 concurrent streams held ✅

### Hard Lessons (do not repeat)
- AzuraCast's Liquidsoap config (`media_path`) is generated at station restart time. If the storage location is changed after the last config generation, the old path is baked in. Always run `azuracast_cli azuracast:radio:restart 1` after any storage location change.
- NPM Custom Locations gear-icon config box inserts content INSIDE the generated `location {}` block — do not wrap in another `location {}`. Paste the directive only.
- Cloudflare A record must be **DNS only (grey cloud)** for audio streams — proxied (orange) violates free-tier TOS and will break Icecast.

### Next Session — P2 Remaining (BUTT repoint)
- In BUTT on the garage NUC: change server from Zeno → AzuraCast.
  - Host: `radio.clearlakechristmasradio.com`
  - Port: `80` (HTTP source) or `8000` if direct to Icecast
  - Mount: `/radio.mp3`
  - Source credentials: AzuraCast Station → Broadcasting → Icecast → Source username/password (Username: `source`, Password shown in dashboard)
- Confirm stream live in AzuraCast after BUTT repoint.
- Confirm ZaraRadio + FM transmitter path completely undisturbed.
- P2 Gate: Zeno decommissioned, station fully self-hosted.

---

## 2026-08-07 — P2 partial — Music library import
**Session Type:** INFRA
**Deliverable:** Full music library visible in AzuraCast; 614 audio files indexed.

### What Was Done

**Library import approach**
- Decided on custom storage location (Option A: point AzuraCast at `/mnt/music`) over copying files — no duplication, single source of truth on the Unraid array.
- `/mnt/music` was already mounted in the VM with correct permissions (777), but AzuraCast's Docker container couldn't see it — the mount exists on the VM host, not inside the container.

**docker-compose.override.yml**
- Created `/tmp/docker-compose.override.yml` to bind-mount `/mnt/music` into the container at `/var/azuracast/storage/music`.
- AzuraCast restarted via `docker compose down && docker compose up -d` from `/tmp`.
- Added `Local: /var/azuracast/storage/music` as a new Storage Location in AzuraCast admin.
- Switched station's Media Storage Location to the new path.
- AzuraCast auto-triggered a scan; indexed 614 audio files (library has mixed MP3/FLAC + Windows metadata artifacts).

**Key decisions / clarifications**
- Brian confirmed AutoDJ is NOT a priority — ZaraRadio remains the playout brain; AzuraCast library is a fallback/future capability.
- AzuraCast's role clarified: it IS the Icecast server (replacing Zeno FM) + management front-end. ZaraRadio → BUTT → AzuraCast → internet listeners.
- ZaraRadio migration off the Christmas lights NUC added to parking lot — it's a shared machine with the light show and FM transmitter, which is a concern but an off-season problem.

### Hard Lessons (do not repeat)
- AzuraCast runs in Docker — host-mounted paths (`/mnt/music`) are NOT visible inside the container without an explicit bind mount. Always use `docker-compose.override.yml` for customizations; never edit `docker-compose.yml` directly.
- The compose files live in `/tmp` (installer ran from there in P0) — always `cd /tmp` before any `docker compose` commands.

### Next Session
- **P1 — Exposure.** Add NginxProxyManager host `radio.clearlakechristmasradio.com` → `10.4.1.2`. Configure stream passthrough. Confirm Let's Encrypt cert. External listener test.
- **P2 remaining:** Repoint BUTT from Zeno → AzuraCast (`http://radio.clearlakechristmasradio.com/radio.mp3`). Zeno retired.

---

## 2026-08-06/07 — P0 Infra — Ubuntu VM + AzuraCast — GATE PASSED
**Session Type:** INFRA
**Deliverable:** Self-hosted AzuraCast instance streaming live on the LAN. P0 gate passed.

### What Was Done

**Domain**
- Registered `clearlakechristmasradio.com`. Target subdomain: `radio.clearlakechristmasradio.com` (wired at P1 via NginxProxyManager).

**Ubuntu VM creation**
- Created `azuracast-ubuntu` VM on Unraid: 2 vCPU, 4 GB RAM, 50 GB raw vdisk (`/mnt/user/domains/azuracast-ubuntu/vdisk1.img`), SeaBIOS, Q35→i440fx.
- Music library (`/mnt/user/Music/! Christmas Radio/`, 5.6 GB) exposed to VM as a 9p/VirtFS share (mount tag: `music`).
- Ubuntu Server 24.04.2 LTS installed (kernel 6.8.0-137). Hostname: `azuracast`. IP: `10.4.1.2`.
- SSH key-based access established from Unraid (`claude-ssh` user → `brian@10.4.1.2`).
- Passwordless sudo configured for `brian` (`/etc/sudoers.d/brian-nopasswd`).
- 9p music share mounted at `/mnt/music`, added to `/etc/fstab` for persistence.

**AzuraCast installation**
- Docker 29.7.2 installed via AzuraCast's official `docker.sh` installer.
- AzuraCast Rolling Release (`2026-08-03`) running as Docker container at `http://10.4.1.2`.
- Station created: **Clearlake Christmas Radio** — 192 kbps MP3, Icecast mount `/radio.mp3`.
- AutoDJ (Liquidsoap) configured and running.

**Media & playlist**
- 10 test tracks copied from music library into AzuraCast station media dir.
- Playlist `Christmas Rotation` created (General Rotation, Shuffled, Avoid Duplicates).
- Tracks assigned to playlist.

**P0 Gate**
- Stream URL: `http://10.4.1.2/listen/clearlake_christmas_radio/radio.mp3`
- **PASSED**: stream heard on a second LAN device. Bing Crosby confirmed.

### Decisions Made This Session
- `clearlakechristmasradio.com` locked as the domain. `radio.clearlakechristmasradio.com` is the target.
- SeaBIOS (not OVMF) for the Ubuntu VM — UEFI caused unresolvable VNC keyboard issues.
- Music library served via 9p mount (not copied to vdisk) — confirmed working.
- AzuraCast installer ran from `/tmp` (not `/var/azuracast`) — Docker volumes are in `/var/lib/docker/volumes/azuracast_*`.

### Hard Lessons (do not repeat)
- DISABLE="yes" in Unraid `domain.cfg` blocks VM creation — must be "no".
- Never toggle VM Manager off/on to fix config issues — it unmounts `/etc/libvirt`.
- Two simultaneous wget processes corrupt an ISO — always single-process downloads.
- Boot order defaults to vdisk first — set to ISO for first boot.
- OVMF BIOS + noVNC = keyboard dead in UEFI menu. SeaBIOS works cleanly.

### Next Session
- **P1 — Exposure.** Add NginxProxyManager host `radio.clearlakechristmasradio.com` → `10.4.1.2`. Configure stream passthrough. Confirm Let's Encrypt cert. External listener test.
- At P2: import full music library, repoint BUTT from Zeno.

---

## 2026-07-17 — Project Kickoff — Full Architecture Locked
**Session Type:** STRATEGIC
**Deliverable:** Project scaffolding (docs) + locked end-to-end architecture + monetization route + session startup primer

### What Was Done
Kicked off a brand-new project: replace Zeno FM (which raised its rates) with a self-owned internet radio station + companion app, owned end to end. Named **Clearlake Christmas Radio**, in homage to the 20-year Clearlake Christmas Light Spectacular and the original Clearlake Way roots.

Worked the whole architecture top to bottom in one sitting, decision by decision:

**Hosting & backbone**
- Landed on home-hosting via the existing Unraid homelab (Lenovo TS440, Xeon E3-1245 v3, 32 GB RAM, 950 symmetric fiber).
- Inspected the actual box: ~27 GB RAM free, and — critically — **NginxProxyManager already running**, which largely solves safe external exposure.
- Backbone = **AzuraCast** (verified current/maintained). Maps 1:1 to the needs: AutoDJ, Icecast, Web DJ (podcast + light-show live takeover), REST API (app hook), analytics.
- Deployment call: **Ubuntu VM running AzuraCast's official installer** — not a Windows VM, not a native Unraid container — to isolate its self-managing compose stack from the *arr Docker and protect Plex.

**Capacity**
- 10–50 peak concurrent ≈ <2% of the 950 up pipe → home-direct, no relay. Relay/CDN noted as the scale-out path.

**Existing setup / cutover**
- Mapped the current topology: garage NUC → ZaraRadio 1.6 → FM transmitter (synced physical show) + BUTT → Zeno.
- Cutover is near drop-in: **repoint BUTT from Zeno → AzuraCast**. ZaraRadio + FM path untouched in the first cut. Playout consolidation deferred to off-season.

**Product insight — two listening modes**
- **Live** (shared, synced AzuraCast stream) vs **on-demand** (personal, "like Amazon Music").
- Big unlock: **Plex is already running** and is the on-demand backend — we don't build the hard part.
- The dreamed-of behavior (music that cuts over to the live show automatically) is real: app watches AzuraCast live status → "LIVE NOW" banner → synced stream → hands back after.

**Podcast**
- Trailer cut years ago, never launched. Goal: do it this year with the boys. Self-host via Castopod (confirm at P4).

**Scalability — tiered model**
- Public tier (live radio + podcast) scales + is statutorily licensable. Private tier (on-demand Plex) stays invite-gated by design (no cheap on-demand license).
- **Auth-first app** is the one-way-door insurance: makes "5 or 5,000" a config question.

**Monetization / resell (added later in session)**
- Weighed the resell angle. Ruled OUT managed music-hosting AaaS (thin margins, fat licensing liability). Ruled IN **white-label companion-app SaaS** — sell the app + config dashboard, not hosting; licensing stays the customer's.
- Locked: productized app is a **BlinkinLights Studio** product, cross-sold with Maestromia (sequence → broadcast, same buyer). The **station stays personal/standalone**; only the app productizes.
- Strategic/GTM/financials tracked in the separate **Business Claude** project. This repo only preserves the architecture path (P3 auth kept multi-tenant-capable).

### Deliverables Produced
- Full doc scaffold created on the host repo: `PROJECT_INSTRUCTIONS`, `DECISIONS`, `BACKLOG`, `SESSION_LOG`, `HANDOFF`, `CHANGELOG`, `README`, `.gitignore`.
- Monetization & Product Strategy section added to `DECISIONS`; SaaS parking-lot + P3 forward-compat line added to `BACKLOG`.
- **Session startup primer** prepended to `HANDOFF.md` for fast cold-starts (read order, ready-confirmation format, locked-stack one-liner, red guardrails, "right now" pointer).

### Decisions Locked This Session
All captured in `DECISIONS.md` — project/scope, hosting (Unraid VM + AzuraCast + NPM), capacity, Zeno cutover via BUTT, two listening modes + live cutover, app (PWA + Capacitor, auth-first), podcast (Castopod direction), tiered public/private model, and the white-label SaaS monetization route.

### Next Session
- **P0 — Infra.** Decide the `radio.{domain}` domain, stand up the Ubuntu VM + AzuraCast, stream on the LAN. See the primer + first tasks in `HANDOFF.md`.

### Retrospective
- Reading the actual Unraid box mid-session changed the plan for the better — the pre-existing NginxProxyManager collapsed most of the P1 exposure problem before it started. Inspect real infra before designing around assumed infra.
- The "two listening modes" reframe was the pivotal moment — it turned a vague "make it like Amazon Music" wish into a clean architecture (radio vs library) with an already-owned backend (Plex) doing the heavy lifting.
- Naming the licensing shape early (statutory-radio vs no-cheap-on-demand) kept both scalability AND monetization from becoming traps — the tiered model and the "sell tools not hosting" SaaS route both fall straight out of that one distinction.
- Good discipline holding the physical FM show as sacred and untouched — de-risks the entire cutover.
- Process note: initial doc writes went through the sandbox file tool and did not reach the host repo; corrected by writing through the filesystem MCP. Recorded in PROJECT_INSTRUCTIONS + HANDOFF guardrails so it doesn't recur.
