//
//  CoreDataDecoder.swift
//  CountriesExplorer
//
//  Created by Ashleigh Kaffenberger on 5/3/24.
//

import CoreData

extension Decoder {
    func managedObjectContext() throws -> NSManagedObjectContext {
        guard let context = userInfo[.managedObjectContext] as? NSManagedObjectContext else {
            throw ManagedContextError.decoderMissingManagedObjectContext
        }
        return context
    }
}

extension CodingUserInfoKey {
    static let managedObjectContext = CodingUserInfoKey(rawValue: "managedObjectContext")!
}

enum ManagedContextError: Error {
    case decoderMissingManagedObjectContext
}
