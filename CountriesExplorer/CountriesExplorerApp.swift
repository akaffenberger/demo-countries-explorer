//
//  CountriesExplorerApp.swift
//  CountriesExplorer
//
//  Created by Ashleigh Kaffenberger on 5/2/24.
//

import SwiftUI

@main
struct CountriesExplorerApp: App {
    
    @Inject(\.persistenceContainerFactory) var persistenceContainerFactory
    @Inject(\.countryRepositoryFactory) var countryRepositoryFactory
    @Inject(\.bookmarksRepositoryFactory) var bookmarksRepositoryFactory

    var body: some Scene {
        WindowGroup {
            if ProcessInfo.isRunningUnitTests  {
                Text("Running tests")
            } else {
                ContentView(
                    countryRepository: countryRepositoryFactory(),
                    bookmarksRepository: bookmarksRepositoryFactory()
                )
                .environment(\.managedObjectContext, persistenceContainerFactory().viewContext)
                .preferredColorScheme(.light)
            }
        }
    }
}
