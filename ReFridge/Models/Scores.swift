//
//  Scores.swift
//  ReFridge
//
//  Created by Melody Lee on 2024/4/19.
//

import Foundation

struct Score: Codable {
    var number: Int
}

struct Scores: Codable {
    var consumed: Int
    var thrown: Int
}

enum DeleteWay: String, CaseIterable {
    case consumed
    case thrown
}
