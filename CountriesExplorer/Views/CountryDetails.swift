//
//  CountryDetails.swift
//  CountriesExplorer
//
//  Created by Ashleigh Kaffenberger on 5/2/24.
//

import SwiftUI
import Observation
import CoreData

struct CountryDetails<C: Country, B: Bookmark>: View where B: NSManagedObject {
    
    var model: CountryDetailsViewModel<C, B>
    
    @State private var tabSelection: Tab = .overview
    
    var body: some View {
        TabView(selection: $tabSelection) {
            CountryOverview(country: model.country, detailAction: { self.tabSelection = .maps })
                .redacted(reason: model.isLoading ? .placeholder : [])
                .tabItem { Label("Overview", systemImage: "star") }
                .tag(Tab.overview)
            
            CountryMaps(models: model.mapModels)
                .tabItem { Label("Maps", systemImage: "map").environment(\.symbolVariants, .none) }
                .tag(Tab.maps)
        }
        .toolbar {
            BookmarkButton(
                id: model.country.commonName ?? "",
                repository: model.bookmarkRepository
            )
        }
        .task {
            print("Loading country details")
            if let fullCountry = await model.search(for: model.country) {
                model.country = fullCountry
                
                withAnimation {
                    model.isLoading = false
                }
            }
        }
    }
    
    enum Tab {
        case overview
        case maps
    }
}

@Observable
class CountryDetailsViewModel<C: Country, B: Bookmark> {
    let repository: any Repository<C>
    let bookmarkRepository: any Repository<B>
    var country: C
    var isLoading: Bool =  true
    
    @ObservationIgnored
    var mapModels: [CountryMapViewModel] = []
    
    init(repository: any Repository<C>, bookmarkRepository: any Repository<B>, country: C) {
        self.repository = repository
        self.country = country
        self.bookmarkRepository = bookmarkRepository
    }
    
    func search(for country: C) async -> C? {
        do {
            if  let name = country.officialName,
                let fullCountry = try await repository.search(id: name).first {
                
                self.mapModels = [
                    .init(userTitle: "Your Current Location"),
                    .init(
                        title: "Country",
                        name: fullCountry.commonName,
                        coordinate: fullCountry.countryCoordinate,
                        area: fullCountry.area
                    ),
                    .init(
                        title: "Capital",
                        name: fullCountry.capital?.first,
                        coordinate: fullCountry.capitalCoordinate,
                        area: fullCountry.area
                    )
                ]
                return fullCountry
            } else {
                return nil
            }
        } catch {
            print(error)
            return nil
        }
    }
}

extension CountryDetailsViewModel: Equatable {
    static func == (lhs: CountryDetailsViewModel<C, B>, rhs: CountryDetailsViewModel<C, B>) -> Bool {
        lhs.country.commonName == rhs.country.commonName &&
        lhs.country.officialName == rhs.country.officialName &&
        lhs.country.region == rhs.country.region &&
        lhs.country.subregion == rhs.country.subregion &&
        lhs.country.population == rhs.country.population &&
        lhs.country.capital == rhs.country.capital &&
        lhs.country.area == rhs.country.area &&
        lhs.country.languages == rhs.country.languages &&
        lhs.country.car?.side == rhs.country.car?.side &&
        lhs.country.timezones == rhs.country.timezones
    }
}

#Preview {
    CountryDetails(
        model: CountryDetailsViewModel(
            repository: MockCountryRepository(),
            bookmarkRepository: MockBookmarkRepository(),
            country: MockCountryRepository.mockIreland
        )
    )
}
