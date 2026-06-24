import Foundation

struct LibraryCategory: Identifiable, Hashable {
    let id: Int
    let parentId: Int?
    let title: String
    let level: Int
    let orderIndex: Int
}
