//
//  CountryEntity+CoreDataClass.swift
//  CountriesExplorer
//
//  Created by Ashleigh Kaffenberger on 5/3/24.
//
//

import CoreData

class CountryEntity: NSManagedObject, Country, Decodable {
    
    var countryCoordinate: [Float]? {
        self.countryCoordinateObject as? [Float]
    }
    
    var capitalCoordinate: [Float]? {
        self.capitalCoordinateObject as? [Float]
    }
    
    var car: CarEntity? {
        self.carObject
    }
    
    var timezones: [String]? {
        self.timezonesObject as? [String]
    }

    var capital: [String]? {
        self.capitalObject as? [String]
    }
    
    var coatOfArms: ImageEntity? {
        self.coatOfArmsImage
    }
    
    var currencies: [CurrencyEntity]? {
        self.currenciesSet?.allObjects as? [CurrencyEntity]
    }
    
    var flags: ImageEntity? {
        self.flagsImage
    }
    
    var languages: [String : String]? {
        self.languagesObject as? [String: String]
    }
    
    enum CodingKeys: String, CodingKey {
        case population,
             region,
             subregion,
             coatOfArmsImage = "coatOfArms",
             flagsImage = "flags",
             nameObject = "name",
             capitalObject = "capital",
             languagesObject = "languages",
             currenciesSet = "currencies",
             carObject = "car",
             timezonesObject = "timezones",
             capitalCoordinateObject = "capitalInfo",
             countryCoordinateObject = "latlng",
             area
    }
    
    enum NameCodingKeys: String, CodingKey {
        case common, official
    }
    
    enum CapitalInfoCodingKeys: String, CodingKey {
        case capitalCoordinate = "latlng"
    }
    
    public required convenience init(from decoder: any Decoder) throws {
        self.init(context: try decoder.managedObjectContext())
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.area = try container.decodeIfPresent(Float.self, forKey: .area) ?? 0
        self.population = try container.decodeIfPresent(Int64.self, forKey: .population) ?? 0
        self.region = try container.decodeIfPresent(String.self, forKey: .region)
        self.subregion = try container.decodeIfPresent(String.self, forKey: .subregion)
        self.coatOfArmsImage = try container.decodeIfPresent(CoatOfArmsEntity.self, forKey: .coatOfArmsImage)
        self.flagsImage = try container.decodeIfPresent(FlagsEntity.self, forKey: .flagsImage)
        self.capitalObject = try container.decodeIfPresent([String].self, forKey: .capitalObject) as? NSObject
        self.languagesObject = try container.decodeIfPresent([String: String].self, forKey: .languagesObject) as? NSObject
        if let currenciesDictionary = try container.decodeIfPresent([String: CurrencyEntity].self, forKey: .currenciesSet) {
            currenciesDictionary.forEach { $0.value.abbreviation = $0.key }
            self.currenciesSet = NSSet(array: Array(currenciesDictionary.values))
        }
        self.carObject = try container.decodeIfPresent(CarEntity.self, forKey: .carObject)
        self.timezonesObject = try container.decodeIfPresent([String].self, forKey: .timezonesObject) as? NSObject
        self.countryCoordinateObject = try container.decodeIfPresent([Float].self, forKey: .countryCoordinateObject) as? NSObject
        do {
            let capitalInfoContainer = try container.nestedContainer(keyedBy: CapitalInfoCodingKeys.self, forKey: .capitalCoordinateObject)
            self.capitalCoordinateObject = try capitalInfoContainer.decodeIfPresent([Float].self, forKey: .capitalCoordinate) as? NSObject
        } catch {
            self.capitalCoordinateObject = nil
        }
        do {
            let nameContainer = try container.nestedContainer(keyedBy: NameCodingKeys.self, forKey: .nameObject)
            self.commonName = try nameContainer.decodeIfPresent(String.self, forKey: .common)
            self.officialName = try nameContainer.decodeIfPresent(String.self, forKey: .official)
        } catch {
        }
    }
}
