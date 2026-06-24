import Foundation
import SQLite3

final class SQLiteBookTextRepository: BookTextRepository {
    private let database: SQLiteConnection

    init(database: SQLiteConnection) {
        self.database = database
    }

    func lines(bookId: Int, startingAtLineIndex: Int, limit: Int) async throws -> [BookLine] {
        try await database.read { db in
            let statement = try SQLiteStatement(database: db, sql: """
                SELECT id, bookId, lineIndex, content, heRef
                FROM line
                WHERE bookId = ? AND lineIndex >= ?
                ORDER BY lineIndex
                LIMIT ?
            """)
            try statement.bind(bookId, at: 1)
            try statement.bind(startingAtLineIndex, at: 2)
            try statement.bind(limit, at: 3)

            var lines: [BookLine] = []
            while try statement.step() {
                lines.append(
                    BookLine(
                        id: statement.columnInt(0),
                        bookId: statement.columnInt(1),
                        lineIndex: statement.columnInt(2),
                        content: statement.columnString(3) ?? "",
                        heRef: statement.columnString(4)
                    )
                )
            }
            return lines
        }
    }

    func tableOfContents(bookId: Int) async throws -> [TOCEntry] {
        try await database.read { db in
            let statement = try SQLiteStatement(database: db, sql: """
                SELECT te.id,
                       te.bookId,
                       te.parentId,
                       tt.text,
                       te.level,
                       te.lineId,
                       COALESCE(te.lineIndex, ln.lineIndex) AS resolvedLineIndex,
                       te.hasChildren
                FROM tocEntry te
                JOIN tocText tt ON tt.id = te.textId
                LEFT JOIN line ln ON ln.id = te.lineId
                WHERE te.bookId = ?
                ORDER BY COALESCE(resolvedLineIndex, 0), te.level, te.id
            """)
            try statement.bind(bookId, at: 1)

            var entries: [TOCEntry] = []
            while try statement.step() {
                let parentId: Int? = statement.columnType(2) == SQLITE_NULL ? nil : statement.columnInt(2)
                let lineId: Int? = statement.columnType(5) == SQLITE_NULL ? nil : statement.columnInt(5)
                let lineIndex: Int? = statement.columnType(6) == SQLITE_NULL ? nil : statement.columnInt(6)
                entries.append(
                    TOCEntry(
                        id: statement.columnInt(0),
                        bookId: statement.columnInt(1),
                        parentId: parentId,
                        title: statement.columnString(3)?.otsariaPlainText ?? "",
                        level: statement.columnInt(4),
                        lineId: lineId,
                        lineIndex: lineIndex,
                        hasChildren: statement.columnBool(7)
                    )
                )
            }
            return entries
        }
    }
}
