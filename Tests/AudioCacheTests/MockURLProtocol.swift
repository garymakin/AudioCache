//
//  MockURLProtocol.swift
//

import Foundation

class MockURLProtocol: URLProtocol {
	static var data = [URL?: Data]()

	override class func canInit(with request: URLRequest) -> Bool {
		return true
	}

	override class func canonicalRequest(for request: URLRequest) -> URLRequest {
		return request
	}

	override func startLoading() {
		if let url = request.url {
			if let data = MockURLProtocol.data[url] {
				let response = URLResponse()
				client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
				client?.urlProtocol(self, didLoad: data)
			}
		}
		client?.urlProtocolDidFinishLoading(self)
	}

	override func stopLoading() {
	}

}
