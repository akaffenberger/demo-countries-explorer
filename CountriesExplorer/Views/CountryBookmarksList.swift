//
//  CountryBookmarksList.swift
//  CountriesExplorer
//
//  Created by Ashleigh Kaffenberger on 5/7/24.
//

import SwiftUI
import CoreData

struct CountryBookmarksList<C: Country, B: Bookmark>: View where C: NSManagedObject, B: NSManagedObject {
    
    let repository: any Repository<C>
    let bookmarksRepository: any Repository<B>
    
    @FetchRequest(
        entity: B.entity(),
        sortDescriptors: [NSSortDescriptor(key: "id", ascending: true)]
    )
    var bookmarks: FetchedResults<B>
    
    @FetchRequest(
        entity: C.entity(),
        sortDescriptors: [NSSortDescriptor(key: "commonName", ascending: true)],
        predicate: NSPredicate(format: "commonName IN %@", [])
    )
    var countries: FetchedResults<C>
    
    var body: some View {
        CountryList<C, B, FetchedResults<C>>(
            repository: repository,
            countries: countries
        )
        .onReceive(bookmarks.publisher.collect()) { values in
            self.countries.nsPredicate = NSPredicate(format: "commonName IN %@", bookmarks.map { $0.id })
        }
    }
}

#Preview {
    CountryBookmarksList(
        repository: MockCountryRepository(),
        bookmarksRepository: MockBookmarkRepository()
    )
    .environment(\.managedObjectContext, CoreDataPersistenceService.preview.container.viewContext)
}
