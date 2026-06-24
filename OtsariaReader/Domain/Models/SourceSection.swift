import Foundation

struct SourceSection: Identifiable, Hashable {
    let id: String
    let title: String
    let items: [LinkedSource]
}
