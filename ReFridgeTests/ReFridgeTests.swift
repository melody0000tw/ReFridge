//
//  ReFridgeTests.swift
//  ReFridgeTests
//
//  Created by Melody Lee on 2024/5/18.
//

import XCTest
@testable import ReFridge

final class ReFridgeTests: XCTestCase {
    var sut: MyFridgeViewModel!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        sut = MyFridgeViewModel()
    }

    override func tearDownWithError() throws {
        sut = nil
        try super.tearDownWithError()
    }

    func testCalculateRemainingDaysForFutureDate() {
        let futureDate = Calendar.current.date(byAdding: .day, value: 20, to: Date())!
        let remainingDays = futureDate.calculateRemainingDays()
        XCTAssertEqual(remainingDays, 20, "Calculate Remaining days for future date is wrong")
    }

    func testCalculateRemainingDaysForPastDate() {
        let pastDate = Calendar.current.date(byAdding: .day, value: -5, to: Date())!
        let remainingDays = pastDate.calculateRemainingDays()
        XCTAssertEqual(remainingDays, -5, "Calculate Remaining days for past date is wrong")
    }
    
    func testSearchFoodCardName() {
        let card1 = FoodCard(name: "香菇")
        let card2 = FoodCard(name: "香蕉")
        let card3 = FoodCard(name: "蘋果")
        let card4 = FoodCard(name: "魚")
        let card5 = FoodCard(name: "香腸")
        
        let allCards = [card1, card2, card3, card4, card5]
        sut.allCards = allCards
        
        sut.searchFoodCards(with: "香")
        XCTAssertEqual(sut.showCards.count, 3, "Search FoodCard Name function is wrong")
    }
}
