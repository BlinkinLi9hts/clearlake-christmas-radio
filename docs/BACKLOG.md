# Clearlake Christmas Radio — Backlog
**Last updated:** 2026-07-17 (Kickoff — architecture locked; SaaS resell route locked (white-label app, BLS-branded, tracked in Business Claude). Awaiting P0 infra start.)

---

## Roadmap
**North star: Clearlake Christmas Radio live and self-owned for the 2026 season — Zeno FM fully retired, with the companion app in listeners' hands.**

Phase gates are hard. Do not advance a phase until its gate passes.

---

### P0 — Infra ← NEXT
**Gate: AzuraCast streaming music, heard on a second device on the LAN.**
- ⬜ Create Ubuntu Server VM on Unraid (2 vCPU / 4 GB / ~40–60 GB to start).
- ⬜ Mount array share for the media library (not on the VM vdisk).
- ⬜ Run AzuraCast official Docker installer inside the VM.
- ⬜ Create the station, set up an Icecast mount + AutoDJ.
- ⬜ Drop in a handful of test tracks, confirm AutoDJ plays.
- ⬜ **Gate:** play the stream on another LAN device.

---

### P1 — Exposure + Capacity
**Gate: an external listener connects over the internet; concurrent load verified.**
- ⬜ Add NginxProxyManager host `radio.{domain}` → AzuraCast VM.
- ⬜ Configure websocket / stream passthrough for the Icecast mount.
- ⬜ Confirm Let's Encrypt cert serves cleanly.
- ⬜ Load-test simulated concurrent streams vs. the 950 up pipe (target 50+, headroom check).
- ⬜ (If Cloudflare Tunnel considered) verify free-tier audio TOS first.
- ⬜ **Gate:** external listener connects + N-concurrent load holds.

---

### P2 — Content + Zeno Cutover
**Gate: Zeno FM fully replaced; podcast/live takeover works and returns to auto; FM path untouched.**
- ⬜ Import the full Christmas library into AzuraCast; verify metadata + artwork.
- ⬜ Build playlists + scheduling to match current 24/7 rotation feel.
- ⬜ Repoint **BUTT** from Zeno → AzuraCast mount (streamer creds).
- ⬜ Test live takeover: go on-air, confirm stream switches, confirm return to AutoDJ after.
- ⬜ Confirm ZaraRadio + FM transmitter path completely undisturbed.
- ⬜ **Gate:** Zeno decommissioned, station fully self-hosted.

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
- Playout consolidation: ZaraRadio → AzuraCast AutoDJ as single brain.
- Public-tier go-public: statutory webcasting licensing spin-up (SoundExchange) if ever desired.
- Station imaging / sweepers / branded IDs for the live stream.
- Advertising/sponsor slots (only if going public).
