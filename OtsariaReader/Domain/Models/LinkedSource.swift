import Foundation

struct LinkedSource: Identifiable, Hashable {
    let id: Int
    let connectionType: String
    let linkedLineId: Int
    let linkedBookId: Int
    let linkedLineIndex: Int
    let bookTitle: String
    let bookPath: String?
    let heRef: String?
    let content: String

    var text: String { content.otsariaPlainText }

    var localizedConnectionType: String {
        switch connectionType {
        case "COMMENTARY": "מפרשים"
        case "SOURCE": "מקורות"
        case "TARGUM": "תרגום"
        case "REFERENCE": "מראי מקום"
        case "OTHER": "אחר"
        default: connectionType
        }
    }

    var systemImage: String {
        switch connectionType {
        case "COMMENTARY": "text.quote"
        case "TARGUM": "character.book.closed"
        case "REFERENCE": "link"
        case "SOURCE": "doc.text"
        default: "arrow.triangle.branch"
        }
    }
}
