# Game City App - Concise Project Context

> **الغرض**: تقليل استهلاك التوكن في المحادثات مع الذكاء الاصطناعي من خلال توفير ملخص شامل ومكثف للمشروع.
> **Purpose**: Minimize token usage in AI conversations by providing a comprehensive and dense project summary.

## Project Overview

- **Type**: Flutter Mobile Application
- **Purpose**: Gaming community app (news, deals, community, chat).
- **Architecture**: Modular structure using GetX for state management and routing.

## Tech Stack

- **State Management**: GetX (`get`)
- **Networking**: Dio, HTTP
- **Database/Backend**: Firebase (Core, Messaging, Realtime Database)
- **Local Storage**: GetStorage, SharedPreferences
- **UI Components**: Google Fonts, CachedNetworkImage, Flutter SVG

## Core Directory Structure

- `lib/core/`: Utilities, network configs, theme, and global values.
- `lib/data/`: Models, Repositories (Data handling logic), and Data Services.
- `lib/modules/`: Feature-based modules (each contains its own controllers/views).
- `lib/routes/`: Navigation definitions (`app_pages.dart`, `app_routes.dart`).
- `lib/shared/`: Reusable widgets and shared components.

## Key Modules & Routes

- **splash**: Initial screen (`/splash`).
- **home**: Main dashboard (`/home`).
- **auth**: Login (`/login`) and Register (`/register`).
- **news**: News details with arguments (`/news-details`).
- **games**: Free game details (`/free-game-details`) and Discounted game details (`/discounted-game-details`).
- **settings**: App settings (`/settings`).

## Key Files to Reference

- [lib/main.dart](lib/main.dart): Entry point.
- [lib/routes/app_pages.dart](lib/routes/app_pages.dart): All routes and bindings.
- [lib/firebase_options.dart](lib/firebase_options.dart): Firebase configuration.
- [pubspec.yaml](pubspec.yaml): Dependencies and assets.
- [API_ENDPOINTS.md](API_ENDPOINTS.md): API documentation.

## Coding Patterns

- **GetX Pattern**: Modules usually have a `View` and a `Controller`.
- **Dependency Injection**: Bindings are used in `AppPages` to inject controllers.
- **Data Flow**:
  - **UI** (Views) -> **Controllers** (GetxController) -> **Repositories** (`lib/data/repositories/`) -> **ApiClient** (`lib/core/network/api_client.dart`) -> **Backend**.
- **Networking**: `ApiClient` uses `http` client, handles JSON encoding/decoding, and manages Bearer tokens via `GetStorage`.
- **Firebase**: Used for real-time messaging, database, and push notifications.
