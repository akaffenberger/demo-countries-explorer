//
//  Inject.swift
//  CountriesExplorer
//
//  Created by Ashleigh Kaffenberger on 5/3/24.
//

import Foundation

@propertyWrapper
struct Inject<Service> {

    private var service: Service
    
    var wrappedValue: Service {
        get { self.service }
        set { service = newValue }
    }

    init(_ keyPath: KeyPath<Container, Service>) {
        self.service = Container.shared[keyPath: keyPath]
    }
}
