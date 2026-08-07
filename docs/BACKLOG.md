# Clearlake Christmas Radio — Backlog
**Last updated:** 2026-08-07 (P2 partial — music library imported into AzuraCast. BUTT repoint pending.)

---

## Roadmap
**North star: Clearlake Christmas Radio live and self-owned for the 2026 season — Zeno FM fully retired, with the companion app in listeners' hands.**

Phase gates are hard. Do not advance a phase until its gate passes.

---

### P0 — Infra ✅ COMPLETE
**Gate: AzuraCast streaming music, heard on a second device on the LAN.**
- ✅ Create Ubuntu Server VM on Unraid (2 vCPU / 4 GB / 50 GB, SeaBIOS).
- ✅ Mount array share for the media library (`/mnt/music` via 9p, persistent in fstab).
- ✅ Run AzuraCast official Docker installer inside the VM.
- ✅ Create the station, set up an Icecast mount + AutoDJ.
- ✅ Drop in a handful of test tracks, confirm AutoDJ plays.
- ✅ **Gate:** stream heard on a second LAN device. (`http://10.4.1.2/listen/clearlake_christmas_radio/radio.mp3`)

---

### P1 — Exposure + Capacity ← NEXT
**Gate: an external listener connects over the internet; concurrent load verified.**
- ⬜ Add NginxProxyManager host `radio.clearlakechristmasradio.com` → `10.4.1.2` (port 80).
- ⬜ Configure websocket / stream passthrough for the Icecast mount (`/radio.mp3`).
- ⬜ Confirm Let's Encrypt cert serves cleanly on `radio.clearlakechristmasradio.com`.
- ⬜ Update AzuraCast Site Base URL to `https://radio.clearlakechristmasradio.com`.
- ⬜ Load-test simulated concurrent streams vs. the 950 up pipe (target 50+, headroom check).
- ⬜ (If Cloudflare Tunnel considered) verify free-tier audio TOS first.
- ⬜ **Gate:** external listener connects + N-concurrent load holds.

---

### P2 — Content + Zeno Cutover
**Gate: Zeno FM fully replaced; FM path untouched.**
- ✅ Import the full music library into AzuraCast (614 files indexed from `/mnt/music`).
- ⬜ Repoint **BUTT** from Zeno → AzuraCast mount (streamer creds from AzuraCast → Streamers/DJs).
- ⬜ Confirm stream is live and receivable from AzuraCast after BUTT repoint.
- ⬜ Confirm ZaraRadio + FM transmitter path completely undisturbed.
- ⬜ **Gate:** Zeno decommissioned, station fully self-hosted.

Note: AutoDJ/playlist setup is NOT a priority. ZaraRadio remains the playout brain. AzuraCast library is a fallback.

---

### P3 — App Core (Web / PWA) + Auth
**Gate: app works in-browser and installs on a phone; accounts functional.**
- ⬜ Mockup app shell (station identity, now-playing, transport).
- ⬜ Live stream player: play/pause, now-playing from AzuraCast API, listener count.
- ⬜ Auth scaffolding (accounts from day one — gates the private tier later).
- ⬜ (Forward-compat) Design auth/config so multi-tenant white-labeling later needs no rewrite. Do NOT build tenant features now — just don't preclude them. (Ties to SaaS route — see DECISIONS: Monetization.)
- ⬜ PWA manifest + installability.
- ⬜ **Gate:** browser + phone-installed, auth works.

---

### P4 — On-Demand + Podcast + Live Cutover
**Gate: personal playlist plays; live cutover banner works; podcast in-app.**
- ⬜ Plex integration: browse/play the Christmas library (private / account-gated).
- ⬜ On-demand transport: pick / skip / shuffle ("like Amazon Music").
- ⬜ Podcast: stand up Castopod (or confirmed alternative), publish feed, read it in-app.
- ⬜ LIVE-NOW cutover: app watches AzuraCast live status → banner → pulls into synced stream → hands back after.
- ⬜ **Gate:** on-demand + live cutover + podcast all working together.

---

### P5 — Native Wrap (Capacitor)
**Gate: plays in the car over Bluetooth with correct now-playing metadata.**
- ⬜ Wrap PWA with Capacitor → iOS + Android builds.
- ⬜ Background audio + lock-screen controls.
- ⬜ Car-Bluetooth now-playing metadata.
- ⬜ Store setup (Apple Dev $99/yr, Play $25 one-time).
- ⬜ **Gate:** real car test, metadata on the head unit.

---

### P6 — Light-Show Sync (someday / optional)
**The hard, optional win. Not required for launch.**
- ⬜ Investigate taming the stream-vs-physical-lights delay for tuned-in listeners.
- ⬜ Scope only after the station + app are live and stable.

---

## Parking Lot (post-launch / off-season)
- **White-label companion app SaaS (BLS product)** — resell angle LOCKED as SaaS: sell the app + config dashboard, not music hosting; branded under BlinkinLights Studio; cross-sell with Maestromia. Strategic/GTM/pricing/financials tracked in the **Business Claude** project, not here. Build-side obligation: keep P3 auth/config multi-tenant-capable (above).
- **ZaraRadio / LOR S6 reliability + two-NUC strategy (STRATEGIC session required)** — ZaraRadio is the master scheduler for the entire show evening: radio stops 1 min before each show, starts 1 min after. A ZaraRadio crash breaks the whole night's timing. LOR S6 and ZaraRadio are tightly coupled — splitting them across two machines creates a sync problem on top of a reliability problem. BUTT is the only piece that cleanly moves to a separate machine. Investigate: (1) process watchdog to auto-restart ZaraRadio on crash, (2) UPS on the show NUC, (3) whether LOR S6 resource load during shows is destabilizing ZaraRadio. Full two-NUC FM architecture needs a dedicated strategic session before any hardware is purchased.
- Playout consolidation: ZaraRadio → AzuraCast AutoDJ as single brain.
- Public-tier go-public: statutory webcasting licensing spin-up (SoundExchange) if ever desired.
- Station imaging / sweepers / branded IDs for the live stream.
- Advertising/sponsor slots (only if going public).
