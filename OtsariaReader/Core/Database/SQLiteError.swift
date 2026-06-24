import Foundation
import SQLite3

enum SQLiteError: LocalizedError {
    case openFailed(message: String, code: Int32)
    case databaseClosed
    case prepareFailed(message: String, code: Int32, sql: String)
    case stepFailed(message: String, code: Int32, sql: String)
    case bindFailed(message: String, code: Int32)

    var errorDescription: String? {
        switch self {
        case .openFailed(let message, let code):
            return "SQLite open failed (\(code)): \(message)"
        case .databaseClosed:
            return "SQLite database is closed."
        case .prepareFailed(let message, let code, let sql):
            return "SQLite prepare failed (\(code)): \(message)\n\(sql)"
        case .stepFailed(let message, let code, let sql):
            return "SQLite step failed (\(code)): \(message)\n\(sql)"
        case .bindFailed(let message, let code):
            return "SQLite bind failed (\(code)): \(message)"
        }
    }
}

func sqliteMessage(_ db: OpaquePointer?) -> String {
    guard let db else { return "unknown SQLite error" }
    return String(cString: sqlite3_errmsg(db))
}
