//
//  AudioCache.swift
//

import Foundation
import CryptoKit

/// A singleton class that can be used to download audio from remote URLs and cache the audio locally.
public class AudioCache {

	/// The singleton instance
	public static var shared: AudioCache = { AudioCache() }()

	/// The URLSession instance to use for fetching audio. Main purpose is to enable unit testing.
	public var urlSession = URLSession.shared

	/// The cached audio files are stored under the Application Support directory,
	/// in a folder named by `cacheFolderName`. Defaults to "Audio Cache".
	/// This folder  will be created if needed.
	public var cacheFolderName = "Audio Cache"

	private init() {
	}

	/// Loads remote audio from the given URL. It is saved on disk, in the cacheFolder.
	/// If the audio exists in the cache, it is loaded from there.
	///
	/// `sourceURL` is used as a key to reference the cached file. It is needed to remove the file.
	///
	/// - Parameter sourceURL: The remote URL source for the audio.
	///
	/// - Returns: A tuple of (local file: URL, audio: Data).
	public final func fetchAudio(from sourceURL: URL) async throws -> (URL, Data) {
		let localFileURL = try self.cacheURL(for: sourceURL)

		if FileManager.default.fileExists(atPath: localFileURL.path) {
			return try (localFileURL, Data(contentsOf: localFileURL))
		}

		// Not saved locally, so fetch from the source
		let (audioData, _) = try await urlSession.data(from: sourceURL)
		try audioData.write(to: localFileURL)
		return (localFileURL, audioData)
	}

	/// Removes the cached file for the given URL.
	/// - Parameter sourceURL: The remote URL source for the audio.
	public final func removeCachedFile(for sourceURL: URL) async throws {
		let localFileURL = try self.cacheURL(for: sourceURL)
		try FileManager.default.removeItem(at: localFileURL)
	}

	/// Returns the URL for the folder the cached files are stored in.
	///
	///  The cache folder is stored in the Application Support directory.
	///
	/// - Returns: URL for a local folder.
	open func cacheFolderURL() throws -> URL {
		let url = try FileManager.default.url(for: .applicationSupportDirectory,
										   in: .userDomainMask,
										   appropriateFor: nil,
										   create: true).appending(path: cacheFolderName)
		try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
		return url
	}

	// Returns the local file URL to store the cache for the given remote URL.
	private func cacheURL(for sourceURL: URL) throws -> URL {
		// Convert the URL to a Data object, hash it and format as Hex.
		let hashed = SHA256.hash(data: Data(sourceURL.absoluteString.utf8))
		let hashString = hashed.compactMap { String(format: "%02x", $0) }.joined()
		return try cacheFolderURL().appendingPathComponent(hashString)
	}

}
