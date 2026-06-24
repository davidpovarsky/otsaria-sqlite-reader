import SwiftUI

struct BookResultRow: View {
    let book: Book

    var body: some View {
        Label {
            Text(book.title)
                .lineLimit(2)
        } icon: {
            Image(systemName: book.hasLinks ? "book.closed.fill" : "book.closed")
        }
        .badge(book.totalLines > 0 ? Text("\(book.totalLines)") : nil)
        .help(book.subtitle)
    }
}
