# 01 · Getting started

## Prerequisites

- **Flutter** 3.27 or newer (`flutter --version`)
- **Dart** 3.6 or newer (bundled with Flutter)
- A device or emulator (Android/iOS)
- A running [Stockr API](https://github.com/ThQMS/Stockr-api) instance (or a deployed URL)

Verify your toolchain:

```sh
flutter doctor
```

## Install & generate code

This scaffold does **not** commit generated files (Drift, Riverpod, Injectable).
Generate them after cloning:

```sh
flutter pub get
dart run build_runner build --delete-conflicting-outputs
```

Use `watch` instead of `build` while developing:

```sh
dart run build_runner watch --delete-conflicting-outputs
```

## Point the app at the API

The base URL is a **compile-time** constant read from `API_BASE_URL`
(see [`lib/core/network/dio_client.dart`](../lib/core/network/dio_client.dart)).
It defaults to `https://api.example.com`, so you must override it:

```sh
# Android emulator -> host machine
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8080

# iOS simulator -> host machine
flutter run --dart-define=API_BASE_URL=http://localhost:8080

# Physical device on the same LAN
flutter run --dart-define=API_BASE_URL=http://192.168.0.10:8080
```

> Prefer keeping defines out of shell history by using a `--dart-define-from-file`
> JSON in larger setups.

## Build a release APK

```sh
flutter build apk --release --dart-define=API_BASE_URL=https://your-api.example.com
```

The artifact lands in `build/app/outputs/flutter-apk/app-release.apk`.

## Troubleshooting

| Symptom | Fix |
|---------|-----|
| `*.g.dart` not found | Run the `build_runner` step above |
| Network calls hang on emulator | Use `10.0.2.2`, not `localhost` |
| Scanner shows black screen | Grant camera permission to the app |
