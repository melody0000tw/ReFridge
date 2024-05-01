//
//  ListItem.swift
//  ReFridge
//
//  Created by Melody Lee on 2024/4/13.
//

import Foundation

struct ListItem: Codable {
    var itemId: String = UUID().uuidString
    var typeId: String = "501"
    var categoryId: Int = 0
    var qty: Int = 1
    var mesureWord: String = "個"
    var checkStatus: Int = 0
    var isRoutineItem: Bool = false
    var name: String = ""
    var iconName: String = "other"
    var notes: String = ""
//    var routinePeriod: Int
//    var routineStartTime: Date
    
//    static let share = ListItem(itemId: "", typeId: "501", qty: 1, checkStatus: 0, isRoutineItem: false, routinePeriod: 0, routineStartTime: Date())
}
