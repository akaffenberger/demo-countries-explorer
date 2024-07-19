//
//  CountryMaps.swift
//  CountriesExplorer
//
//  Created by Ashleigh Kaffenberger on 5/7/24.
//

import SwiftUI
import MapKit

struct CountryMaps: View {
    let models: [CountryMapViewModel]
    
    @Inject(\.locationService) private var locationService: LocationService
    
    var body: some View {
        ScrollView {
            VStack {
                if locationService.hasAuthorizationStatus {
                    ForEach(models) { model in
                        CountryMap(model: model)
                    }
                }
            }
            .padding(.top)
        }
        .task {
            locationService.start()
        }
    }
}

fileprivate struct CountryMap: View {
    var model: CountryMapViewModel
    
    @Inject(\.locationService) private var locationService: LocationService

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if let position = model.position {
                Text(model.title)
                    .font(.system(size: 16, weight: .heavy))
                    .foregroundStyle(Color.gray) +
                
                Text(model.name != nil ? " - " + model.name! : "")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(Color.gray)
                
                Map(initialPosition: position) {
                    if model.useUserPosition {
                        UserAnnotation()
                    }
                }
                .mapControls {
                    MapUserLocationButton()
                }
                .frame(height: 400)
                .padding(.bottom)
            }
        }
        .padding(.horizontal)
        .transition(.slide)
        .task {
            if !model.useUserPosition {
                let regionPosition = await model.updateRegionPosition()
                model.position = regionPosition
            }
        }
        .task(id: locationService.location) {
            if model.useUserPosition {
                let userPosition = model.updateUserPosition(locationService: locationService)
                model.position = userPosition
            }
        }
    }
}

@Observable 
class CountryMapViewModel: Identifiable {
    var id: String { title }
    var country: (any Country)?
    var title: String
    var name: String?
    var coordinate: CLLocationCoordinate2D?
    var area: Float?
    var searchLocalMaps: Bool = true
    var useUserPosition: Bool = false
    var position: MapCameraPosition?
    
    init(
        title: String,
        name: String?,
        coordinate: [Float]?,
        area: Float,
        searchLocalMaps: Bool = true
    ) {
        self.title = title
        self.name = name
        self.coordinate = coordinate?.toCLLocationCoordinate2D()
        self.area = area
        self.searchLocalMaps = searchLocalMaps
    }
    
    init(userTitle: String) {
        self.title = userTitle
        self.useUserPosition = true
    }
    
    func updateUserPosition(locationService: LocationService) -> MapCameraPosition? {
        if let location = locationService.location {
            return .camera(MapCamera(
                centerCoordinate: location.coordinate,
                distance: 800,
                heading: locationService.direction
            ))
        } else {
            return nil
        }
    }
    
    func updateRegionPosition() async -> MapCameraPosition? {
        guard let coordinate = coordinate else {
            return nil
        }
        
        let area = self.area ?? 0
        let diameter = 2 * Double(sqrt((area / Float.pi)) * 1000)
        let region = MKCoordinateRegion(
            center: coordinate,
            latitudinalMeters: diameter,
            longitudinalMeters: diameter
        )
        
        if !searchLocalMaps {
            return .region(region)
        }
        
        let searchRequest = MKLocalSearch.Request()
        searchRequest.naturalLanguageQuery = name
        searchRequest.region = region
        let search = MKLocalSearch(request: searchRequest)
        
        do {
            let response = try await search.start()
            return .region(response.boundingRegion)
            
        } catch {
            print(error)
            return .region(region)
        }
    }
}

#Preview {
    CountryMaps(models: [
        .init(userTitle: "Your Current Location"),
        .init(
            title: "Country",
            name: MockCountryRepository.mockIreland.commonName,
            coordinate: MockCountryRepository.mockIreland.countryCoordinate,
            area: MockCountryRepository.mockIreland.area
        ),
        .init(
            title: "Capital",
            name: MockCountryRepository.mockIreland.capital?.first,
            coordinate: MockCountryRepository.mockIreland.capitalCoordinate,
            area: MockCountryRepository.mockIreland.area
        )
    ])
}

extension Collection where Element == Float {
    func toCLLocationCoordinate2D() -> CLLocationCoordinate2D? {
        guard self.count == 2 else { return nil }
        
        return CLLocationCoordinate2D(
            latitude: CLLocationDegrees(self[self.startIndex]),
            longitude: CLLocationDegrees(self[self.index(after: self.startIndex)])
        )
    }
}
