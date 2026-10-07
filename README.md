# Billa Mobile

Flutter companion to the Billa web app: documents, customers, payments and receivables for small businesses in Rwanda.

## Running

The API address is passed at build time and is never hardcoded:

```bash
flutter run --dart-define=API_BASE_URL=https://billa-api-og7v.onrender.com
```

Without it the app points at `http://localhost:4000`, which only works on an emulator with a local server.

## Release builds

Release builds are signed with the key described in `android/key.properties` (git-ignored). Without that file the build still succeeds, signed with the debug key, and is not fit to publish.

`android/key.properties` has four lines:

```
storePassword=...
keyPassword=...
keyAlias=billa
storeFile=C:/path/to/billa-release.jks
```

The keystore and its passwords live outside the repository. Back them up: if the key is lost, an app published on the Play Store can never be updated.

Build one APK per CPU architecture; phones today use `app-arm64-v8a-release.apk`, which is about a third of the size of the universal build:

```bash
flutter build apk --release --split-per-abi --dart-define=API_BASE_URL=https://billa-api-og7v.onrender.com
```

The APKs are written to `build/app/outputs/flutter-apk/`. Release builds shrink code and resources, so check sign-in, lists and sharing on a device after changing dependencies.

## Checks before a pull request

```bash
flutter analyze
flutter test
flutter build apk --debug
```
