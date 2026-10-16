---
name: subscription-engineering
description: Build and review Ritmia subscription tracking in Flutter and Firebase, with recurrence correctness, transactional quotas and reliable reminders.
---
Use when changing this app's domain, persistence, reminders or billing boundary. Keep UI concerns out of domain rules.

- Use anchor-based civil-date recurrence: January 31 becomes February 28/29 then March 31. Keep money in integer minor units; never combine currencies.
- Count all stored records toward Free's five-slot limit, including paused and archived records. Serialize local writes and enforce cloud creation quotas in a Firestore transaction. Read plan grants only from server-owned billing documents.
- Use revision checks on edits/deletes to reject stale concurrent changes. Preserve records after downgrade; allow edits/deletes but reject creation while over quota.
- A cancellation URL opens a provider website. It must never mark an actual external contract canceled automatically. Only the user changes tracking status.
- Derive reminders from recurrence/end/trial dates. Skip past events and inactive records. Reconcile schedules after edits/deletes/sign-out. Bound local notifications under iOS's pending limit.
- Email delivery requires explicit consent, verified address and configured provider. Dedupe server queue writes transactionally; distinguish enqueued from delivered. Never include secrets in tracked files.
- Test month ends, leap years, currencies, quota concurrency, revision conflicts and reminder deduplication. Run Flutter analyze/tests/web build and TypeScript build/tests.
- Read docs/ARCHITECTURE.md and docs/FIREBASE.md when changing cloud schema or deployment. Do not deploy, charge users or claim payment integration is live without the configured infrastructure.
