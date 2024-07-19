//
//  BookmarkRepository.swift
//  CountriesExplorer
//
//  Created by Ashleigh Kaffenberger on 5/5/24.
//

import Foundation
import CoreData

class BookmarkRepository: Repository {
    typealias T = BookmarkEntity
    
    private let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    func all() async throws -> [T] {
        let context = context
        return await context.perform {
            let fetchRequest = NSFetchRequest<T>(entityName: "\(T.self)")
            do {
                return try context.fetch(fetchRequest)
            } catch {
                return []
            }
        }
    }
    
    func search(id: String) async throws -> [T] {
        let context = context
        return await context.perform {
            let fetchRequest = NSFetchRequest<T>(entityName: "\(T.self)")
            let predicate = NSPredicate(format: "id == %@", id)
            fetchRequest.predicate = predicate
            do {
                return try context.fetch(fetchRequest)
            } catch {
                return []
            }
        }
    }
    
    func add(_ id: String) async throws {
        if let _ = try await search(id: id).first {
            return
        } else {
            let context = context
            let item = T(context: context)
            item.id = id
            try await context.perform {
                try context.save()
            }
        }
    }
    
    func remove(_ id: String) async throws {
        let items = try await search(id: id)
        if items.count > 0 {
            let context = context
            try await context.perform {
                items.forEach { context.delete($0) }
                try context.save()
            }
        } else {
            return
        }
    }
    
    func removeAll() async throws {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "\(T.self)")
        fetchRequest.includesPropertyValues = false
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        try await context.perform {
            try self.context.execute(deleteRequest)
            self.context.reset()
        }
    }
}
