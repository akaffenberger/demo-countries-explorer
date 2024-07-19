//
//  Country.swift
//  CountriesExplorer
//
//  Created by Ashleigh Kaffenberger on 5/2/24.
//

import Foundation

protocol Country {
    associatedtype C: Car
    associatedtype I: CountryImage
    associatedtype U: Currency
    
    var commonName: String? { get }
    var officialName: String? { get }
    var area: Float { get }
    var capital: [String]? { get }
    var capitalCoordinate: [Float]? { get }
    var car: C? { get }
    var coatOfArms: I? { get }
    var countryCoordinate: [Float]? { get }
    var currencies: [U]? { get }
    var flags: I? { get }
    var languages: [String: String]? { get }
    var population: Int64 { get }
    var region: String? { get }
    var subregion: String? { get }
    var timezones: [String]? { get }
}

protocol Bookmark {
    var id: String? { get }
}
