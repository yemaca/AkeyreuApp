//
//  RokuTVControlTests.swift
//  RokuTVTests
//
//  Created by Asher Amey on 9/4/24.
//

import XCTest
@testable import Akeyreu

class RokuTVControlTests: XCTestCase {
    var rokuTVControl: RokuTVControl!

    override func setUp() {
        super.setUp()
        // Initialize with the correct IP address of the actual Roku TV or a test IP
        rokuTVControl = RokuTVControl(ip: "192.168.1.35")
    }

    override func tearDown() {
        rokuTVControl = nil
        super.tearDown()
    }

    func testTogglePower() {
        let expectation = self.expectation(description: "Toggling power should succeed")

        rokuTVControl.togglePower { success in
            XCTAssertTrue(success, "Toggle Power should succeed")
            expectation.fulfill()
        }

        waitForExpectations(timeout: 5, handler: nil)
    }

    func testTogglePowerAtScheduledTime() {
        let expectation = self.expectation(description: "Power should toggle at the scheduled time")

        let scheduledTime = Date().addingTimeInterval(5)  // Schedule for 5 seconds from now
        Timer.scheduledTimer(withTimeInterval: 5.0, repeats: false) { _ in
            self.rokuTVControl.togglePower { success in
                XCTAssertTrue(success, "Toggle Power at scheduled time should succeed")
                expectation.fulfill()
            }
        }

        waitForExpectations(timeout: 10, handler: nil)
    }
}
