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
**Phase:** P1 — Exposure (not started)
**Last session:** P2 partial — music library imported (614 files). AutoDJ not a priority; ZaraRadio remains the playout brain. BUTT repoint (Zeno cutover) still pending.

---

## Where We Are

AzuraCast is live on the LAN. P0 gate passed. Music library imported. The existing Zeno/ZaraRadio/FM setup is still running — we have not touched it.

**AzuraCast instance:**
- VM: `azuracast` at `10.4.1.2`
- Web UI: `http://10.4.1.2` (admin: `bbutson73@gmail.com`)
- Stream URL: `http://10.4.1.2/listen/clearlake_christmas_radio/radio.mp3`
- Compose files: `/tmp/docker-compose.yml` + `/tmp/docker-compose.override.yml`
- AzuraCast Docker volumes in `/var/lib/docker/volumes/azuracast_*`
- Music library mount: `/mnt/music` (9p VirtFS from Unraid array, persistent in `/etc/fstab`)
- Music inside container: `/var/azuracast/storage/music` (bind-mounted via override file)
- Station media storage: `Local: /var/azuracast/storage/music` (614 audio files indexed)

**Music library note:**
Full library at `/mnt/music` inside the VM — 614 audio files indexed by AzuraCast (MP3 + FLAC mix; Windows metadata artifacts skipped). AutoDJ NOT in use — ZaraRadio is the playout brain. AzuraCast library is a fallback/future capability. To add new music: add to the Unraid share → AzuraCast picks it up on the next scan (or trigger manually via Media → Music Files).

**Critical infrastructure note:**
The docker-compose files live in `/tmp`. Always `cd /tmp` before any `docker compose` commands. The `docker-compose.override.yml` there is what exposes `/mnt/music` to the container — do not delete it.

---

## Next Session — P1 Tasks in Order

1. **Add NPM host** `radio.clearlakechristmasradio.com` → `10.4.1.2:80` with websocket/stream passthrough.
2. **Let's Encrypt cert** — should auto-provision via existing NPM setup.
3. **Update AzuraCast Site Base URL** to `https://radio.clearlakechristmasradio.com` (Admin → System Settings).
4. **External listener test** — confirm stream works from outside the LAN.
5. **Load test** — simulate 50 concurrent streams, verify headroom.
6. **P1 Gate:** external listener connects + load holds.

Then P2 remaining: repoint BUTT from Zeno → AzuraCast.

---

## Do-Not-Touch (guardrails)
- **ZaraRadio 1.6 on the garage NUC** — the 24/7 playout brain. Leave it running.
- **The FM transmitter + antenna path** — sacred. Any change gets flagged and gated separately.
- **The existing *arr Docker stack + Plex** — AzuraCast VM is isolated specifically so we never disturb these.
- **`/tmp/docker-compose.override.yml`** — do not delete; it's what mounts the music library into the container.

---

## Key Reminders
- Prove in isolation (LAN) before exposing to the internet. ✅ Done.
- Gates are hard — no skipping.
- Claude has Unraid MCP + SSH to the host, but NO shell to Brian's Windows machine.
- Write docs via the filesystem MCP tools only.
- Cutover from Zeno = repoint BUTT. ZaraRadio stays the brain.
- AzuraCast compose files live in `/tmp` — always run `docker compose` from there.

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
