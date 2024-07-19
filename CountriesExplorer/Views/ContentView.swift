//
//  ContentView.swift
//  CountriesExplorer
//
//  Created by Ashleigh Kaffenberger on 5/2/24.
//

import SwiftUI
import CoreData

struct ContentView<C: Country, B: Bookmark>: View where C: Hashable & NSManagedObject, B: NSManagedObject {
    
    var countryRepository: any Repository<C>
    var bookmarksRepository: any Repository<B>
    
    @State private var tabSelection: Tab = .search
    @State private var searchText: String = ""

    var body: some View {
        NavigationStack {
            TabView(selection: $tabSelection) {
                CountrySearchList(repository: countryRepository, bookmarksRepository: bookmarksRepository, searchText: $searchText)
                    .tabItem { Label("Search", systemImage: "magnifyingglass") }
                    .tag(Tab.search)

                CountryBookmarksList(repository: countryRepository, bookmarksRepository: bookmarksRepository)
                    .tabItem { Label("Saved", systemImage: "star") .environment(\.symbolVariants, .none) }
                    .tag(Tab.bookmarks)
            }
            .searchBarTranscribeButton(text: $searchText)
            .searchable(condition: tabSelection == .search, text: $searchText, placement: .navigationBarDrawer(displayMode: .always))
            .ignoresSafeArea()
            .navigationTitle(tabSelection == .search ? "Countries" : "Saved")
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(for: C.self) { model in
                CountryDetails(model: CountryDetailsViewModel(
                    repository: countryRepository,
                    bookmarkRepository: bookmarksRepository,
                    country: model
                ))
            }
        }
    }
    
    enum Tab {
        case search
        case bookmarks
    }
}

#Preview {
    ContentView(
        countryRepository: MockCountryRepository(),
        bookmarksRepository: MockBookmarkRepository()
    )
    .environment(\.managedObjectContext, CoreDataPersistenceService.preview.container.viewContext)
}
