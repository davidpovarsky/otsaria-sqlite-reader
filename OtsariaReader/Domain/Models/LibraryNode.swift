import Foundation

struct LibraryNode: Identifiable, Hashable {
    let id: String
    let title: String
    let subtitle: String?
    let systemImage: String
    let book: Book?
    let children: [LibraryNode]?

    var isBook: Bool { book != nil }
}
