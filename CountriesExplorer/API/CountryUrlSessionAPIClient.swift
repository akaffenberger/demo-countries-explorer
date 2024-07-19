//
//  CountryUrlSessionAPIClient.swift
//  CountriesExplorer
//
//  Created by Ashleigh Kaffenberger on 5/3/24.
//

import Foundation

class CountryUrlSessionAPIClient<T: Country & Decodable>: CountryAPIClient {
    typealias Query = CountryAPIRequest.Query
    
    private(set) var session: URLSession
    private(set) var decoder: JSONDecoder
    
    init(
        session: URLSession = .shared,
        decoder: JSONDecoder = JSONDecoder()
    ) {
        self.session = session
        self.decoder = decoder
    }
    
    func all(fields: [Query.Fields] = Query.Fields.allCases) async throws -> [T] {
        return try await getCollection(request: CountryAPIRequest(path: .all, query: [fields]))
    }
    
    func search(name: String, fields: [Query.Fields] = Query.Fields.allCases) async throws -> [T] {
        return try await getCollection(request: CountryAPIRequest(path: .name(name), query: [fields]))
    }
    
    func searchFullName(name: String, fields: [Query.Fields] = Query.Fields.allCases) async throws -> [T] {
        return try await getCollection(request: CountryAPIRequest(path: .name(name), query: [fields, [Query.FullText.enabled]]))
    }

    private func getCollection(request: CountryAPIRequest) async throws -> [T] {
        guard let url = URL(request) else { throw ClientError.invalidUrl }
        let (data, _) = try await session.data(from: url)
        let items = try decoder.decode([T].self, from: data)
        return items
    }
}

extension CountryUrlSessionAPIClient {
    enum ClientError: Error {
        case invalidUrl
    }
}

fileprivate extension URL {
    init?(_ request: CountryAPIRequest) {
        self.init(string: request.base)
        self.append(path: request.path.string)
        self.append(queryItems: request.query.compactMap { $0.queryItem })
    }
}

fileprivate extension Collection where Element == any CountryAPIRequestQuery {
    var queryItem: URLQueryItem? {
        if self.count > 0 {
            return URLQueryItem(name: self.first!.parameterName, value: self.map { String(describing: $0.rawValue) }.joined(separator: ","))
        } else {
            return nil
        }
    }
}
