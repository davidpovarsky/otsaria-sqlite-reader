import SwiftUI

struct RootSplitView: View {
    @EnvironmentObject private var app: AppContainer

    @StateObject private var libraryViewModel = LibraryViewModel()
    @StateObject private var sourcesViewModel = SourcesViewModel()

    @State private var selectedBook: Book?
    @State private var selectedLineID: Int?
    @State private var showDatabaseImporter = false
    @State private var showSourcesInspector = false
    @State private var showReaderSettings = false

    var body: some View {
        NavigationSplitView {
            LibraryView(
                viewModel: libraryViewModel,
                selectedBook: $selectedBook,
                showDatabaseImporter: $showDatabaseImporter
            )
        } detail: {
            detailView
                .inspector(isPresented: $showSourcesInspector) {
                    SourcesView(viewModel: sourcesViewModel)
                }
        }
        .navigationSplitViewStyle(.balanced)
        .fileImporter(
            isPresented: $showDatabaseImporter,
            allowedContentTypes: [.sqliteDatabase, .data],
            allowsMultipleSelection: false
        ) { result in
            handleDatabaseImport(result)
        }
        .sheet(isPresented: $showReaderSettings) {
            NavigationStack {
                ReaderSettingsView()
            }
        }
        .toolbar {
            ToolbarItemGroup(placement: .primaryAction) {
                Button("בחר DB", systemImage: "externaldrive") {
                    showDatabaseImporter = true
                }

                Button("הגדרות", systemImage: "textformat.size") {
                    showReaderSettings = true
                }
            }

            ToolbarItemGroup(placement: .secondaryAction) {
                Button("שכח DB", systemImage: "trash", role: .destructive) {
                    selectedBook = nil
                    selectedLineID = nil
                    sourcesViewModel.reset()
                    showSourcesInspector = false
                    app.forgetDatabase()
                }
            }
        }
        .task(id: app.databaseToken) {
            await libraryViewModel.load(using: app.repositories?.library)
        }
        .onChange(of: selectedBook) { _, _ in
            selectedLineID = nil
            sourcesViewModel.reset()
            showSourcesInspector = false
        }
        .environment(\.layoutDirection, .rightToLeft)
    }

    @ViewBuilder
    private var detailView: some View {
        if app.isOpeningDatabase {
            LoadingStateView(title: "פותח מסד נתונים")
        } else if let error = app.databaseError {
            ErrorStateView(title: "שגיאה בפתיחת המסד", message: error)
        } else if let book = selectedBook, let repositories = app.repositories {
            ReaderView(
                book: book,
                repository: repositories.bookText,
                selectedLineID: $selectedLineID
            ) { line in
                showSourcesInspector = true
                Task {
                    await sourcesViewModel.load(line: line, repository: repositories.sources)
                }
            }
            .id(book.id)
        } else if app.repositories == nil {
            DatabaseRequiredView {
                showDatabaseImporter = true
            }
        } else {
            ReaderPlaceholderView()
        }
    }

    private func handleDatabaseImport(_ result: Result<[URL], Error>) {
        switch result {
        case .success(let urls):
            guard let url = urls.first else { return }
            selectedBook = nil
            selectedLineID = nil
            sourcesViewModel.reset()
            showSourcesInspector = false
            Task {
                await app.openPickedDatabase(at: url)
                await libraryViewModel.load(using: app.repositories?.library)
            }
        case .failure(let error):
            app.databaseError = error.localizedDescription
        }
    }
}
