import SwiftUI

struct SourcesView: View {
    @ObservedObject var viewModel: SourcesViewModel

    var body: some View {
        Group {
            if viewModel.isLoading {
                LoadingStateView(title: "טוען מקורות")
            } else if let error = viewModel.errorMessage {
                ErrorStateView(title: "טעינת המקורות נכשלה", message: error)
            } else if viewModel.selectedLine == nil {
                ContentUnavailableView("בחר שורה", systemImage: "link", description: Text("לחיצה על שורה בטקסט תציג כאן מפרשים, מקורות ותרגומים."))
            } else if viewModel.sections.isEmpty {
                ContentUnavailableView("לא נמצאו קישורים", systemImage: "link.badge.plus")
            } else {
                sourcesList
            }
        }
        .navigationTitle("מקורות")
    }

    private var sourcesList: some View {
        List {
            if let line = viewModel.selectedLine {
                Section("השורה שנבחרה") {
                    Text(line.text)
                        .font(.callout)
                        .lineLimit(4)
                        .multilineTextAlignment(.trailing)
                        .textSelection(.enabled)
                }
            }

            ForEach(viewModel.sections) { section in
                Section(section.title) {
                    ForEach(section.items) { item in
                        LinkedSourceRow(item: item)
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
    }
}
