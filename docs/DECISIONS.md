# Clearlake Christmas Radio — Decision Log
**Locked decisions. Do not relitigate without explicit instruction from Brian.**

---

## Project & Scope
| Decision | Detail | Date |
|---|---|---|
| Project goal | Replace Zeno FM with a self-owned internet radio station + companion app. No recurring platform fees. Owned end to end. | 2026-07-17 |
| Trigger | Zeno FM raised rates. Not paying it. Build our own. | 2026-07-17 |
| Standalone project | Own repo, own docs. The **station** is personal-first, not a BlinkinLights Studio product. (Refined 2026-07-17 — see Monetization: the productized app IS a BLS product; the station is not.) | 2026-07-17 |
| Station name | "Clearlake Christmas Radio" — homage to the Clearlake Christmas Light Spectacular (20 yrs) and the original Clearlake Way roots. | 2026-07-17 |

## Hosting & Infrastructure
| Decision | Detail | Date |
|---|---|---|
| Host | Existing Unraid homelab — Lenovo TS440, Xeon E3-1245 v3 (4c/8t), 32 GB RAM. ~27 GB RAM available, ~6 GB active. Ample headroom alongside Plex/*arr stack. | 2026-07-17 |
| Uplink | 950 Mbps symmetric fiber. | 2026-07-17 |
| Capacity verdict | Peak 10–50 concurrent listeners ≈ 6–16 Mbps of 950 up (<2%). Home-direct, NO relay needed. Relay/CDN is the known scale-out path if growth ever demands it. | 2026-07-17 |
| Backbone | AzuraCast — self-hosted radio-in-a-box (Liquidsoap AutoDJ, Icecast, Web DJ, REST API, analytics). Confirmed current + actively maintained (2026). Long-running stable beta. | 2026-07-17 |
| AzuraCast deployment | Ubuntu Server VM on Unraid running AzuraCast's official Docker installer. NOT a Windows VM (pure overhead for a Linux app). NOT a native Unraid container (AzuraCast self-manages its own compose stack and would step on the *arr Docker). Isolated VM = upstream-supported, clean self-update, station update can never take down Plex. | 2026-07-17 |
| Media storage | AzuraCast library lives on the array via a mount, not the VM vdisk. | 2026-07-17 |
| Exposure | Reuse existing NginxProxyManager as the front door (`radio.{domain}`), reusing existing DNS + Let's Encrypt certs. Requires websocket/stream passthrough config for the Icecast mount. | 2026-07-17 |
| Cloudflare Tunnel | Optional / deferred. NPM already solves safe exposure. If ever used, verify Cloudflare free-tier TOS on proxying audio before committing. | 2026-07-17 |

## Cutover — Zeno Replacement
| Decision | Detail | Date |
|---|---|---|
| Zeno's role | Zeno was only ever the internet-distribution layer. Replacing it is close to a drop-in swap. | 2026-07-17 |
| Cutover mechanism | Repoint **BUTT** (Icecast source client) from Zeno's server/port/login to the new AzuraCast mount. | 2026-07-17 |
| Physical show untouched | ZaraRadio 1.6 (garage NUC) and the FM transmitter/antenna path are NOT touched in the first cut. The synced physical light show keeps running exactly as-is. | 2026-07-17 |
| Playout consolidation | Replacing ZaraRadio with AzuraCast's own AutoDJ as the single brain is DEFERRED to the off-season. First cut leaves the 20-year-proven playout alone. | 2026-07-17 |

## Product — Two Listening Modes
| Decision | Detail | Date |
|---|---|---|
| Live mode | Shared, synced AzuraCast stream: 24/7 music, show time, light show, live podcast. Non-skippable/non-reorderable by design — this is what keeps it synced to the physical lights. | 2026-07-17 |
| On-demand mode | Personal, "like Amazon Music": each listener browses the Christmas library, picks/skips/shuffles. Plex-backed (already running). Not a radio feature — a music-library app. | 2026-07-17 |
| Live cutover behavior | App watches AzuraCast live status. On-air → "LIVE NOW — Clearlake Christmas Light Spectacular" banner pulls listeners into the synced stream. Show ends → hands them back to their personal playlist. | 2026-07-17 |
| On-demand ≠ synced | On-demand cannot and need not sync to the physical lights (every listener is at a different spot). The live cutover is the mechanism for shared/synced moments. | 2026-07-17 |

## Companion App
| Decision | Detail | Date |
|---|---|---|
| Platform reach | All three: iOS + Android + web. | 2026-07-17 |
| App architecture | One codebase → three targets. PWA core + Capacitor wrap for iOS/Android store apps. | 2026-07-17 |
| Why Capacitor | Needed for proper background audio, lock-screen controls, and car-Bluetooth now-playing metadata — critical for a radio app used in cars. | 2026-07-17 |
| Integration surface | App builds against AzuraCast REST API (now-playing, listener count, song requests, live status) + Plex (on-demand library) + podcast RSS. | 2026-07-17 |
| Auth-first | The app has accounts/auth from day one. This gates the private tier, enables roster management, and makes "5 listeners or 5,000" a config question, not a rewrite. This is the one-way-door insurance. | 2026-07-17 |
| App cost floor | Apple Developer $99/yr, Google Play $25 one-time, web free. Accepted as the cost of native store presence. | 2026-07-17 |

## Podcast
| Decision | Detail | Date |
|---|---|---|
| Status | Trailer cut, never launched. Goal: record this year with Brian's two sons. | 2026-07-17 |
| Hosting direction | Self-hosted via Castopod (Docker, real RSS → also lands on Apple/Spotify). Confirm at P4. Owned end to end. | 2026-07-17 |
| App integration | App reads the podcast RSS feed. Live episodes can also run as a live takeover on the AzuraCast stream. | 2026-07-17 |

## Scalability — Tiered Model
| Decision | Detail | Date |
|---|---|---|
| Public tier | Live radio + podcast. Scales (hundreds+ on current pipe; relay/CDN path beyond). Licensable via US non-interactive statutory webcasting (SoundExchange). Advertisable if ever desired. | 2026-07-17 |
| Private tier | On-demand Plex library. Account-gated, friends & family. Interactive on-demand streaming of copyrighted music has no cheap licensing path → stays private by design. | 2026-07-17 |
| Licensing note | Flagged as design shape, not legal advice (Claude is not a lawyer). Confirm specifics before ever taking on-demand public. | 2026-07-17 |
| Audience posture | Light show is deliberately NOT advertised (avoid crowds bothering neighbors). Radio + podcast have room to grow independently of the physical show. | 2026-07-17 |

## Monetization & Product Strategy
| Decision | Detail | Date |
|---|---|---|
| Resell route | **White-label companion-app SaaS.** Sell the branded listener app + config dashboard, pointed at the customer's own station wherever hosted. Selling software/UX, NOT hosting music. Locked direction — Brian 100% on board. | 2026-07-17 |
| Liability principle | Sell tools, not hosting. Music-performance licensing stays each customer's responsibility. No managed music-hosting "AaaS" at start — that pulls licensing liability onto us. Revisit only much later with legal structure. | 2026-07-17 |
| Product branding | The productized white-label app is a **BlinkinLights Studio** product, alongside Maestromia. Cross-sell tie: Maestromia sequences the show → Clearlake app broadcasts it. Same buyer (xLights/FPP/LOR home-display crowd). | 2026-07-17 |
| Personal vs product split | The **Clearlake Christmas Radio station** (this repo) stays personal + standalone. The **resellable white-label app** is the BLS SaaS product. Two cleanly separated things. | 2026-07-17 |
| Architecture preservation | Auth-first, multi-tenant-friendly app design (locked at kickoff) preserves the SaaS path with zero rework. P3 auth/config must not preclude multi-tenant. Do NOT build tenant features early — just don't wall them out. | 2026-07-17 |
| Strategic/financial tracking | GTM, pricing, market sizing, and financial-opportunity tracking live in the separate **Business Claude** project (Brian's opportunities tracker), NOT this repo. This repo keeps only the architecture-preserving decisions. | 2026-07-17 |

## Tooling
| Decision | Detail | Date |
|---|---|---|
| Auto-commit watcher | `clearlake-watch.ps1` + `.bat` at repo root. Resident system-tray "TSR" - debounced git add/commit/push on file change. Ported from the Maestromia watcher, Christmas-themed (evergreen/gold "C", holly-red busy state). Two deliberate differences: NO static-deploy step (no host yet - wire at P3+ when the PWA lands), and it commits locally with a clear notice if no git remote is configured (rather than throwing push failures). Watch excludes .git/node_modules/dist/build/media. | 2026-07-17 |

---

## Open / Pending Decisions
- Music library scope + source for AzuraCast import (size, format, metadata quality).
- Domain/subdomain to use for `radio.{domain}` (which existing domain, or new).
- App visual identity / station imaging (BRANDING session — logo, colors, "on-air" look).
- Auth provider choice (self-hosted vs managed — decide at P3).
- Castopod vs alternative podcast host — confirm at P4.
- Whether/when to consolidate ZaraRadio → AzuraCast AutoDJ (off-season revisit).
- Off-season: whether to ever take the public tier truly public (licensing spin-up).
- SaaS productization specifics (pricing, packaging, launch) — owned in Business Claude, not here.
