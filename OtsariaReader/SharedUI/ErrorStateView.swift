import SwiftUI

struct ErrorStateView: View {
    let title: String
    let message: String

    var body: some View {
        ContentUnavailableView(title, systemImage: "exclamationmark.triangle", description: Text(message))
    }
}
