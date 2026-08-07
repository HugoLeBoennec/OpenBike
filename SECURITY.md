# Security Policy

## Reporting a vulnerability

**Please do not open a public issue for security problems.**

Report privately through GitHub's
[Report a vulnerability](https://github.com/HugoLeBoennec/OpenBike/security/advisories/new)
form, which opens a draft advisory visible only to the maintainers.

If that form is unavailable to you, email **hugo@leboennec.com** with
`OpenBike security` in the subject.

Please include:

- what the issue is and what an attacker could achieve,
- the affected version or commit, and the platform (Android, iOS, macOS,
  Windows, Linux),
- steps to reproduce, ideally minimal.

## What to expect

OpenBike is maintained by one person as a side project, so response times are
best-effort rather than contractual:

- **Acknowledgement** within 7 days.
- **An assessment** — whether it's accepted, and a rough fix timeline — within
  14 days.
- Credit in the advisory and `CHANGELOG.md` when a report leads to a fix,
  unless you'd rather stay anonymous.

Please give a reasonable window to ship a fix before disclosing publicly.
There is no bug bounty.

## Supported versions

Only the latest released version receives security fixes. There are no
long-term support branches.

## Scope

OpenBike is a local-first app: there is **no backend server, no account
system, and no OpenBike-operated infrastructure**. Ride, workout and profile
data live in a local SQLite database on the device. That shapes what is and
isn't in scope.

### In scope

- Exposure of locally stored ride, workout or profile data to other apps on
  the device.
- Mishandling of the Strava OAuth token, which is held in OS-backed secure
  storage (`flutter_secure_storage` → Keychain / Keystore).
- Anything causing data to leave the device that the
  [privacy policy](docs/privacy-policy.md) says does not — in particular ride
  data or location reaching crash reports.
- Weaknesses in the BLE or ANT+ handling that a hostile nearby device could
  exploit, beyond simply feeding wrong sensor numbers.
- Vulnerable third-party dependencies with a plausible path to exploitation
  here.

### Out of scope

- **Spoofed sensor readings.** BLE trainers and heart-rate straps broadcast
  unauthenticated data by design. Anyone can advertise a fake power meter, and
  OpenBike has no way to tell. Rides are not competitive records and no
  anti-cheat is claimed.
- Anything requiring a physically unlocked device, or a rooted/jailbroken OS.
- The absence of certificate pinning on outbound HTTPS. All remote traffic —
  Strava, OpenStreetMap tiles, and Sentry when enabled — uses TLS via the
  platform trust store; pinning is a deliberate non-goal for an app with no
  backend of its own.
- Findings against the closed-source `openbike_private_plugins` package.
  Report those the same way, but they are not part of this repository.
