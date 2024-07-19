//
//  MockUrlProtocol.swift
//  CountriesExplorerTests
//
//  Created by Ashleigh Kaffenberger on 5/3/24.
//

import Foundation

class MockURLProtocol: URLProtocol {
    
    static var responseJsonFileName: String = ""
    
    static var requestHandler: ((URLRequest) throws -> (HTTPURLResponse, Data?))?
  
    override class func canInit(with request: URLRequest) -> Bool {
        return true
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }

    override func startLoading() {
        if let handler = MockURLProtocol.requestHandler {
            do {
                let (response, data) = try handler(request)
                client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
                if let data = data {
                    client?.urlProtocol(self, didLoad: data)
                }
                client?.urlProtocolDidFinishLoading(self)
                return
            } catch {
                client?.urlProtocol(self, didFailWithError: error)
                return
            }
        }
        
        if !MockURLProtocol.responseJsonFileName.isEmpty {
            if let path = Bundle.main.path(forResource: MockURLProtocol.responseJsonFileName, ofType: "json") {
                do {
                    let response = HTTPURLResponse(url: self.request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
                    client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
                    let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                    client?.urlProtocol(self, didLoad: data)
                    return
                } catch {
                    client?.urlProtocol(self, didFailWithError: error)
                    return
                }
            }
        }
        
        fatalError("No handler or json file was set to mock response")
    }
}
