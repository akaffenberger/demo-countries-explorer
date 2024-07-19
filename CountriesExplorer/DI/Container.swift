//
//  Container.swift
//  CountriesExplorer
//
//  Created by Ashleigh Kaffenberger on 5/3/24.
//

import Foundation
import CoreData

/// A singleton that holds properties that may be injected via key path.
/// Example: `@Inject(\.persistenceService) var persistenceService`
class Container {
    static let shared = Container()
    
    private init() {}
    
    lazy var locationService = LocationService()
    
    lazy var persistenceService = CoreDataPersistenceService()

    lazy var speechService = SpeechRecognizerService()
    
    lazy var countryAPIClient: CountryUrlSessionAPIClient<CountryEntity> = {
        @Inject(\.persistenceContainerFactory) var persistenceContainerFactory
        
        let jsonDecoder = JSONDecoder()
        jsonDecoder.userInfo[.managedObjectContext] = persistenceContainerFactory().newBackgroundContext()
        return CountryUrlSessionAPIClient(decoder: jsonDecoder)
    }()

    lazy var countryRepositoryFactory: () -> any Repository<CountryEntity> = {
        if ProcessInfo.isRunningTests {
            return MockCountryRepository()
        }
        
        @Inject(\.persistenceService) var persistence
        @Inject(\.countryAPIClient) var client
        
        return CountryRepository(context: persistence.container.viewContext, client: client)
    }
    
    lazy var bookmarksRepositoryFactory: () -> any Repository<BookmarkEntity> = {
        if ProcessInfo.isRunningTests {
            return MockBookmarkRepository()
        }
        
        @Inject(\.persistenceService) var persistence
        
        return BookmarkRepository(context: persistence.container.viewContext)
    }
    
    lazy var persistenceContainerFactory: () -> NSPersistentContainer = {
        if ProcessInfo.isRunningTests {
            return CoreDataPersistenceService.preview.container
        }
        
        @Inject(\.persistenceService) var persistence
        return persistence.container
    }
}
