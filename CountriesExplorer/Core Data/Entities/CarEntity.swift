//
//  CarEntity+CoreDataProperties.swift
//  CountriesExplorer
//
//  Created by Ashleigh Kaffenberger on 5/3/24.
//
//

import CoreData

class CarEntity: NSManagedObject, Car, Decodable {
    
    enum CodingKeys: CodingKey {
        case side
    }
    
    public required convenience init(from decoder: any Decoder) throws {
        self.init(context: try decoder.managedObjectContext())
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.side = try container.decodeIfPresent(String.self, forKey: .side)
    }
}
