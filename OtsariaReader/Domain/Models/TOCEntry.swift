import Foundation

struct TOCEntry: Identifiable, Hashable {
    let id: Int
    let bookId: Int
    let parentId: Int?
    let title: String
    let level: Int
    let lineId: Int?
    let lineIndex: Int?
    let hasChildren: Bool

    var menuTitle: String {
        String(repeating: "  ", count: max(0, min(level, 4))) + title
    }
}
