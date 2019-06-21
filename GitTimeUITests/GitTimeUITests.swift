//
//  GitTimeUITests.swift
//  GitTimeUITests
//
//  Created by Kanz on 09/05/2019.
//  Copyright © 2019 KanzDevelop. All rights reserved.
//

import XCTest

class GitTimeUITests: XCTestCase {

    override func setUp() {
        continueAfterFailure = false
        
        let app = XCUIApplication()
        setupSnapshot(app)
        app.launch()
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testScreenShot() {
        
        let app = XCUIApplication()
        
        let tabBarsQuery = app.tabBars
        tabBarsQuery.buttons["Activity"].tap()
        snapshot("0Activity")
        
        tabBarsQuery.buttons["Trending"].tap()
        snapshot("1Trending")
        
        tabBarsQuery.buttons["Follow"].tap()
        snapshot("2Follow")
        
        tabBarsQuery.buttons["Setting"].tap()
        snapshot("3Setting")
    }
}
