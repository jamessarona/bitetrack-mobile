# BiteTrack Mobile — Agent Guide

You are working on the **BiteTrack** Flutter app: customer discovery + seller business management.

**Tagline:** Track your next bite.

## Read first

| Document | Purpose |
|----------|---------|
| [`docs/BITETRACK_PRODUCT.md`](docs/BITETRACK_PRODUCT.md) | Full product spec, scope, terminology |
| [`README.md`](README.md) | Flutter setup, env files, scripts |

## Backend

Sibling repo: **bitetrack-api** — run locally via Docker + `npm run dev` on port 4000.

## Product truths (do not re-derive each session)

- **Business**, not vendor profile — one user can own **many businesses**.
- No `VENDOR` user role — seller = user with `businessCount > 0`.
- **Go live** / **Stop selling** on business detail (Settings → My businesses).
- **Map:** `flutter_map` + OpenStreetMap — **not** Google Maps.
- **Uploads:** S3 presigned URLs via API — no local file upload path.
- Seller onboarding lives on **My businesses**, not Discover home.

## Architecture

```
lib/features/{feature}/
├── data/
├── domain/
└── presentation/
```

- **State:** BLoC where used; repository pattern for API calls
- **DI:** get_it + injectable
- **Routing:** go_router
- **Network:** Dio

## When implementing

1. Follow `docs/BITETRACK_PRODUCT.md` for scope and UX wording.
2. Keep diffs minimal; match existing feature structure.
3. Do not add `GOOGLE_MAPS_API_KEY` or local upload flows.
4. Future features (payments, FCM, Apple login) only when explicitly requested.

## MCP / future

This doc + `docs/BITETRACK_PRODUCT.md` + `.cursor/rules/bitetrack-product.mdc` replace the original `.docx` BRD for AI context.
