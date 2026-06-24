import SwiftUI

struct LibraryNodeRow: View {
    let node: LibraryNode
    @Binding var selectedBook: Book?

    var body: some View {
        if let book = node.book {
            Button {
                selectedBook = book
            } label: {
                BookResultRow(book: book)
            }
            .buttonStyle(.plain)
            .listRowBackground(selectedBook?.id == book.id ? Color.accentColor.opacity(0.12) : nil)
        } else {
            Label(node.title, systemImage: node.systemImage)
                .lineLimit(2)
        }
    }
}
