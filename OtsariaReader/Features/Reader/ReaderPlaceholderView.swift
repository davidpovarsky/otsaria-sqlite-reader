import SwiftUI

struct ReaderPlaceholderView: View {
    var body: some View {
        ContentUnavailableView("בחר ספר מהספרייה", systemImage: "book.closed")
            .navigationTitle("קורא")
    }
}
