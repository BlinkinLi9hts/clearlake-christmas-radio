# Clearlake Christmas Radio — Handoff

## ▶ START HERE — Session Primer
*Fresh session? Read this block first. It exists to orient you in under a minute — written by a prior instance for the next one.*

**What this is:** Brian's self-hosted internet radio station + companion app, replacing Zeno FM (which raised rates), owned end to end. The **station is personal/standalone** (this repo). A **white-label version of the app is a separate BlinkinLights Studio SaaS product** — that money/GTM side is tracked in the *Business Claude* project, NOT here.

**Do this first, before responding:**
1. Read in order: `PROJECT_INSTRUCTIONS.md` → `SESSION_LOG.md` (top entry) → `BACKLOG.md` → `DECISIONS.md` → the rest of this file.
2. Post the ready confirmation (format below). Ask nothing until it's posted.

```
Good morning Brian.

Project: Clearlake Christmas Radio
Phase: PX — [name] ([status])
Last session: [one line]
Top priority: [top backlog item]
Open gates: [current phase gate]

Ready.
```

**Locked stack — do NOT re-litigate (see DECISIONS):**
Unraid homelab (TS440, 32 GB, 950 symmetric) → **Ubuntu VM** → **AzuraCast** behind the existing **NginxProxyManager** → **BUTT** repointed off Zeno. App = **auth-first PWA + Capacitor** (web/iOS/Android). Two modes: **LIVE** (AzuraCast, synced to the lights) + **ON-DEMAND** (Plex, private). Podcast via **Castopod**. Home-direct, no relay needed.

**🔴 Hard guardrails — violate none:**
- **The FM transmitter + ZaraRadio 1.6 (garage NUC) are SACRED.** They keep the physical light show synced. Do not touch, or propose touching, without a flagged, separately-gated discussion.
- **Write docs via the filesystem MCP tools ONLY.** The native file-creation tools land in a sandbox and never reach this repo.
- **Phase gates are hard.** Never advance a phase until its gate passes.
- **Discuss before building. Prove in isolation before exposing or cutting over.**
- Claude has Unraid MCP + SSH to the host; **no shell to Brian's Windows machine** (git/remotes are Brian's).

**Right now:** Phase **P0 — Infra (not started)**. Immediate next action → decide the domain for `radio.{domain}`, then stand up the Ubuntu VM + AzuraCast and hit the P0 gate (stream heard on a second LAN device). Full task order is in the P0 section of `BACKLOG.md` and below.

---

**Date:** 2026-07-17
**Phase:** P0 — Infra (not started)
**Last session:** Project kickoff — full end-to-end architecture locked, docs scaffolded, SaaS resell route locked.

---

## Where We Are
Architecture is fully locked (see `DECISIONS.md`). Nothing built yet. The repo + docs exist; infra is untouched. The existing Zeno/ZaraRadio/FM setup is still running exactly as before — we have not touched anything live.

---

## Next Session — First Tasks in Order (P0 — Infra)

1. **Decide the domain/subdomain** for `radio.{domain}` (which existing domain, or a new one). Needed before NPM in P1, but good to settle early.
2. **Create the Ubuntu Server VM** on Unraid — 2 vCPU / 4 GB RAM / ~40–60 GB vdisk to start.
3. **Mount an array share** into the VM for the media library (keep the library off the vdisk).
4. **Run AzuraCast's official Docker installer** inside the VM (Linux shell familiarity assumed).
5. **Create the station** — Icecast mount + AutoDJ, drop in a few test tracks.
6. **P0 Gate:** play the stream on a second device on the LAN. Do not proceed to P1 until this passes.

---

## Open Questions (settle before or during P0)
- Which domain for `radio.{domain}`?
- Music library: where does it live now, how big, what format/metadata quality? (Drives the P2 import.)
- Confirm the Ubuntu VM sizing is comfortable (can grow — start modest).

---

## Do-Not-Touch (guardrails)
- **ZaraRadio 1.6 on the garage NUC** — the 24/7 playout brain. Leave it running.
- **The FM transmitter + antenna path** — this is what keeps the physical light show synced. Sacred. Any change that could affect it gets flagged and gated separately.
- **The existing *arr Docker stack + Plex** — the AzuraCast VM is isolated specifically so we never disturb these.

---

## Key Reminders
- Prove in isolation (LAN) before exposing to the internet.
- Gates are hard — no skipping.
- Claude has Unraid MCP + SSH to the host, but NO shell to Brian's Windows machine (git remotes / Windows plumbing are Brian's).
- Write docs via the filesystem MCP tools (they reach the host); the native file tools land in a sandbox and won't appear in the repo.
- Cutover from Zeno is a repoint of BUTT — a swap, not a rebuild. The scary part (bandwidth, exposure) is already de-risked by the 950 pipe + existing NginxProxyManager.
- Resell/SaaS path is preserved via a P3 forward-compat line (keep auth multi-tenant-capable). Strategy itself lives in Business Claude.


## Commit & Push -- Master Watcher (added 2026-07-30)

Auto commit + push for this repo is handled by the **Master Projects Watcher**
(`C:\\Projects\\_watcher\\master-watch.ps1`, launched at logon), which watches every
git repo under `C:\\Projects`. The old per-repo watchers are retired.

- On save, after ~8s of quiet: `git add -A` -> `git commit -m "auto: <timestamp>"` -> `git push`.
- One shared tray icon; this repo shows its own colored/lettered icon + a repo-named
  toast on each push. Activity log: `C:\\Projects\\_watcher\\master-watch.log`.
- Guards: skips while a manual git op is in progress (merge/rebase/lock); unstages +
  warns on any file over 25MB (never auto-pushes large/secret blobs); recovers on buffer overflow.
- Routine edits need no manual git. Still make intentional manual commits for milestones
  -- the `auto:` commits are a safety net, not a substitute for real history.
- Shared standards: this repo's root `CLAUDE.md` imports `C:\\Projects\\_shared\\Claude.md`.

> Note: this repo has **no live deploy yet** (still P0) -- pushes just back it up to GitHub; nothing goes live.
