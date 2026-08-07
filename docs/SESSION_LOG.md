# Clearlake Christmas Radio — Session Log

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
- At P2: import full music library, build proper playlists, repoint BUTT from Zeno.

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
