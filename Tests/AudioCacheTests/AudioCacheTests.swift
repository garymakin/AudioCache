import XCTest
@testable import AudioCache

final class AudioCacheTests: XCTestCase {

	var cacheFolderName: String = ""

	override func setUp() {
		let configuration = URLSessionConfiguration.ephemeral
		configuration.protocolClasses = [MockURLProtocol.self]
		let urlSession = URLSession(configuration: configuration)

		let url = URL(string: "https://example.com/audio")
		MockURLProtocol.data = [url: Data("1234567890".utf8)]

		cacheFolderName = UUID().uuidString
		AudioCache.shared.urlSession = urlSession
		AudioCache.shared.cacheFolderName = cacheFolderName
	}

	override func tearDown() {
		do {
			try FileManager.default.removeItem(at: try AudioCache.shared.cacheFolderURL())
		} catch {
		}
		AudioCache.shared.urlSession = URLSession.shared
	}

	/// Fetches a file and adds it to an empty cache. There should be one file in the cache.
	func testCachingFile() async throws {
		if let url = URL(string: "https://example.com/audio") {
			let (localURL, audioData) = try await AudioCache.shared.fetchAudio(from: url)
			XCTAssertEqual(audioData.count, MockURLProtocol.data[url]?.count)
			XCTAssert(localURL.absoluteString.contains(cacheFolderName))

			let items = try FileManager.default.contentsOfDirectory(at: try AudioCache.shared.cacheFolderURL(), includingPropertiesForKeys: [])
			XCTAssertEqual(items.count, 1)
		} else {
			XCTFail()
		}
	}

	/// Fetches a file and adds it to an empty cache. Changes the file and then performs the fetch again. The changed file should be returned.
	func testLoadingFromCache() async throws {
		if let url = URL(string: "https://example.com/audio") {
			let (localURL, audioData) = try await AudioCache.shared.fetchAudio(from: url)
			XCTAssertEqual(audioData.count, MockURLProtocol.data[url]?.count)
			XCTAssert(localURL.absoluteString.contains(cacheFolderName))

			// Change the file
			let newData = "12345"
			try newData.write(to: localURL, atomically: true, encoding: .utf8)

			// Perform the fetch again
			let (newLocalURL, newAudioData) = try await AudioCache.shared.fetchAudio(from: url)
			XCTAssertEqual(newLocalURL, localURL)
			XCTAssertEqual(newAudioData.count, newData.count)
		} else {
			XCTFail()
		}
	}

	/// Fetches a file and adds it to an empty cache. There should be one file in the cache. Then removes it. Cache should be empty.
	func testRemovingFile() async throws {
		if let url = URL(string: "https://example.com/audio") {
			let (localURL, audioData) = try await AudioCache.shared.fetchAudio(from: url)
			XCTAssertEqual(audioData.count, 10)
			XCTAssert(localURL.absoluteString.contains(cacheFolderName))

			var items = try FileManager.default.contentsOfDirectory(at: try AudioCache.shared.cacheFolderURL(),
																	includingPropertiesForKeys: [])
			XCTAssertEqual(items.count, 1)

			try await AudioCache.shared.removeCachedFile(for: url)

			items = try FileManager.default.contentsOfDirectory(at: try AudioCache.shared.cacheFolderURL(),
																includingPropertiesForKeys: [])
			XCTAssertEqual(items.count, 0)
		} else {
			XCTFail()
		}
	}
}
