import Foundation
import SQLite3

final class SQLiteLibraryRepository: LibraryRepository {
    private let database: SQLiteConnection

    init(database: SQLiteConnection) {
        self.database = database
    }

    func loadLibrary() async throws -> (nodes: [LibraryNode], books: [Book]) {
        try await database.read { db in
            let categories = try Self.fetchCategories(db)
            let books = try Self.fetchBooks(db)
            let nodes = Self.buildTree(categories: categories, books: books)
            return (nodes, books)
        }
    }

    private static func fetchCategories(_ db: OpaquePointer) throws -> [LibraryCategory] {
        let statement = try SQLiteStatement(database: db, sql: """
            SELECT id, parentId, title, level, orderIndex
            FROM category
            ORDER BY level, orderIndex, title
        """)

        var categories: [LibraryCategory] = []
        while try statement.step() {
            let parentId: Int? = statement.columnType(1) == SQLITE_NULL ? nil : statement.columnInt(1)
            categories.append(
                LibraryCategory(
                    id: statement.columnInt(0),
                    parentId: parentId,
                    title: statement.columnString(2) ?? "ללא שם",
                    level: statement.columnInt(3),
                    orderIndex: statement.columnInt(4)
                )
            )
        }
        return categories
    }

    private static func fetchBooks(_ db: OpaquePointer) throws -> [Book] {
        let statement = try SQLiteStatement(database: db, sql: """
            SELECT id, title, categoryId, orderIndex, totalLines, heShortDesc,
                   filePath, fileType, isBaseBook, hasTeamim, hasNekudot,
                   CASE
                       WHEN hasTargumConnection = 1
                         OR hasReferenceConnection = 1
                         OR hasSourceConnection = 1
                         OR hasCommentaryConnection = 1
                         OR hasOtherConnection = 1 THEN 1
                       ELSE 0
                   END AS hasLinks
            FROM book
            WHERE COALESCE(fileType, '') NOT IN ('link', 'url')
            ORDER BY orderIndex, title
        """)

        var books: [Book] = []
        while try statement.step() {
            books.append(
                Book(
                    id: statement.columnInt(0),
                    title: statement.columnString(1) ?? "ללא שם",
                    categoryId: statement.columnInt(2),
                    orderIndex: statement.columnInt(3),
                    totalLines: statement.columnInt(4),
                    shortDescription: statement.columnString(5),
                    filePath: statement.columnString(6),
                    fileType: statement.columnString(7),
                    isBaseBook: statement.columnBool(8),
                    hasTeamim: statement.columnBool(9),
                    hasNekudot: statement.columnBool(10),
                    hasLinks: statement.columnBool(11)
                )
            )
        }
        return books
    }

    private static func buildTree(categories: [LibraryCategory], books: [Book]) -> [LibraryNode] {
        let categoriesByParent = Dictionary(grouping: categories, by: \.parentId)
        let booksByCategory = Dictionary(grouping: books, by: \.categoryId)

        func categorySort(_ lhs: LibraryCategory, _ rhs: LibraryCategory) -> Bool {
            if lhs.orderIndex != rhs.orderIndex { return lhs.orderIndex < rhs.orderIndex }
            return lhs.title.localizedCompare(rhs.title) == .orderedAscending
        }

        func bookSort(_ lhs: Book, _ rhs: Book) -> Bool {
            if lhs.orderIndex != rhs.orderIndex { return lhs.orderIndex < rhs.orderIndex }
            return lhs.title.localizedCompare(rhs.title) == .orderedAscending
        }

        func nodes(parentId: Int?) -> [LibraryNode] {
            let categoryNodes = (categoriesByParent[parentId] ?? [])
                .sorted(by: categorySort)
                .map { category in
                    let children = nodes(parentId: category.id)
                    return LibraryNode(
                        id: "category-\(category.id)",
                        title: category.title,
                        subtitle: nil,
                        systemImage: "folder",
                        book: nil,
                        children: children.isEmpty ? nil : children
                    )
                }

            let bookNodes: [LibraryNode]
            if let parentId {
                bookNodes = (booksByCategory[parentId] ?? [])
                    .sorted(by: bookSort)
                    .map { book in
                        LibraryNode(
                            id: "book-\(book.id)",
                            title: book.title,
                            subtitle: book.subtitle,
                            systemImage: book.hasLinks ? "book.closed.fill" : "book.closed",
                            book: book,
                            children: nil
                        )
                    }
            } else {
                bookNodes = []
            }

            return categoryNodes + bookNodes
        }

        return nodes(parentId: nil)
    }
}
