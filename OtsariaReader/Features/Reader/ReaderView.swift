import SwiftUI

struct ReaderView: View {
    let book: Book
    let onSelectLine: (BookLine) -> Void

    @Binding var selectedLineID: Int?
    @StateObject private var viewModel: ReaderViewModel

    init(
        book: Book,
        repository: any BookTextRepository,
        selectedLineID: Binding<Int?>,
        onSelectLine: @escaping (BookLine) -> Void
    ) {
        self.book = book
        self.onSelectLine = onSelectLine
        _selectedLineID = selectedLineID
        _viewModel = StateObject(wrappedValue: ReaderViewModel(book: book, repository: repository))
    }

    var body: some View {
        Group {
            if let error = viewModel.errorMessage, viewModel.lines.isEmpty {
                ErrorStateView(title: "טעינת הספר נכשלה", message: error)
            } else if viewModel.lines.isEmpty && viewModel.isLoading {
                LoadingStateView(title: "טוען את \(book.title)")
            } else if viewModel.lines.isEmpty {
                ContentUnavailableView("אין שורות להצגה", systemImage: "text.book.closed")
            } else {
                readerList
            }
        }
        .navigationTitle(book.title)
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            if !viewModel.tocEntries.isEmpty {
                ToolbarItem(placement: .primaryAction) {
                    Menu("תוכן", systemImage: "list.bullet") {
                        ForEach(viewModel.tocEntries.prefix(160)) { entry in
                            Button(entry.menuTitle) {
                                Task { await viewModel.jump(to: entry) }
                            }
                            .disabled(entry.lineIndex == nil)
                        }
                    }
                }
            }
        }
        .task {
            await viewModel.loadInitial()
        }
    }

    private var readerList: some View {
        List {
            Section {
                ForEach(viewModel.lines) { line in
                    ReaderLineRow(line: line, isSelected: selectedLineID == line.id)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            selectedLineID = line.id
                            onSelectLine(line)
                        }
                        .task {
                            if line.id == viewModel.lines.last?.id {
                                await viewModel.loadNextPage()
                            }
                        }
                }

                if viewModel.isLoading {
                    ProgressView("טוען עוד")
                }
            } footer: {
                Text(book.subtitle)
            }
        }
        .listStyle(.plain)
    }
}
