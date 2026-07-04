# BiteTrack Mobile

**Track your next bite.** Cross-platform Flutter app for real-time mobile vendor discovery and tracking.

Built with **Flutter**, **BLoC**, **Clean Architecture**, **get_it + injectable**, and **Dio**.

---

## Features (scaffold)

| Area | Status |
|------|--------|
| **Auth** | Login, register, token persistence, `/me` bootstrap |
| **Navigation** | go_router with auth-aware redirects |
| **Config** | Per-environment bundled env files |
| **Architecture** | Clean Architecture (data / domain / presentation) |

Coming next: live vendor map, real-time tracking, favorites, notifications.

---

## Tech stack

- **Framework:** Flutter 3.x (Android + iOS)
- **State:** flutter_bloc + bloc
- **DI:** get_it + injectable
- **Network:** Dio (interceptors, token attach)
- **Storage:** SharedPreferences (tokens), Hive (cache scaffold)
- **Routing:** go_router
- **Env:** flutter_dotenv

---

## Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (stable channel)
- Android Studio / Xcode for emulators
- Running [bitetrack-api](../bitetrack-api) backend (Docker infra + `npm run dev`)

> **Note:** If `flutter` fails with "Unable to find git in your PATH", add Git to PATH or run:
> `git config --global --add safe.directory C:/src/flutter` (adjust path to your Flutter SDK).

---

## Environment files

| File | Purpose |
|------|---------|
| `env/env.sample` | Template (committed) |
| `env/env.development` | Local dev — `cp env/env.sample env/env.development` (git-ignored) |
| `env/env.staging` | Staging API URLs (git-ignored) |
| `env/env.production` | Production API URLs (git-ignored) |

Select environment at build/run time:

```bash
flutter run --dart-define=ENV=development   # default
flutter run --dart-define=ENV=staging
flutter run --dart-define=ENV=production
```

**Android emulator:** `API_BASE_URL=http://10.0.2.2:4000/api/v1` (maps to host `localhost`).

**iOS simulator / physical device:** replace with your machine's LAN IP, e.g. `http://192.168.1.10:4000/api/v1`.

---

## Quick start

```bash
git clone <repo-url> bitetrack-mobile
cd bitetrack-mobile
cp env/env.sample env/env.development
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run
```

Ensure the API is running (`docker compose up -d` + `npm run dev` in `bitetrack-api`).

---

## Project structure

```
lib/
├── app/                 # bootstrap, MaterialApp shell
├── core/
│   ├── config/          # EnvConfig
│   ├── di/              # get_it + injectable
│   ├── error/           # Failure types
│   ├── network/         # Dio client + interceptors
│   ├── router/          # go_router
│   ├── storage/         # TokenStorage
│   └── theme/           # AppTheme
├── features/
│   ├── auth/
│   │   ├── data/        # DTOs, remote datasource, repo impl
│   │   ├── domain/      # entities, repo contract, use-cases
│   │   └── presentation/# BLoC, pages
│   └── home/            # placeholder post-login screen
└── main.dart
```

Each new feature follows the same **data → domain → presentation** layout with its own BLoC.

---

## Code generation

After changing `@injectable` annotations:

```bash
dart run build_runner build --delete-conflicting-outputs
```

Watch mode during development:

```bash
dart run build_runner watch --delete-conflicting-outputs
```

---

## Testing

```bash
flutter test
flutter analyze
```

Target: **80%+ coverage** on use-cases and BLoCs (per BRD).

---

## Git commit convention

Conventional Commits — one logical change per commit:

```
feat(auth): add login page with BLoC
chore: initialize Flutter project
docs: add README
```

---

## License

Proprietary — BiteTrack Engineering.
