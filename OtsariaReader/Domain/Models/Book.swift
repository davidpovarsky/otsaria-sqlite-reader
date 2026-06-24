import Foundation

struct Book: Identifiable, Hashable {
    let id: Int
    let title: String
    let categoryId: Int
    let orderIndex: Int
    let totalLines: Int
    let shortDescription: String?
    let filePath: String?
    let fileType: String?
    let isBaseBook: Bool
    let hasTeamim: Bool
    let hasNekudot: Bool
    let hasLinks: Bool

    var subtitle: String {
        if let shortDescription, !shortDescription.isEmpty {
            return shortDescription
        }
        if totalLines > 0 {
            return "\(totalLines) שורות"
        }
        return filePath ?? ""
    }
}
