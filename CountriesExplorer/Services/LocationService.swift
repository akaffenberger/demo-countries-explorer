//
//  LocationService.swift
//  CountriesExplorer
//
//  Created by Ashleigh Kaffenberger on 5/7/24.
//

import CoreLocation

@Observable
class LocationService: NSObject, CLLocationManagerDelegate {
    var location: CLLocation?
    var direction: CLLocationDirection = .zero
    var hasAuthorizationStatus: Bool = false
    
    private let locationManager = CLLocationManager()
    
    func start() async {
        if locationManager.delegate !== self {
            locationManager.startUpdatingLocation()
            locationManager.delegate = self
            try? await requestAuthorization()
        }
    }
    
    func requestAuthorization() async throws {
        if locationManager.authorizationStatus == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
        } else {
            hasAuthorizationStatus = true
        }
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        self.hasAuthorizationStatus = true
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        locations.forEach {
            self.location = $0
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        self.direction = newHeading.trueHeading
    }
}
