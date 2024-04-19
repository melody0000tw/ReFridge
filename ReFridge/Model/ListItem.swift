//
//  ListItem.swift
//  ReFridge
//
//  Created by Melody Lee on 2024/4/13.
//

import Foundation

struct ListItem: Codable {
    var itemId: String
    var typeId: String
    var qty: Int
    var checkStatus: Int
    var isRoutineItem: Bool
    var routinePeriod: Int
    var routineStartTime: Date
    
    static let share = ListItem(itemId: "", typeId: "501", qty: 1, checkStatus: 0, isRoutineItem: false, routinePeriod: 0, routineStartTime: Date())
}
