import SwiftUI

struct DatabaseRequiredView: View {
    let chooseDatabase: () -> Void

    var body: some View {
        ContentUnavailableView {
            Label("בחר את seforim.db", systemImage: "externaldrive.badge.icloud")
        } description: {
            Text("האפליקציה אינה מעתיקה את מסד הנתונים. היא שומרת רק הרשאת גישה לקובץ שבחרת ב-Files או ב-iCloud Drive.")
        } actions: {
            Button("בחר DB", systemImage: "folder") {
                chooseDatabase()
            }
            .buttonStyle(.borderedProminent)
        }
        .navigationTitle("אוצריא")
    }
}
