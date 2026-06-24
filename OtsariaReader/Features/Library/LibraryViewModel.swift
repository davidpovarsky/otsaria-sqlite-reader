import Foundation

@MainActor
final class LibraryViewModel: ObservableObject {
    enum State: Equatable {
        case idle
        case loading
        case loaded
        case empty(String)
        case failed(String)
    }

    @Published private(set) var state: State = .idle
    @Published private(set) var nodes: [LibraryNode] = []
    @Published private(set) var books: [Book] = []

    func load(using repository: (any LibraryRepository)?) async {
        guard let repository else {
            nodes = []
            books = []
            state = .empty("בחר את seforim.db כדי לטעון את הספרייה")
            return
        }

        state = .loading
        do {
            let result = try await repository.loadLibrary()
            nodes = result.nodes
            books = result.books
            state = result.books.isEmpty ? .empty("לא נמצאו ספרים במסד הנתונים") : .loaded
        } catch {
            nodes = []
            books = []
            state = .failed(error.localizedDescription)
        }
    }

    func searchResults(for text: String) -> [Book] {
        let query = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else { return [] }
        return Array(
            books.lazy.filter { book in
                book.title.localizedCaseInsensitiveContains(query)
                || (book.filePath?.localizedCaseInsensitiveContains(query) ?? false)
            }.prefix(200)
        )
    }
}
