# Shortest Path

Flutter app for the Webspark test assignment. It loads grid tasks from the API,
finds the shortest path for each one and sends the results back.

## Run

Flutter 3.47.2 (stable).

```bash
flutter pub get
flutter run
flutter test
```

API URL: `https://flutter.webspark.dev/flutter/api`

Platforms: iPhone and Android phones, portrait only.

## Architecture

Clean Architecture with Cubit (`flutter_bloc`). Dependencies point inwards:

```
lib/
  main.dart       composition root: creates the API client and repositories
  app/            App, AppRouter (navigation, builds screens with their Cubits)
  core/network/   ApiClient: timeout, cancellation, response envelope, errors
  domain/         entities, BFS path finder, repository interfaces (pure Dart)
  data/           JSON DTOs, repository implementations
  presentation/
    screens/      home, process, results, preview
    common/       theme, shared widgets, error texts
```

- Screens depend on their own navigation interface (`HomeRoutes`, ...),
  implemented by `AppRouter`.
- Dependencies are passed through constructors; no service locator.
- Packages: `flutter_bloc`, `equatable`, `http`, `shared_preferences`.

## Path finding

Breadth-first search in `domain/pathfinding/path_finder.dart`, no third-party
code. A move goes to any of the 8 adjacent free cells; a diagonal move between
two blocked cells is allowed. Both rules were confirmed by the server accepting
the results as correct. Each task is solved in a separate isolate, so the UI
stays responsive and the progress is real (no artificial delays).

## Tests

`flutter test` runs 60 unit tests for the logic where a mistake is easy to make
and hard to notice by hand: path finder, POST serialization (checked against a
request the server accepted), URL validation, response envelope parsing, cell
type priority on the preview grid. UI, navigation and Cubits were tested
manually on iOS and Android.

## Decisions and assumptions

- **Task data is not validated.** The assignment guarantees a square grid of
  2–99 cells with only `.` and `X`, and `start` / `end` inside it. If malformed
  data still breaks the calculation, the Process screen shows an error.
- **No path** (end unreachable, or `start` / `end` on `X`): sent as
  `"steps": []`, `"path": ""`; the UI shows `No path found`.
- **Path format** in the UI is the API format, `(x,y)->(x,y)`.
- **URL** is validated by format only (`http` / `https` with a host; query
  parameters are kept), saved on Start and restored on the next launch.
  Hosts with non-ASCII characters are not supported.
- **Requests** time out after 15 s. Errors are shown in a dialog with the
  server's `message` when there is one. Leaving the Process screen cancels the
  results request; the server may still have processed it.
- **Preview** supports grids up to 99×99: zoom goes up to 4 cells across the
  screen; on large grids the `(x,y)` labels appear as you zoom in.
