//
//  FoodCard.swift
//  ReFridge
//
//  Created by Melody Lee on 2024/4/11.
//

import Foundation

struct FoodCard: Codable {
    var cardId: String = ""
    var name: String = ""
    var categoryId: Int = 5
    var typeId: String = "501"
    var iconName: String = "other"
    var qty: Int = 1
    var mesureWord: String = "個"
    var createDate: Date = Date()
    var expireDate: Date = Date().createExpiredDate(afterDays: 7) ?? Date()
    var isRoutineItem: Bool = false
    var barCode: String = ""
    var storageType: Int = 0
    var notes: String = ""
    
//    static let  = FoodCard(cardId: "", name: "", categoryId: 0, typeId: 0, iconName: "", qty: 1, createDate: Date(), expireDate: Date(), notificationTime: 0, barCode: 0, storageType: 0, notes: "")
}
