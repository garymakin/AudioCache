# AudioCache


A Swift class for downloading and caching audio.

Supports iOS, iPadOS, macOS, tvOS.

## API

### `fetchAudio(from:)`

Fetch audio from a remote URL with:

```swift
AudioCache.shared.fetchAudio(from: URL) async throws -> (URL, Data)
```

This stores the audio in the cache directory and returns a tuple with:
 * the URL to the cached file, and
 * a Data instance with the contents.

Further calls return the cached file without fetching from the remote URL.

### `removeCachedFile(for:)`

The cached file can be removed using `removeCachedFile(for:)` with the original remote URL as the key:
 
```swift
AudioCache.shared.removeCachedFile(for: URL) async throws
```

## Usage

```swift
// Load the audio requested by the user
let url = URL(string: "http://...")
let (localURL, audioData) = try await AudioCache.shared.fetchAudio(from: url)

...

// When the user is finished with the audio 
AudioCache.shared.removeCachedFile(for: url)
```


## Settings

The cached files are stored in the Application Support directory, in a folder named "Audio Cache".
This folder name is stored in `AudioCache.shared.cacheFolderName`.
Note: Do not localise this string, as the cache would change location, leaving orphaned files. 

```swift
AudioCache.shared.cacheFolderName = "My cache folder"
```

The URLSession can be set. It defaults to `URLSession.shared`.

```swift
AudioCache.shared.urlSession = myURLSession
```


## Installation via Xcode

To add AudioCache as a Package Dependancy:

1. With your project open in Xcode, select **File** → **Add Package Dependancies…**.
2. Paste the GitHub repo URL `https://github.com/garymakin/AudioCache.git`
3. Click the **Copy Dependancy** button.

The packages can be managed in Xcode, along side the Build Settings for the project. 
