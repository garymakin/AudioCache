//
//  AudioCache.swift
//

import Foundation
import CryptoKit

class AudioCache {

	static var shared: AudioCache = { AudioCache() }()

	private init() {
	}

	final func fetchAudio(from sourceURL: URL) async throws -> (URL, Data) {
		let localFileURL = try self.cacheURL(for: sourceURL)

		if FileManager.default.fileExists(atPath: localFileURL.path) {
			return try (localFileURL, Data(contentsOf: localFileURL))
		}

		// Not saved locally, so fetch from the source
		let (audioData, _) = try await URLSession.shared.data(from: sourceURL)
		try audioData.write(to: localFileURL)
		return (localFileURL, audioData)
	}

	final func removeCachedFile(for sourceURL: URL) async throws {
		let localFileURL = try self.cacheURL(for: sourceURL)
		try FileManager.default.removeItem(at: localFileURL)
	}

	open func cacheFolderURL() throws -> URL {
		let url = try FileManager.default.url(for: .applicationSupportDirectory,
										   in: .userDomainMask,
										   appropriateFor: nil,
										   create: true).appending(path: "Audio Cache")
		try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
		return url
	}

	private func cacheURL(for url: URL) throws -> URL {
		// Convert the URL to a Data object
		let hashed = SHA256.hash(data: Data(url.absoluteString.utf8))
		let hashString = hashed.compactMap { String(format: "%02x", $0) }.joined()

		return try cacheFolderURL().appendingPathComponent(hashString)
	}

}
