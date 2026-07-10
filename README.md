# Finova — Personal Finance Manager

Finova is a Flutter personal finance manager built as a learning/interview-style
project. It demonstrates a clean, feature-first Flutter architecture using
`flutter_bloc`, `go_router` and `get_it`, without code generation.

All data currently lives in in-memory repositories, starting empty so each
user builds their own data — there is no backend yet. Settings, drafts and
auth state are persisted locally via `SharedPreferences`.

---

## Project Overview

Finova lets a user:

- Track income/expense transactions with categories, tags, receipt images and
  recurring flags.
- Search, filter, sort and paginate the transaction list.
- Set category budgets and see spend-vs-limit progress with threshold alerts.
- View dashboard/analytics charts (spending breakdown, income vs expense,
  monthly comparison) and simple, non-AI financial insights.
- Manage recurring subscriptions and see upcoming renewals.
- Scan a "receipt" (camera/gallery) and get a simulated OCR result that can be
  turned into a transaction.
- Customize theme, currency, notifications and profile details.

## Architecture

**Feature-first**, with a shared `core/` layer:

```
lib/
├── core/                 # Cross-feature building blocks
│   ├── constants/        # AppStrings
│   ├── di/               # get_it setup (injection_container.dart)
│   ├── routes/           # go_router routes + config
│   ├── services/         # SharedPreferences-backed services
│   ├── theme/            # AppColors, AppTheme, ThemeController
│   ├── utils/            # formatters, validators, greeting, chart helpers
│   └── widgets/          # SectionCard (shared across features)
└── features/
    └── <feature>/
        ├── data/
        │   ├── models/         # Plain Dart classes, no codegen
        │   └── repositories/   # In-memory data sources
        └── presentation/
            ├── bloc/           # <Feature>Bloc / Event / State
            ├── pages/          # Screens
            └── widgets/        # Feature-scoped widgets
```

Each feature follows the same shape: a repository owns the data and the
math (totals, filtering, spend-vs-budget, etc.); the bloc composes
repository calls into a `Equatable` state; pages are thin — they read bloc
state and dispatch events, they don't contain business logic.

**Shared forms across Add/Edit.** Each CRUD feature (Transactions, Budgets,
Subscriptions) has one `XForm` widget reused by both its Add and Edit page —
the caller passes an optional `initialX` to pre-fill it and decides what to do
with the submitted model via an `onSubmit` callback. Add/Edit pages share the
same bloc instance (via `BlocProvider.value`) so the underlying list refreshes
automatically when you navigate back.

**Dependency injection.** `get_it` registers repositories as lazy singletons
(one shared in-memory data source per app run) and blocs as factories (a
fresh bloc — and fresh form state — every time a screen is opened).

**Navigation.** After login, Dashboard/Transactions/Budget/Analytics/Profile
sit behind a Material 3 `NavigationBar` (`MainShell`). Each tab rebuilds
fresh (a new bloc + a fresh load) whenever it's selected, so switching tabs
always shows up-to-date data instead of a stale cached screen.

**Theming.** `AppTheme` defines the Material 3 light/dark `ThemeData`.
`ThemeController` (a `ValueNotifier<ThemeMode>`, seeded from persisted
settings at startup) is what lets the Profile screen's theme toggle update
the running app immediately.

## Features

