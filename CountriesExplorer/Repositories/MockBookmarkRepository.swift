//
//  MockBookmarkRepository.swift
//  CountriesExplorer
//
//  Created by Ashleigh Kaffenberger on 5/5/24.
//

import CoreData

class MockBookmarkRepository: BookmarkRepository {
    convenience init() {
        self.init(context: CoreDataPersistenceService.preview.container.viewContext)
    }
}
