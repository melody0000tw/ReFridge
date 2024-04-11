//
//  FoodCard.swift
//  ReFridge
//
//  Created by Melody Lee on 2024/4/11.
//

import Foundation

struct FoodCard: Codable {
    let name: String
    let categoryId: Int
    let typeId: Int
    let iconName: String
    let qty: Int
    let createDate: Double
    let expireDate: Double
    let notificationTime: Int
    let barCode: Int
    let storageType: Int
    let notes: String
}
