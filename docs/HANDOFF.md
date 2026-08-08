# Clearlake Christmas Radio — Handoff

## ▶ START HERE — Session Primer
*Fresh session? Read this block first. It exists to orient you in under a minute — written by a prior instance for the next one.*

**What this is:** Brian's self-hosted internet radio station + companion app, replacing Zeno FM (which raised rates), owned end to end. The **station is personal/standalone** (this repo). A **white-label version of the app is a separate BlinkinLights Studio SaaS product** — that money/GTM side is tracked in the *Business Claude* project, NOT here.

**⚠️ COLD-START WARNING — Knowledge cache is stale. Filesystem MCP is truth.**
The knowledge source `memory.md` injected at session start is a background summary only — it does NOT reflect current phase, recent decisions, or session state. Always read the live repo docs via the filesystem MCP first. The `memory.md` is orientation context, not a substitute for the docs below.

**Do this first, before responding:**
1. Read in order: `PROJECT_INSTRUCTIONS.md` → `SESSION_LOG.md` (top entry) → `BACKLOG.md` → `DECISIONS.md` → the rest of this file.
2. Post the ready confirmation (format below). Ask nothing until it's posted.

```
Good [morning/evening] Brian.

Project: Clearlake Christmas Radio
Phase: PX — [name] ([status])
Last session: [one line]
Top priority: [top backlog item]
Open gates: [current phase gate]

Ready.
```

**Locked stack — do NOT re-litigate (see DECISIONS):**
Unraid homelab (TS440, 32 GB, 950 symmetric) → **Ubuntu VM** (`azuracast`, `10.4.1.2`) → **AzuraCast** behind the existing **NginxProxyManager** → **BUTT** repointed off Zeno. App = **auth-first PWA + Capacitor** (web/iOS/Android). Two modes: **LIVE** (AzuraCast, synced to the lights) + **ON-DEMAND** (Plex, private). Podcast via **Castopod**. Home-direct, no relay needed.

**🔴 Hard guardrails — violate none:**
- **The FM transmitter + ZaraRadio 1.6 (garage NUC) are SACRED.** They keep the physical light show synced. Do not touch, or propose touching, without a flagged, separately-gated discussion.
- **Write docs via the filesystem MCP tools ONLY.** The native file-creation tools land in a sandbox and never reach this repo.
- **Phase gates are hard.** Never advance a phase until its gate passes.
- **Discuss before building. Prove in isolation before exposing or cutting over.**
- Claude has Unraid MCP + SSH to the host; **no shell to Brian's Windows machine** (git/remotes are Brian's).

---

**Date:** 2026-08-07
**Phase:** P2 — Zeno Cutover (in progress — BUTT repoint remaining)
**Last session:** P1 COMPLETE — NPM proxy + HTTPS cert + AutoDJ fix + 50-concurrent load test passed. External listener confirmed from phone on mobile data.

---

## Where We Are

P1 gate is passed. The station is publicly reachable over HTTPS, AutoDJ is running the full 614-track library, and the stream has been confirmed from a real external device.

**Public stream URL:** `https://radio.clearlakechristmasradio.com/live` (NPM redirect → full listen URL)
**Full listen URL:** `https://radio.clearlakechristmasradio.com/listen/clearlake_christmas_radio/radio.mp3`

**AzuraCast instance:**
- VM: `azuracast` at `10.4.1.2`
- Web UI: `http://10.4.1.2` (admin: `bbutson73@gmail.com`)
- Stream URL (internal): `http://10.4.1.2/listen/clearlake_christmas_radio/radio.mp3`
- Compose files: `/tmp/docker-compose.yml` + `/tmp/docker-compose.override.yml`
- AzuraCast Docker volumes in `/var/lib/docker/volumes/azuracast_*`
- Music library mount: `/mnt/music` (9p VirtFS from Unraid array, persistent in `/etc/fstab`)
- Music inside container: `/var/azuracast/storage/music` (bind-mounted via override file)
- Station media storage: `Local: /var/azuracast/storage/music` (614 audio files indexed)
- Liquidsoap `media_path`: `/var/azuracast/storage/music` ✅ (verified after fix)

**NPM proxy host:**
- Domain: `radio.clearlakechristmasradio.com` → `10.4.1.2:80`
- SSL: Let's Encrypt cert (npm-16, expires 2026-11-06, auto-renews)
- Custom nginx: `proxy_buffering off; proxy_read_timeout 3600s;`
- Custom location `/live`: `return 302 https://radio.clearlakechristmasradio.com/listen/clearlake_christmas_radio/radio.mp3;`

**DNS (Cloudflare):**
- `radio.clearlakechristmasradio.com` → `199.187.202.175` (A record, DNS only / grey cloud)

**AutoDJ:**
- Running. `Christmas Rotation` playlist has all 614 tracks. 24/7 schedule active.
- AutoDJ is a fallback only — ZaraRadio via BUTT will be the source when connected.

---

## Next Session — P2 BUTT Repoint

The only remaining P2 task is repointing BUTT on the garage NUC from Zeno to AzuraCast.

**BUTT settings to change:**
- Server/Host: `radio.clearlakechristmasradio.com`
- Port: `80`
- Mount: `/radio.mp3`
- Type: Icecast
- Source username: `source`
- Source password: visible in AzuraCast Station → Broadcasting → Icecast → "Source" credentials

**After repoint:**
1. Confirm stream shows as live in AzuraCast dashboard (listener count > 0, "On the Air" green).
2. Confirm the public stream URL plays the ZaraRadio feed (not AutoDJ).
3. Confirm ZaraRadio + FM transmitter path completely undisturbed.
4. P2 Gate: Zeno decommissioned.

---

## Do-Not-Touch (guardrails)
- **ZaraRadio 1.6 on the garage NUC** — the 24/7 playout brain. Leave it running.
- **The FM transmitter + antenna path** — sacred. Any change gets flagged and gated separately.
- **The existing *arr Docker stack + Plex** — AzuraCast VM is isolated specifically so we never disturb these.
- **`/tmp/docker-compose.override.yml`** — do not delete; it's what mounts the music library into the container.

---

## Key Reminders
- After any AzuraCast storage location change, always run `azuracast_cli azuracast:radio:restart 1` to regenerate Liquidsoap config with the correct `media_path`.
- NPM compose files are on the **Unraid host** (not the AzuraCast VM). SSH context matters.
- AzuraCast compose files live in `/tmp` on the **VM** — always `sudo docker compose` from there.
- Cloudflare A record must stay **grey cloud (DNS only)** — proxied will break audio streams.
- Write docs via the filesystem MCP tools only.

## Commit & Push — Master Watcher (added 2026-07-30)

Auto commit + push for this repo is handled by the **Master Projects Watcher**
(`C:\Projects\_watcher\master-watch.ps1`, launched at logon), which watches every
git repo under `C:\Projects`. The old per-repo watchers are retired.

- On save, after ~8s of quiet: `git add -A` -> `git commit -m "auto: <timestamp>"` -> `git push`.
- One shared tray icon; this repo shows its own colored/lettered icon + a repo-named
  toast on each push. Activity log: `C:\Projects\_watcher\master-watch.log`.
- Guards: skips while a manual git op is in progress (merge/rebase/lock); unstages +
  warns on any file over 25MB (never auto-pushes large/secret blobs); recovers on buffer overflow.
- Routine edits need no manual git. Still make intentional manual commits for milestones
  — the `auto:` commits are a safety net, not a substitute for real history.
- Shared standards: this repo's root `CLAUDE.md` imports `C:\Projects\_shared\Claude.md`.
