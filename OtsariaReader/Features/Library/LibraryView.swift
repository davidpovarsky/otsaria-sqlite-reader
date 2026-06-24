import SwiftUI

struct LibraryView: View {
    @ObservedObject var viewModel: LibraryViewModel
    @Binding var selectedBook: Book?
    @Binding var showDatabaseImporter: Bool

    @State private var searchText = ""

    var body: some View {
        content
            .navigationTitle("ספרייה")
            .searchable(text: $searchText, placement: .sidebar, prompt: "חיפוש ספר")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button("בחר DB", systemImage: "folder") {
                        showDatabaseImporter = true
                    }
                }
            }
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .idle, .loading:
            LoadingStateView(title: "טוען ספרייה")
        case .empty(let message):
            ContentUnavailableView {
                Label("אין ספרייה טעונה", systemImage: "books.vertical")
            } description: {
                Text(message)
            } actions: {
                Button("בחר seforim.db", systemImage: "folder") {
                    showDatabaseImporter = true
                }
                .buttonStyle(.borderedProminent)
            }
        case .failed(let message):
            ErrorStateView(title: "טעינת הספרייה נכשלה", message: message)
        case .loaded:
            libraryList
        }
    }

    private var libraryList: some View {
        List {
            if searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                OutlineGroup(viewModel.nodes, children: \.children) { node in
                    LibraryNodeRow(node: node, selectedBook: $selectedBook)
                }
            } else {
                Section("תוצאות חיפוש") {
                    ForEach(viewModel.searchResults(for: searchText)) { book in
                        Button {
                            selectedBook = book
                        } label: {
                            BookResultRow(book: book)
                        }
                    }
                }
            }
        }
    }
}
