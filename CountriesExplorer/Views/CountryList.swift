//
//  CountryList.swift
//  CountriesExplorer
//
//  Created by Ashleigh Kaffenberger on 5/2/24.
//

import SwiftUI
import CoreData

struct CountryList<C: Country, B: Bookmark, R: RandomAccessCollection<C>>: View where C: Hashable, B: NSManagedObject {

    let repository: any Repository<C>
    var bookmarksRepository: (any Repository<B>)? = nil
    var countries: R
    
    var body: some View {
        List(countries, id: \.commonName) { country in
            CountryListItem(
                commonName: country.commonName,
                officialName: country.officialName,
                capital: country.capital,
                flag: country.flags?.png
            )
            .overlay(alignment: .topTrailing) {
                if let repository = bookmarksRepository {
                    BookmarkButton(
                        id: country.commonName ?? "",
                        repository: repository,
                        tapDisabled: true
                    )
                    .padding()
                }
            }
            .background {
                NavigationLink(value: country) {
                    Color.clear
                }
            }
            .listRowBackground(Color.clear)
            .listRowSeparator(.hidden)
            .listRowInsets(.init(top: 5, leading: 20, bottom: 10, trailing: 20))
        }
        .listStyle(.plain)
    }
}

#Preview {
    CountryList(
        repository: MockCountryRepository(),
        bookmarksRepository: MockBookmarkRepository(),
        countries: [MockCountryRepository.mockIreland]
    )
    .environment(\.managedObjectContext, CoreDataPersistenceService.preview.container.viewContext)
}
