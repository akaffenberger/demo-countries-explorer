//
//  CountryAPIClient.swift
//  CountriesExplorer
//
//  Created by Ashleigh Kaffenberger on 5/3/24.
//

import Foundation

protocol CountryAPIClient<T> {
    associatedtype T: Country & Decodable
    
    func all(fields: [CountryAPIRequest.Query.Fields]) async throws -> [T]
    func search(name: String, fields: [CountryAPIRequest.Query.Fields]) async throws -> [T]
    func searchFullName(name: String, fields: [CountryAPIRequest.Query.Fields]) async throws -> [T]
}
