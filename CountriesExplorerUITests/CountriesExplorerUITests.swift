//
//  CountriesExplorerUITests.swift
//  CountriesExplorerUITests
//
//  Created by Ashleigh Kaffenberger on 5/2/24.
//

import XCTest

final class CountriesExplorerUITests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testLaunchPerformance() throws {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 7.0, *) {
            // This measures how long it takes to launch your application.
            measure(metrics: [XCTApplicationLaunchMetric()]) {
                XCUIApplication().launch()
            }
        }
    }
    
    func testTabView() throws {
        let app = XCUIApplication()
        app.launchArguments = [.isRunningUITests]
        app.launch()
        
        let search = app.tabBars.buttons["Search"]
        let bookmarks = app.tabBars.buttons["Saved"]

        XCTAssert(search.exists)
        XCTAssert(bookmarks.exists)
    }
    
    func testSearchList() throws {
        let app = XCUIApplication()
        app.launchArguments = [.isRunningUITests]
        app.launch()
        app.tabBars.buttons["Search"].tap()
        
        let countriesNavigationBar = app.navigationBars["Countries"]
        let searchSearchField = countriesNavigationBar.searchFields["Search"]
        
        searchSearchField.tap()
        searchSearchField.typeText("Ireland")
        
        let cell = app.collectionViews.children(matching: .cell).element(boundBy: 0)
        
        XCTAssert(cell.staticTexts["Ireland"].exists)
        XCTAssert(cell.staticTexts["Republic of Ireland"].exists)
        XCTAssert(cell.staticTexts["Dublin"].exists)
        
        countriesNavigationBar.buttons["SearchBarTranscribeButton"].tap()
    }
    
    func testCountryDetails() throws {
        let app = XCUIApplication()
        app.launchArguments = [.isRunningUITests]
        app.launch()
        app.tabBars.buttons["Search"].tap()
        app.collectionViews.children(matching: .cell).element(boundBy: 0).tap()
        
        let elementsQuery = app.scrollViews.otherElements
        XCTAssert(elementsQuery.staticTexts["Europe"].exists)
        XCTAssert(elementsQuery.staticTexts["Northern Europe"].exists)
        XCTAssert(elementsQuery.staticTexts["Dublin"].exists)
        XCTAssert(elementsQuery.staticTexts["UTC"].exists)
        XCTAssert(elementsQuery.staticTexts["4,994,724"].exists)
        XCTAssert(elementsQuery.staticTexts["English"].exists)
        XCTAssert(elementsQuery.staticTexts["Irish"].exists)
        XCTAssert(elementsQuery.staticTexts["EUR (€ Euro)"].exists)
        XCTAssert(elementsQuery.staticTexts["LEFT"].exists)
        XCTAssert(elementsQuery.images["car.circle"].exists)
        XCTAssert(elementsQuery.staticTexts["RIGHT"].exists)
        XCTAssert(app.tabBars.buttons["Overview"].exists)
        XCTAssert(app.tabBars.buttons["Maps"].exists)
    }
    
    func testBookmark() throws {
        let app = XCUIApplication()
        app.launchArguments = [.isRunningUITests]
        app.launch()
        app.tabBars.buttons["Search"].tap()
        app.collectionViews.children(matching: .cell).element(boundBy: 0).tap()
        app.navigationBars/*@START_MENU_TOKEN@*/.buttons["Bookmark"]/*[[".otherElements[\"Bookmark\"].buttons[\"Bookmark\"]",".buttons[\"Bookmark\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        app.navigationBars.buttons["Countries"].tap()
        app.tabBars.buttons["Saved"].tap()
        
        let cell = app.collectionViews.children(matching: .cell).element(boundBy: 0)
        
        XCTAssert(cell.staticTexts["Ireland"].exists)
        XCTAssert(cell.staticTexts["Republic of Ireland"].exists)
        XCTAssert(cell.staticTexts["Dublin"].exists)
    }
}
