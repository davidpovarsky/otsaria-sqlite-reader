# Build and IPA Export

This project includes local scripts for compiling, archiving, and exporting an IPA with readable logs.

> IPA export requires macOS with Xcode and valid Apple signing credentials. GitHub Codespaces on iPad cannot build iOS apps because it is not a macOS/Xcode environment.

## 1. Check the machine

```bash
bash scripts/doctor.sh
```

This verifies that Xcode tools are visible and that the `OtsariaReader` scheme is discoverable.

## 2. Compile without signing

Use this first. It builds for the iOS Simulator and disables code signing:

```bash
bash scripts/build.sh
```

The full log is written under:

```text
build/logs/
```

If compilation fails, copy the block printed between:

```text
================ COPY THIS ERROR SUMMARY ================
================ END COPY THIS ERROR SUMMARY =============
```

## 3. Archive for iPhone/iPad

Set your Apple Team ID if automatic signing needs it:

```bash
XCODE_DEVELOPMENT_TEAM=YOUR_TEAM_ID bash scripts/archive.sh
```

Optional: override the bundle identifier without editing the project:

```bash
XCODE_DEVELOPMENT_TEAM=YOUR_TEAM_ID \
XCODE_BUNDLE_ID=com.yourname.otsariareader \
bash scripts/archive.sh
```

The latest archive path is saved to:

```text
build/latest-archive-path.txt
```

## 4. Export IPA

Development IPA:

```bash
XCODE_DEVELOPMENT_TEAM=YOUR_TEAM_ID bash scripts/export-ipa.sh development
```

Ad Hoc IPA:

```bash
XCODE_DEVELOPMENT_TEAM=YOUR_TEAM_ID bash scripts/export-ipa.sh ad-hoc
```

App Store Connect export:

```bash
XCODE_DEVELOPMENT_TEAM=YOUR_TEAM_ID bash scripts/export-ipa.sh app-store-connect
```

Legacy App Store export method, for Xcode versions that still expect `app-store`:

```bash
XCODE_DEVELOPMENT_TEAM=YOUR_TEAM_ID bash scripts/export-ipa.sh app-store
```

You can also provide your own plist:

```bash
EXPORT_OPTIONS_PLIST=/path/to/ExportOptions.plist bash scripts/export-ipa.sh development
```

The IPA is written under:

```text
build/output/
```

## Error reporting

Every script writes a full log under `build/logs/`.

When a build, archive, or export fails, the script prints a compact error summary and the last 80 log lines. Copy that summary into ChatGPT so the error can be diagnosed without needing the full log.

## Common signing notes

- For simulator builds, signing is disabled automatically.
- For archive/export, the Mac must be logged into Xcode with an Apple Developer account or have the correct signing certificates and provisioning profiles installed.
- The project currently uses automatic signing. If Xcode reports a signing error, first open the project in Xcode, select the `OtsariaReader` target, choose your Team, and let Xcode repair signing.
- If Xcode says the bundle identifier is taken, override it with `XCODE_BUNDLE_ID` or change it in the project settings.
