//
//  FoodCard.swift
//  ReFridge
//
//  Created by Melody Lee on 2024/4/11.
//

import Foundation

struct FoodCard: Codable {
    var cardId: String
    var name: String
    var categoryId: Int
    var typeId: Int
    var iconName: String
    var qty: Int
    var createDate: Date
    var expireDate: Date
    var notificationTime: Int
    var barCode: Int
    var storageType: Int
    var notes: String
    
    static var share = FoodCard(cardId: "", name: "", categoryId: 0, typeId: 0, iconName: "", qty: 1, createDate: Date(), expireDate: Date(), notificationTime: 0, barCode: 0, storageType: 0, notes: "")
}
