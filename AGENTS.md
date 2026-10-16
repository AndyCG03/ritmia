# Ritmia
Flutter/Dart subscription tracker. Project root is independent from Tumbo. Do not edit sibling projects.

Read skills/subscription-engineering/SKILL.md before changing domain, persistence, quotas or reminders. Read docs/ARCHITECTURE.md and docs/FIREBASE.md for contracts.

- Installed baseline: Flutter 3.47.7, Dart 3.13.5, Android SDK 36. No global SDK/config changes.
- Production identity: assets/brand/app-icon-ai.png; preserve aubergine/lavender/coral/ivory.
- Onboarding uses local original Lottie JSON; honor reduce-motion preferences.
- User requires at least 100 brands and catalog search. Currently 214 local SVGs with pinned provenance.
- Free tier has FIVE SUBSCRIPTIONS total, including paused/archived, not five images.
- Pure domain in lib/domain, adapters in lib/data, Riverpod in lib/core, views in lib/presentation.
- Money is integer minor units. Never sum currencies. Dates use civil YYYY-MM-DD and anchor recurrence.
- Cloud writes use callables and transactional quota; billing grants cannot be written by client.
- Firestore project ritmia-app / 725132962702 / Android package app.ritmia.ritmia.
- Local config files, credentials, .local and emulator downloads are ignored.
- Local APK is the testable default until Auth/database/functions are live. Do not imply remote sync is active in local mode.
- Validate with flutter analyze, flutter test, TypeScript build/tests; integration script uses demo-ritmia emulators.
- No purchasing/deployment/billing configuration beyond user's authorized scope; never enable billing silently.
