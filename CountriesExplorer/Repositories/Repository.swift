//
//  Repository.swift
//  CountriesExplorer
//
//  Created by Ashleigh Kaffenberger on 5/3/24.
//

import Foundation

protocol Repository<T> {
    associatedtype T

    func all() async throws -> [T]
    func search(id: String) async throws -> [T]
    func add(_ id: String) async throws
    func remove(_ id: String) async throws
    func removeAll() async throws
}
