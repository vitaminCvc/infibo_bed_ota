# Android Country Flavor Design

## Goal

Replace the four copied Flutter projects with one source repository that builds
four independently installable Android applications:

| Flavor | App label | Application ID | First-launch locale |
| --- | --- | --- | --- |
| global | Infibo | `com.infibo.app.global` | `en_US` |
| india | Infibo India | `com.infibo.app.india` | `en_US` |
| spain | Infibo Spain | `com.infibo.app.spain` | `es_ES` |
| turkey | Infibo Turkey | `com.infibo.app.turkey` | `tr_TR` |

The final application IDs must be confirmed before any Google Play release.
They need to be unique identifiers owned by the publisher; the values above
are the implementation defaults for this migration.

## Scope

The shared Flutter implementation remains in one repository:

`D:\FlutterProject\1610\infibo_app_v1.0_1610`

The former `India`, `spain`, and `turikey` folders become read-only migration
references. They are not build targets after migration and must not receive
future feature edits.

Each flavor differs only in:

- Android application ID and visible application name.
- First-launch language, while preserving a user's manually selected language.
- Login and page-header logo assets.

All business logic, routes, translations, dependencies, and non-brand assets
remain shared.

## Flutter Design

Create an immutable `AppBrandConfig` with these values:

- flavor identifier;
- default `Locale`;
- login-logo asset path;
- header-logo asset path.

Create four small entry points (`main_global.dart`, `main_india.dart`,
`main_spain.dart`, and `main_turkey.dart`). Each entry point passes its
`AppBrandConfig` to a shared bootstrap function. The existing startup flow,
user-session restore, and routing stay in that shared function.

The bootstrap function uses the configured locale only if
`app_language_code` or `app_country_code` is absent from `SharedPreferences`.
Because every flavor has a distinct application ID, Android gives each app a
separate preferences store. Selecting a language in one country app does not
change another country app.

Logo asset references in login screens and shared page headers will read from
the active configuration. Other `Assets` entries remain unchanged.

Brand resources will be kept in explicit directories:

```text
assets/branding/
  global/login_logo.png
  global/header_logo.png
  india/login_logo.png
  india/header_logo.png
  spain/login_logo.png
  spain/header_logo.png
  turkey/login_logo.png
  turkey/header_logo.png
```

The migration copies the corresponding assets from each current project only
after comparing them against the global version. No existing asset is deleted
during the initial migration.

## Android Design

Add one Gradle flavor dimension named `market` and four `productFlavors`:
`global`, `india`, `spain`, and `turkey`.

Each flavor supplies `applicationId`, an Android app-label resource, and uses
the shared Android implementation and signing configuration. The Android
manifest uses `@string/app_name` rather than a hard-coded label.

This creates separate installable packages. For example, the India and Spain
apps can be installed on the same device at the same time.

## Developer Workflow

All feature changes are made once in the main repository. Build the required
country package from that repository:

```powershell
flutter build apk --release --flavor global -t lib/main_global.dart
flutter build apk --release --flavor india -t lib/main_india.dart
flutter build apk --release --flavor spain -t lib/main_spain.dart
flutter build apk --release --flavor turkey -t lib/main_turkey.dart
```

Development runs use the matching `flutter run --flavor ... -t ...` command.
A checked-in PowerShell helper will build all four variants consistently.

## Migration and Verification

1. Snapshot the current state of all four folders without overwriting them.
2. Add the flavor and brand-configuration infrastructure in the main project.
3. Import country-specific logo assets and direct login/header code through the
   configuration.
4. Build all four debug APKs from the main project.
5. Verify each APK has the expected package ID, app label, first-launch locale,
   and two country-specific logos.
6. Run the existing Flutter test suite and add focused tests for locale fallback
   and brand configuration.
7. Build release APKs only after a signing configuration is supplied. The
   existing project currently signs release builds with the debug key, which is
   unsuitable for store distribution.

## Error Handling

- An unknown or missing brand configuration fails during app startup in debug
  mode rather than silently using the wrong country branding.
- Asset tests verify that every configured logo path is declared in
  `pubspec.yaml` and present on disk.
- The build helper stops on the first failed flavor and reports the flavor name.

## Non-Goals

- Migrating iOS, Windows, Linux, macOS, or web packaging.
- Changing user-visible business behavior or translations beyond the
  first-launch default locale.
- Deleting the three former standalone project folders during this task.
