//
//  ChartCounts.swift
//  ReFridge
//
//  Created by Melody Lee on 2024/4/18.
//

import Foundation

struct CategoryCardCount {
    var categoryId: Int
    var cardCounts: Int
}

struct RemainingDayCount {
    var remainingDay: RemainingPeriod
    var cardCounts: Int
}

enum RemainingPeriod {
    case expired
    case lessThanSevenDays
    case lessThanOneMonths
    case lessThanThreeMonths
    case moreThanThreeMonths
}
