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
    let consumed: Int
    let thrown: Int
}

enum DeleteWay: String {
    case consumed
    case thrown
}
