import Foundation

protocol BookTextRepository {
    func lines(bookId: Int, startingAtLineIndex: Int, limit: Int) async throws -> [BookLine]
    func tableOfContents(bookId: Int) async throws -> [TOCEntry]
}
