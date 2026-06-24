import Foundation

protocol SourceRepository {
    func sources(for line: BookLine) async throws -> [LinkedSource]
}
