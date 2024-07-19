//
//  CountrySearchList.swift
//  CountriesExplorer
//
//  Created by Ashleigh Kaffenberger on 5/7/24.
//

import SwiftUI
import CoreData
import Combine

struct CountrySearchList<C: Country, B: Bookmark>: View where C: NSManagedObject, B: NSManagedObject {

    let repository: any Repository<C>
    let bookmarksRepository: any Repository<B>
    let searchText: Binding<String>
    
    @FetchRequest(
        entity: C.entity(),
        sortDescriptors: [NSSortDescriptor(key: "commonName", ascending: true)]
    )
    var countries: FetchedResults<C>
    
    var body: some View {
        CountryList(
            repository: repository,
            bookmarksRepository: bookmarksRepository,
            countries: countries
        )
        .task(id: searchText.wrappedValue) {
            let text = searchText.wrappedValue
            if text.count >= 2  {
                self.countries.nsPredicate = NSPredicate(format: "officialName CONTAINS[c] %@ || commonName CONTAINS[c] %@", text, text)
            } else {
                _ = try? await repository.all()
                self.countries.nsPredicate = nil
            }
        }
        .refreshable {
            Task {
                try await repository.removeAll()
                _ = try? await repository.all()
            }
        }
    }
}

#Preview {
    CountrySearchList(
        repository: MockCountryRepository(),
        bookmarksRepository: MockBookmarkRepository(),
        searchText: .constant("")
    )
    .environment(\.managedObjectContext, CoreDataPersistenceService.preview.container.viewContext)
}
