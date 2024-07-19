//
//  MockCountryRepository.swift
//  CountriesExplorer
//
//  Created by Ashleigh Kaffenberger on 5/3/24.
//

import CoreData

class MockCountryRepository: Repository {
    typealias T = CountryEntity

    private var entities: [T] = []
    
    let context = CoreDataPersistenceService.preview.container.viewContext
    
    init() {
        self.entities = [
            Self.mockIreland,
            mockEntity(context: context, common: "United States", official: "United States of America"),
            mockEntity(context: context, common: "Moldova", official: "Republic of Moldova")
        ]
        do { try context.save() } catch {}
    }
    
    private func mockEntity(context: NSManagedObjectContext, common: String, official: String) -> T {
        let entity = T(context: context)
        entity.commonName = common
        entity.officialName = official
        return entity
    }
    
    func all() async throws -> [T] {
        return entities
    }
    
    func search(id: String) async throws -> [T] {
        return entities.filter { $0.commonName?.contains(id) ?? false || $0.officialName?.contains(id) ?? false }
    }
    
    func add(_ id: String) async throws {
        
    }
    
    func remove(_ id: String) async throws {
        
    }
    
    func removeAll() async throws {
        
    }
    
    static var mockIreland = {
        let context = CoreDataPersistenceService.preview.container.viewContext
        let ireland = T(context: context)
        ireland.commonName = "Ireland"
        ireland.officialName = "Republic of Ireland"
        ireland.area = 70723
        ireland.capitalObject = NSArray(array: ["Dublin"])
        ireland.capitalCoordinateObject = NSArray(array: [53.32, -6.23])
        ireland.carObject = CarEntity(context: context)
        ireland.carObject?.side = "left"
        ireland.coatOfArmsImage = CoatOfArmsEntity(context: context)
        ireland.coatOfArmsImage?.pngPath = "https://mainfacts.com/media/images/coats_of_arms/ie.png"
        ireland.countryCoordinateObject = NSArray(array: [53.0, -8.0])
        let currency = CurrencyEntity(context: context)
        currency.abbreviation = "EUR"
        currency.symbol = "€"
        currency.name = "Euro"
        ireland.currenciesSet = NSSet(array: [currency])
        ireland.flagsImage = FlagsEntity(context: context)
        ireland.flagsImage?.pngPath = "https://flagcdn.com/w320/ie.png"
        ireland.languagesObject = NSDictionary(dictionaryLiteral: ("eng", "English"), ("gle", "Irish"))
        ireland.population = 4994724
        ireland.region = "Europe"
        ireland.subregion = "Northern Europe"
        ireland.timezonesObject = NSArray(array: ["UTC"])
        return ireland
    }()
}
