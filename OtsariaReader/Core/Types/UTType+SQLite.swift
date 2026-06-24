import UniformTypeIdentifiers

extension UTType {
    static let sqliteDatabase = UTType(filenameExtension: "sqlite3")
        ?? UTType(filenameExtension: "sqlite")
        ?? UTType(filenameExtension: "db")
        ?? .data
}
