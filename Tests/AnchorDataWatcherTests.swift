//
//  AnchorDataWatcherTests.swift
//  Baretag iOS App
//
//  Created by Ken Su on 2/27/25.
//

import XCTest
@testable import Baretag_iOS_App

final class AnchorDataWatcherTests: XCTestCase {

    func testFetchAnchorsFromNewAPI() {
        let watcher = AnchorDataWatcher(useLocalFile: false)
        let testURL = "https://vital-dear-rattler.ngrok-free.app/get_anchors"

        let expectation = self.expectation(description: "Fetch anchors from test API")

        watcher.fetchServerAnchors(testURL: testURL)

        // Wait for async data to be fetched
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            if watcher.anchors.isEmpty {
                XCTFail("❌ No anchors were fetched.")
            } else {
                print("✅ Successfully fetched anchors: \(watcher.anchors)")
            }
            expectation.fulfill()
        }

        waitForExpectations(timeout: 5, handler: nil)
    }
}
