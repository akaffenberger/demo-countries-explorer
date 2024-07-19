//
//  CountriesExplorerTests.swift
//  CountriesExplorerTests
//
//  Created by Ashleigh Kaffenberger on 5/2/24.
//

import XCTest
@testable import CountriesExplorer

import XCTest
@testable import CountriesExplorer

final class CountriesExplorerTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        // Any test you write for XCTest can be annotated as throws and async.
        // Mark your test throws to produce an unexpected failure when your test encounters an uncaught error.
        // Mark your test async to allow awaiting for asynchronous code to complete. Check the results with assertions afterwards.
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
    func testInject() throws {
        @Inject(\.locationService) var service1
        @Inject(\.locationService) var service2
        
        XCTAssert(service1 === service2, "Expected singleton injection, got two instances")
    }
    
    func testUrlSessionAPIClient() async throws {
        @Inject(\.countryAPIClient) var client
        client.session.configuration.protocolClasses = [MockURLProtocol.self]
        MockURLProtocol.responseJsonFileName = "mockCountryListResponse"
        
        do {
            let data = try await client.all()
            XCTAssert(!data.isEmpty, "Data should not be empty")
            data.forEach {
                XCTAssertNotNil($0.commonName, "Common name should not be nil")
                XCTAssertNotNil($0.officialName, "Official name should not be nil")
                XCTAssertNotNil($0.capital, "Capital should not be nil")
                XCTAssertNotNil($0.flags?.png, "Flags should not be nil")
            }
        } catch {
            XCTFail("Error was not expected | \(error)")
        }
    }
    
    func testCountryRepositoryList() async throws {
        @Inject(\.countryAPIClient) var client
        @Inject(\.persistenceContainerFactory) var persistenceContainerFactory
        
        client.session.configuration.protocolClasses = [MockURLProtocol.self]
        MockURLProtocol.responseJsonFileName = "mockCountryListResponse"
        let repository = CountryRepository(context: persistenceContainerFactory().viewContext, client: client)
        
        do {
            let data = try await repository.all()
            XCTAssert(!data.isEmpty, "Data should not be empty")
            data.forEach {
                XCTAssertNotNil($0.commonName, "Common name should not be nil")
                XCTAssertNotNil($0.officialName, "Official name should not be nil")
                XCTAssertNotNil($0.capital, "Capital should not be nil")
                XCTAssertNotNil($0.flags?.png, "Flags should not be nil")
                XCTAssert($0.region == nil)
            }
        } catch {
            XCTFail("Error was not expected | \(error)")
        }
    }
    
    func testCountryRepositoryDetails() async throws {
        @Inject(\.countryAPIClient) var client
        @Inject(\.persistenceContainerFactory) var persistenceContainerFactory
        
        client.session.configuration.protocolClasses = [MockURLProtocol.self]
        MockURLProtocol.responseJsonFileName = "mockCountryDetailsResponse"
        let repository = CountryRepository(context: persistenceContainerFactory().viewContext, client: client)
        
        do {
            let data = try await repository.search(id: "Ireland")
            XCTAssert(data.count == 1, "Data should not be empty")
            let item = data.first!
            XCTAssert(item.commonName == "Ireland")
            XCTAssert(item.officialName == "Republic of Ireland")
            XCTAssert(item.capital?.first == "Dublin")
            XCTAssert(item.car?.side == "left")
            XCTAssert(item.coatOfArmsImage?.pngPath == "https://mainfacts.com/media/images/coats_of_arms/ie.png")
            XCTAssert(item.currencies?.first?.name == "Euro")
            XCTAssert(item.currencies?.first?.symbol == "€")
            XCTAssert(item.currencies?.first?.abbreviation == "EUR")
            XCTAssert(item.flagsImage?.pngPath == "https://flagcdn.com/w320/ie.png")
            XCTAssert(item.languages?.values.contains("English") ?? false)
            XCTAssert(item.languages?.values.contains("Irish") ?? false)
            XCTAssert(item.population == 4994724)
            XCTAssert(item.region == "Europe")
            XCTAssert(item.subregion == "Northern Europe")
        } catch {
            XCTFail("Error was not expected | \(error)")
        }
        
    }
    
    func testBookmarks() async throws {
        @Inject(\.bookmarksRepositoryFactory) var repositoryFactory
        
        let repository = repositoryFactory()
        
        do {
            try await repository.removeAll()
            try await repository.add("Ireland")
            
            let bookmarks = try await repository.search(id: "Ireland")
            XCTAssert(bookmarks.count == 1)
            XCTAssert(bookmarks.first!.id == "Ireland")
            
            try await repository.add("United States")
            
            let bookmarksAll = try await repository.all()
            XCTAssert(bookmarksAll.count == 2)
            XCTAssert(bookmarksAll.contains(where: { $0.id == "United States" }))
            XCTAssert(bookmarksAll.contains(where: { $0.id == "Ireland" }))
            
            try await repository.remove("Ireland")
            try await repository.remove("United States")
            
            let bookmarksEmpty = try await repository.search(id: "Ireland")
            XCTAssert(bookmarksEmpty.isEmpty)
            
        } catch {
            XCTFail("Error was not expected")
        }
    }
}
