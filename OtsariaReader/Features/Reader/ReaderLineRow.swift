import SwiftUI

struct ReaderLineRow: View {
    let line: BookLine
    let isSelected: Bool

    @AppStorage("reader.fontSize") private var fontSize = 20.0
    @AppStorage("reader.lineSpacing") private var lineSpacing = 6.0
    @AppStorage("reader.showHebrewReference") private var showHebrewReference = true

    var body: some View {
        LabeledContent {
            Text(line.text)
                .font(line.isHeading ? .title3.bold() : .system(size: fontSize))
                .lineSpacing(lineSpacing)
                .multilineTextAlignment(.trailing)
                .textSelection(.enabled)
                .frame(maxWidth: .infinity, alignment: .trailing)
        } label: {
            if showHebrewReference, let heRef = line.heRef, !heRef.isEmpty {
                Text(heRef)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .textSelection(.enabled)
            }
        }
        .padding(.vertical, line.isHeading ? 10 : 4)
        .listRowBackground(isSelected ? Color.accentColor.opacity(0.14) : nil)
    }
}
