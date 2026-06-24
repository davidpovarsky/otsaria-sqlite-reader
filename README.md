# Otsaria Reader

A fast native SwiftUI reader for the Otsaria SQLite database (`seforim.db`).

The project is intentionally small and native:

- SwiftUI only: `NavigationSplitView`, `List`, `OutlineGroup`, `Form`, native `Text`, and SwiftUI `inspector`.
- No WebView and no bundled database.
- Direct read-only SQLite access through Apple `SQLite3`.
- Clear separation between app shell, domain models, repositories, SQLite data layer, feature views, and shared UI.

## Project structure

```text
OtsariaReader/
  App/
  Core/
    Database/
    FileAccess/
    Text/
    Types/
  Domain/
    Models/
    Repositories/
  Data/
    SQLite/
  Features/
    Library/
    Reader/
    Sources/
    Settings/
  SharedUI/
```

## Expected database

The app expects an Otsaria SQLite database with the core tables:

- `category`
- `book`
- `line`
- `tocEntry`
- `tocText`
- `connection_type`
- `link`

The file is opened read-only and query-only. On first launch choose `seforim.db` from Files/iCloud Drive. The app stores a security-scoped bookmark so the same file can be reopened later.

## Current MVP

- Pick and remember `seforim.db`.
- Load the category/book tree.
- Search books by title/path.
- Read text natively with lazy paging.
- Open a native sources/commentary inspector for the selected line.
- Basic reader settings: font size, line spacing, Hebrew reference visibility.

## Build scripts

The repository includes local scripts under `scripts/`:

```bash
bash scripts/doctor.sh
bash scripts/build.sh
XCODE_DEVELOPMENT_TEAM=YOUR_TEAM_ID bash scripts/archive.sh
XCODE_DEVELOPMENT_TEAM=YOUR_TEAM_ID bash scripts/export-ipa.sh development
```

The scripts write full logs to `build/logs/`. When an error happens, they print a compact block headed by `COPY THIS ERROR SUMMARY`; copy that block when reporting build problems.

Full instructions are in:

```text
Docs/BuildAndExportIPA.md
```

## CI

A GitHub Actions workflow builds the app for the iOS Simulator on macOS and uploads build logs as an artifact:

```text
.github/workflows/ios-build.yml
```

IPA export is intentionally local because it requires Apple signing certificates, provisioning profiles, and a valid Apple Developer account.

## Notes

This is a clean starter project for a native iOS/iPadOS reader. It does not bundle `seforim.db`; the user picks the database file from Files/iCloud Drive.
