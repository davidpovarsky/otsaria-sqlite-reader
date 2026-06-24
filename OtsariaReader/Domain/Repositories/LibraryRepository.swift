import Foundation

protocol LibraryRepository {
    func loadLibrary() async throws -> (nodes: [LibraryNode], books: [Book])
}
