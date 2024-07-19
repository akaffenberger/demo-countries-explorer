//
//  ProcessInfo.swift
//  CountriesExplorer
//
//  Created by Ashleigh Kaffenberger on 5/9/24.
//

import Foundation

extension ProcessInfo {
    static var isRunningUnitTests: Bool {
        #if DEBUG
        ProcessInfo.processInfo.environment[.isRunningUnitTests] != nil
        #else
        false
        #endif
    }
    
    static var isRunningUITests: Bool {
        #if DEBUG
        ProcessInfo.processInfo.arguments.contains(.isRunningUITests)
        #else
        false
        #endif
    }
    
    static var isRunningTests: Bool {
        return isRunningUnitTests || isRunningUITests
    }
}

extension String {
    static var isRunningUnitTests: Self = "XCTestConfigurationFilePath"
    static var isRunningUITests: Self = "isRunningUITests"
}
