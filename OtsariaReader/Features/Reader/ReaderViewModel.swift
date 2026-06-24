import Foundation

@MainActor
final class ReaderViewModel: ObservableObject {
    @Published private(set) var lines: [BookLine] = []
    @Published private(set) var tocEntries: [TOCEntry] = []
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?

    private let book: Book
    private let repository: any BookTextRepository
    private let pageSize = 180
    private var nextLineIndex = 0
    private var allLoaded = false

    init(book: Book, repository: any BookTextRepository) {
        self.book = book
        self.repository = repository
    }

    func loadInitial() async {
        guard lines.isEmpty else { return }
        async let toc: Void = loadTOC()
        async let firstPage: Void = loadNextPage()
        _ = await (toc, firstPage)
    }

    func loadNextPage() async {
        guard !isLoading, !allLoaded else { return }
        isLoading = true
        defer { isLoading = false }

        do {
            let newLines = try await repository.lines(bookId: book.id, startingAtLineIndex: nextLineIndex, limit: pageSize)
            lines.append(contentsOf: newLines)
            if let last = newLines.last {
                nextLineIndex = last.lineIndex + 1
            }
            allLoaded = newLines.count < pageSize
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func jump(to entry: TOCEntry) async {
        guard let lineIndex = entry.lineIndex else { return }
        lines = []
        nextLineIndex = max(0, lineIndex)
        allLoaded = false
        await loadNextPage()
    }

    private func loadTOC() async {
        do {
            tocEntries = try await repository.tableOfContents(bookId: book.id)
        } catch {
            // TOC is optional for reading. Keep the reader usable even if it fails.
            tocEntries = []
        }
    }
}
