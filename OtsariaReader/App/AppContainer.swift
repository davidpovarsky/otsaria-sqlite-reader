import Foundation

@MainActor
final class AppContainer: ObservableObject {
    @Published private(set) var repositories: AppRepositories?
    @Published private(set) var databaseURL: URL?
    @Published private(set) var databaseToken = UUID()
    @Published var databaseError: String?
    @Published var isOpeningDatabase = false

    private let bookmarkStore = SecurityScopedBookmarkStore()
    private var connection: SQLiteConnection?
    private var scopedAccess: SecurityScopedAccess?

    deinit {
        connection?.close()
        scopedAccess?.stop()
    }

    func restoreDatabaseIfPossible() async {
        guard repositories == nil else { return }
        do {
            guard let restored = try bookmarkStore.restore() else { return }
            await openDatabase(at: restored.url, shouldSaveBookmark: false, scopedAccess: restored.access)
        } catch {
            databaseError = error.localizedDescription
        }
    }

    func openPickedDatabase(at url: URL) async {
        await openDatabase(at: url, shouldSaveBookmark: true, scopedAccess: nil)
    }

    func forgetDatabase() {
        connection?.close()
        connection = nil
        scopedAccess?.stop()
        scopedAccess = nil
        repositories = nil
        databaseURL = nil
        databaseError = nil
        bookmarkStore.forget()
        databaseToken = UUID()
    }

    private func openDatabase(at url: URL, shouldSaveBookmark: Bool, scopedAccess existingAccess: SecurityScopedAccess?) async {
        isOpeningDatabase = true
        databaseError = nil
        defer { isOpeningDatabase = false }

        connection?.close()
        connection = nil
        scopedAccess?.stop()
        scopedAccess = nil
        repositories = nil

        do {
            let access = try existingAccess ?? SecurityScopedAccess.start(for: url)
            if shouldSaveBookmark {
                try bookmarkStore.save(url: url)
            }

            let newConnection = try SQLiteConnection.openReadOnly(url: url)
            let newRepositories = AppRepositories(
                library: SQLiteLibraryRepository(database: newConnection),
                bookText: SQLiteBookTextRepository(database: newConnection),
                sources: SQLiteSourceRepository(database: newConnection)
            )

            scopedAccess = access
            connection = newConnection
            repositories = newRepositories
            databaseURL = url
            databaseToken = UUID()
        } catch {
            databaseError = error.localizedDescription
        }
    }
}

struct AppRepositories {
    let library: any LibraryRepository
    let bookText: any BookTextRepository
    let sources: any SourceRepository
}
