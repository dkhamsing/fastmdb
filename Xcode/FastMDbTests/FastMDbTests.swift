//
//  FastMDbTests.swift
//  FastMDbTests
//
//  Created by Daniel on 5/12/20.
//  Copyright © 2020 dk. All rights reserved.
//

import XCTest

@testable import FastMDb

class MoviesTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testYearDisplayNil() throws {
        // Given
        let str: String? = nil

        // Then
        XCTAssertTrue(str.yearDisplay == "")
    }

    func testYearDisplayForTmdbReleaseDate() throws {
        // Given
        let str: String? = "2019-09-17"

        // Then
        XCTAssertTrue(str.yearDisplay == "2019")
    }

    func testCastTitleDisplayWithOriginalTitle() throws {
        // Given
        let c = Credit(id: 0, name: "name", title: "1", original_title: "2", release_date: "2019-09-17")

        // Then
        XCTAssertTrue(c.titleDisplay == "1 (2)")
    }

    func testCastTitleDisplayWithName() throws {
        // Given
        let c = Credit(id:0, name: "1")

        // Then
        XCTAssertTrue(c.titleDisplay == "1")
    }

    func testCastTitleDisplayWithNameAndOriginalTitle() throws {
           // Given
           let c = Credit(id: 0, name: "name", original_title: "2", release_date: "2019-09-17")

           // Then
           XCTAssertTrue(c.titleDisplay == "name (2)")
       }

    func testCrew() throws {
        // Given
        let c = Credit(id:0, title: "1", original_title: "2", release_date: "2019-09-17")

        // Then
        XCTAssertTrue(c.titleDisplay == "1 (2)")
    }

//    func testCastSubtitle() throws {
//        // Given
//        let c = Credit(id: 1668, character: "Rachel Green",  name: "Friends",  episode_count: 236)
//
//
//        // Then
//        XCTAssertTrue(c.subtitle == "Rachel Green")
//    }

    func testMediaTitle() throws {
        // Given
        let m = Media(id: 0, title: "1", original_title: "2", vote_average: 0, vote_count: 0, overview: "")

        // Then
        XCTAssertTrue(m.titleDisplay == "1 (2)")
    }

    func testMediaTvTitle() throws {
        // Given
        let m = Media(id: 0, vote_average: 0, vote_count: 0, overview: "", original_name: "One Tree Hill")

        // Then
        XCTAssertTrue(m.titleDisplay == "One Tree Hill")
    }

}
