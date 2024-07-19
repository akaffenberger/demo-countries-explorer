//
//  CurrencyEntity+CoreDataProperties.swift
//  CountriesExplorer
//
//  Created by Ashleigh Kaffenberger on 5/3/24.
//
//

import CoreData

class CurrencyEntity: NSManagedObject, Currency, Decodable {

    enum CodingKeys: CodingKey {
        case name, symbol
    }
    
    public required convenience init(from decoder: any Decoder) throws {
        self.init(context: try decoder.managedObjectContext())
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.name = try container.decodeIfPresent(String.self, forKey: .name)
        self.symbol = try container.decodeIfPresent(String.self, forKey: .symbol)
    }
}
