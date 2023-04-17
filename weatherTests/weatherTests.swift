//
//  Final Project - By Pruthvi And Sakshi
//  WeatherApp
//
//  Advance IOS
//

import XCTest
@testable import weather

struct ListMock: DateContaining, Equatable {
    let dt: Int
}


class weatherTests: XCTestCase {

    func testForecastFilter() {

//        let list: [ListMock] = [
//            ListMock(dt: 1643835600),
//            ListMock(dt: 1643857200),
//            ListMock(dt: 1643922000)
//        ]
//
//        //not optimal because function lives everywhere but okay for now
//        let filteredList = filterNoon(unfilteredList: list)
//
//        let expectedList: [ListMock] = [
//            ListMock(dt: 1643835600),
//            ListMock(dt: 1643922000)
//        ]
//
//        XCTAssertEqual(filteredList, expectedList)
//    }
//
//    func testDay() {
//        let sunrise = Date.now.addingTimeInterval(-28800)     //sunrise 8h ago
//        let sunset = Date.now.addingTimeInterval(10800)       //sunset in 3h
//        let isNight = Date().isBetween(with: sunrise, with: sunset)
//
//        XCTAssertEqual(isNight, false)
//    }
//
//    func testNight() {
//        let sunrise = Date.now.addingTimeInterval(7200)    //sunrise in 2h
//        let sunset = Date.now.addingTimeInterval(-18000)     //sunset 5h ago
//        let isNight = Date().isBetween(with: sunrise, with: sunset)
//
//        XCTAssertEqual(isNight, true)
    }
}
