//
//  ImageEntity+CoreDataProperties.swift
//  CountriesExplorer
//
//  Created by Ashleigh Kaffenberger on 5/3/24.
//
//

import CoreData

class ImageEntity: NSManagedObject, CountryImage, Decodable {
    var png: URL? {
        return URL(string: self.pngPath ?? "")
    }
    
    enum CodingKeys: String, CodingKey {
        case pngPath = "png"
    }
    
    public required convenience init(from decoder: any Decoder) throws {
        self.init(context: try decoder.managedObjectContext())
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.pngPath = try container.decodeIfPresent(String.self, forKey: .pngPath)
    }
}

class CoatOfArmsEntity: ImageEntity {}
class FlagsEntity: ImageEntity {}
