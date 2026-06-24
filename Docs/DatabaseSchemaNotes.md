# Database Schema Notes

This project uses the read-only Otsaria SQLite schema observed in the Otsaria repository.

Core tables used by the app:

- `category`: library hierarchy.
- `book`: book metadata and connection flags.
- `line`: line-level text, Hebrew reference, and optional TOC mapping.
- `tocEntry` + `tocText`: native table-of-contents navigation.
- `link` + `connection_type`: commentary, source, targum, reference, and other line-level links.

The SQLite connection is opened with:

- `SQLITE_OPEN_READONLY`
- `SQLITE_OPEN_FULLMUTEX`
- `SQLITE_OPEN_URI`
- `mode=ro&immutable=1`
- `PRAGMA query_only=ON`

The app never writes to `seforim.db`.
