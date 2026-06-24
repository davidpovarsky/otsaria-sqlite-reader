import SwiftUI
import UIKit

struct LinkedSourceRow: View {
    let item: LinkedSource

    var body: some View {
        LabeledContent {
            Text(item.text)
                .font(.body)
                .lineSpacing(5)
                .multilineTextAlignment(.trailing)
                .textSelection(.enabled)
        } label: {
            Label(item.bookTitle, systemImage: item.systemImage)
                .font(.headline)

            if let heRef = item.heRef, !heRef.isEmpty {
                Text(heRef)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .contextMenu {
            Button("העתק", systemImage: "doc.on.doc") {
                UIPasteboard.general.string = item.text
            }
        }
    }
}
