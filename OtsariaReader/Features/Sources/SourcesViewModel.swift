import Foundation

@MainActor
final class SourcesViewModel: ObservableObject {
    @Published private(set) var selectedLine: BookLine?
    @Published private(set) var sections: [SourceSection] = []
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?

    func reset() {
        selectedLine = nil
        sections = []
        errorMessage = nil
        isLoading = false
    }

    func load(line: BookLine, repository: any SourceRepository) async {
        selectedLine = line
        sections = []
        errorMessage = nil
        isLoading = true
        defer { isLoading = false }

        do {
            let sources = try await repository.sources(for: line)
            sections = Self.group(sources)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private static func group(_ sources: [LinkedSource]) -> [SourceSection] {
        let grouped = Dictionary(grouping: sources, by: \.connectionType)
        let order = ["COMMENTARY", "TARGUM", "REFERENCE", "SOURCE", "OTHER"]
        var result: [SourceSection] = []

        for key in order {
            if let items = grouped[key], !items.isEmpty {
                result.append(SourceSection(id: key, title: items[0].localizedConnectionType, items: items))
            }
        }

        let known = Set(order)
        for key in grouped.keys.filter({ !known.contains($0) }).sorted() {
            if let items = grouped[key], !items.isEmpty {
                result.append(SourceSection(id: key, title: key, items: items))
            }
        }

        return result
    }
}
