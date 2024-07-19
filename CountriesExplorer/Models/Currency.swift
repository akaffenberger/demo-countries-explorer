//
//  Currency.swift
//  CountriesExplorer
//
//  Created by Ashleigh Kaffenberger on 5/2/24.
//

import Foundation

protocol Currency {
    var name: String? { get }
    var symbol: String? { get }
    var abbreviation: String? { get }
}