| Module | Highlights |
|---|---|
| **Auth** | Login/Register forms with live validation, mocked auth repository, Remember Me. |
| **Splash** | Animated splash, routes to Dashboard or Login based on persisted session. |
| **Dashboard** | Balance/income/expense/savings summary, quick actions, weekly spending chart, budget overview, upcoming subscription renewals, recent transactions. |
| **Transactions** | Full CRUD, search (debounced), category/type/payment-method/date-range filters, 4-way sort, client-side pagination ("Load More"), swipe-to-delete, receipt image attach, tags, recurring flag, draft save/restore. |
| **Budget** | CRUD with category/amount/period/carry-forward, spend-vs-budget progress with 4-tier threshold colors (Healthy/Warning/Critical) and a totals summary. |
| **Analytics** | Date-range selector, expense breakdown pie chart, income vs expense line chart, monthly comparison bar chart, top spending categories, simple derived insights. |
| **Subscriptions** | CRUD with billing cycle (weekly/monthly/yearly), monthly-cost normalization, upcoming renewals. |
| **Receipt Scanner** | Camera/Gallery capture, image preview, **simulated** OCR result (clearly labeled "Sample OCR Result", fully editable), hands off to Add Transaction pre-filled. |
| **Profile** | Edit profile (name/email/phone), theme/currency/notification/biometric-placeholder preferences, Export Data (JSON preview), About, Privacy Policy, Logout. |

## Packages Used

| Package | Purpose |
|---|---|
| `flutter_bloc` | State management (Bloc pattern) |
| `equatable` | Value equality for events/states |
| `go_router` | Declarative navigation/routing |
| `get_it` | Dependency injection / service locator |
| `shared_preferences` | Local key-value persistence (settings, drafts, session) |
| `intl` | Date and currency formatting |
| `fl_chart` | Dashboard/Analytics charts (bar, line, pie) |
| `image_picker` | Camera/gallery image capture (receipts) |

No code generation (no `build_runner`/`freezed`) — every model is a plain,
hand-written Dart class.

## Setup Instructions

1. **Install Flutter** (stable channel) — see the [official install guide](https://docs.flutter.dev/get-started/install).
2. **Get dependencies**
   ```
   flutter pub get
   ```
3. **Run the app**
   ```
   flutter run
   ```
4. **Static analysis / formatting**
   ```
   dart format .
   flutter analyze
   ```
5. **Tests**
   ```
   flutter test
   ```

### Platform notes

- Camera/gallery access (Receipt Scanner, transaction receipts) requires the
  `CAMERA` permission on Android (already declared in
  `android/app/src/main/AndroidManifest.xml`) and `NSCameraUsageDescription` /
  `NSPhotoLibraryUsageDescription` on iOS (already declared in
  `ios/Runner/Info.plist`).
- Biometric login is a **placeholder toggle only** — no real biometric
  authentication is wired up yet.

## Folder Structure

```
lib/
├── core/
│   ├── constants/app_strings.dart
│   ├── di/injection_container.dart
│   ├── routes/{app_routes.dart, app_router.dart}
│   ├── services/{local_storage_service, settings_service, draft_transaction_service}.dart
│   ├── theme/{app_colors, app_theme, theme_controller}.dart
│   ├── utils/{currency_formatter, validators, greeting_helper, chart_titles}.dart
│   └── widgets/section_card.dart
├── features/
│   ├── auth/            (data/repositories, presentation/{bloc,pages,widgets})
│   ├── splash/           (presentation/pages)
│   ├── dashboard/        (presentation/{bloc,pages,widgets})
│   ├── transactions/     (data/{models,repositories}, presentation/{bloc,pages,widgets})
│   ├── budget/           (data/{models,repositories}, presentation/{bloc,pages,widgets})
│   ├── analytics/        (presentation/{bloc,pages,widgets})
│   ├── subscriptions/    (data/{models,repositories}, presentation/{bloc,pages,widgets})
│   ├── receipt_scanner/  (presentation/pages)
│   └── profile/          (presentation/{bloc,pages})
└── main.dart
```

## Screenshots

_Add screenshots here once available — Splash, Login, Dashboard, Transactions
(list + filters), Budget, Analytics, Subscriptions, Receipt Scanner, Profile._

| Splash | Login | Dashboard |
|---|---|---|
| _placeholder_ | _placeholder_ | _placeholder_ |

| Transactions | Budget | Analytics |
|---|---|---|
| _placeholder_ | _placeholder_ | _placeholder_ |

| Subscriptions | Receipt Scanner | Profile |
|---|---|---|
| _placeholder_ | _placeholder_ | _placeholder_ |
