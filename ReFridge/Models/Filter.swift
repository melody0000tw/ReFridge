//
//  CardFilter.swift
//  ReFridge
//
//  Created by Melody Lee on 2024/4/17.
//

import Foundation

struct CardFilter {
    var categoryId: Int?
    var sortBy: CardSortMethod
}

enum CardSortMethod {
    case remainingDay
    case createDay
    case category
}

enum RecipeFilter {
    case all
    case favorite
    case fit
    case finished
}
