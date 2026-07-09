---
phase: P10
title: Monetization scaffolding (OPTIONAL — not planned for initial ship)
status: BLOCKED
depends_on: [P9]
validation:
  - flutter analyze
  - flutter test
---

# P10 — Monetization (optional, blocked by default)

## Context

**Deliberately BLOCKED.** The v1 strategy is: open-source core, feature parity with
subscription apps, no paywall — privacy and openness are the differentiators. This file
exists only so that *if* the maintainer later decides to monetize, the groundwork is
pre-thought and an agent can execute without re-litigating architecture. Do not start
this phase unless the maintainer explicitly flips `status` to `NOT_STARTED`.

## Pre-decided architecture (if ever activated)

- **Open-core boundary is already the monetization boundary.** The private package seam
  from P6 (`openbike_private_plugins`) is where paid capabilities would live (e.g.
  hosted sync, OpenCoach premium features, Records advanced analytics). The public app
  never gates existing free features — no take-backs.
- **Payments**: RevenueCat (`purchases_flutter`) for iOS/Android subscription handling;
  desktop via web account/license key (RevenueCat has no desktop store coverage).
- **Entitlement check**: a single `EntitlementService` port in core (default
  implementation: everything-free), overridden by the private package. UI reads one
  provider; no `if (isPro)` sprinkled in widgets — capability flags per feature.

## Tasks (only when activated)

- [ ] `EntitlementService` port + free default implementation + provider.
- [ ] RevenueCat integration in the private package; paywall screen (public repo gets a
      generic, plugin-provided screen slot).
- [ ] Store subscription products, restore purchases, family of SKUs.
- [ ] Legal: terms of service, subscription disclosures per store rules.

## Validation

```bash
flutter analyze && flutter test
```
Public build with no private package: all features remain available, no paywall UI.

## Definition of done
N/A until activated by the maintainer.
