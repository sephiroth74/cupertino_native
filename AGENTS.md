# Overview
- This project is a Flutter plugin that exposes native macOS Liquid Glass widgets to Flutter via platform channels.
- Primary Dart widget wrappers live in `lib/components`.
- Native macOS implementation is in `macos/Classes`, with the plugin entry point at `macos/Classes/CupertinoNativePlugin.swift`.
- Example pages live in `example/lib/demos` and demonstrate supported widgets.
- A good workflow is: add/modify widget wrapper → update channel payloads → add example page → run `flutter analyze` and tests.

# Key conventions
- New widgets should follow the existing pattern: one Dart file/class per widget, plus a matching example page.
- Keep the Flutter API idiomatic and fall back gracefully on non-macOS platforms when possible.
- Use existing widgets as templates for naming, constructor styles, and documentation.
- When changing public widget APIs, also update channel data definitions in `lib/channel/params.dart` and any macOS factory/view code.

# File structure guidance
- `lib/components/` contains widget wrappers and Flutter-facing types.
- `lib/channel/` contains method-channel argument and response models.
- `lib/model/` and `lib/style/` define shared enums and styles.
- `example/lib/demos/` contains demo pages for each widget.
- `test/` contains package-level Dart tests.
- `example/integration_test/` contains example app integration tests.

# Build and verification
- Run `flutter analyze` from the repository root.
- Run `flutter test` for package tests.
- Run the example on macOS via `cd example && flutter run`.
- `README.md` and `example/README.md` document macOS 11+ and Xcode 26 beta prerequisites.
