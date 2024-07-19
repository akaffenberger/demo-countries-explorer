//
//  CountryRepository.swift
//  CountriesExplorer
//
//  Created by Ashleigh Kaffenberger on 5/3/24.
//

import CoreData

class CountryRepository: Repository {
    typealias T = CountryEntity

    private let listFields: [CountryAPIRequest.Query.Fields]
    private let detailsFields: [CountryAPIRequest.Query.Fields]
    private let context: NSManagedObjectContext
    private let client: any CountryAPIClient<T>
    
    init(
        context: NSManagedObjectContext,
        client: any CountryAPIClient<T>,
        listFields: [CountryAPIRequest.Query.Fields] = [.name, .capital, .flags],
        detailsFields: [CountryAPIRequest.Query.Fields] = .Element.allCases
    ) {
        self.listFields = listFields
        self.detailsFields = detailsFields
        self.client = client
        self.context = context
    }

    func all() async throws -> [T] {
        if let cached = try await cachedAll(context: context) {
            return cached
        }

        let countries = try await client.all(fields: listFields)
        let context = countries.first?.managedObjectContext
        try await context?.perform {
            try context?.save()
        }
        return countries
    }

    func search(id: String) async throws -> [T] {
        guard let item: T = try await client.searchFullName(name: id, fields: detailsFields).first else {
            throw RepositoryError.itemNotFound
        }
        return [item]
    }
    
    func add(_ id: String) async throws {
        // no op
    }
    
    func remove(_ id: String) async throws {
        // no op
    }
    
    func removeAll() async throws {
        let all = try await self.all()
        try await context.perform {
            all.forEach { self.context.delete($0) }
            try self.context.save()
            self.context.reset()
            print("Cache cleared")
        }
    }
    
    private func cachedAll(context: NSManagedObjectContext) async throws -> [T]? {
        let results = await context.perform {
            let fetchRequest = NSFetchRequest<T>(entityName: "\(T.self)")
            do {
                return try context.fetch(fetchRequest)
            } catch {
                return []
            }
        }
        return !results.isEmpty ? results : nil
    }
}

extension CountryRepository {
    enum RepositoryError: Error {
        case itemNotFound
    }
}
