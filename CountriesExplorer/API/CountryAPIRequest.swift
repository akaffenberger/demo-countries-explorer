//
//  CountryAPIRequest.swift
//
//
//  Created by Ashleigh Kaffenberger on 5/3/24.
//

import Foundation

struct CountryAPIRequest {
    var base: String = "https://restcountries.com/v3.1/"
    var path: Path
    var method: Method = .get
    var query: [[any CountryAPIRequestQuery]]
    
    enum Path {
        case all
        case name(String)
        
        var string: String {
            switch self {
            case .all: "all"
            case .name(let name): "name/\(name)"
            }
        }
    }
    
    enum Method {
        case get
    }
    
    struct Query {
        enum Fields: String, CountryAPIRequestQuery {
            var parameterName: String { "fields" }
            
            case name,
                 flags,
                 capital,
                 region,
                 subregion,
                 languages,
                 currencies,
                 population,
                 car,
                 coatOfArms,
                 timezones,
                 latlng,
                 capitalInfo,
                 area;
        }
        
        enum FullText: String, CountryAPIRequestQuery {
            var parameterName: String { "fullText" }
            
            case enabled = "true"
        }
    }
}

protocol CountryAPIRequestQuery: CaseIterable, RawRepresentable {
    var parameterName: String { get }
}
