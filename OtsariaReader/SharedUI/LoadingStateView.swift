import SwiftUI

struct LoadingStateView: View {
    let title: String

    var body: some View {
        ProgressView(title)
            .controlSize(.large)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
