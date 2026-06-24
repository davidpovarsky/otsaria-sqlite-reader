import Foundation

struct BookLine: Identifiable, Hashable {
    let id: Int
    let bookId: Int
    let lineIndex: Int
    let content: String
    let heRef: String?

    var text: String { content.otsariaPlainText }
    var isHeading: Bool { content.looksLikeHTMLHeading }
}
