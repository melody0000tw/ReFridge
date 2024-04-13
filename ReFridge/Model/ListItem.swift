//
//  ListItem.swift
//  ReFridge
//
//  Created by Melody Lee on 2024/4/13.
//

import Foundation

struct ListItem: Codable {
    var itemId: String
    var typeId: Int
    var checkStatus: Int
    var isRoutineItem: Bool
    var routinePeriod: Int?
    var routineStartTime: Date?
}
