//
//  FoodType.swift
//  ReFridge
//
//  Created by Melody Lee on 2024/4/11.
//

import Foundation
import UIKit

struct FoodType: Codable {
    var categoryId: Int
    var typeId: Int
    var typeName: String
    var typeIcon: String
}

struct DefaultTypeData {
    static let share = DefaultTypeData()
    
    let data: [FoodType] = [
        FoodType(categoryId: 1, typeId: 101, typeName: "萵苣", typeIcon: "lettuce"),
        FoodType(categoryId: 1, typeId: 102, typeName: "花椰菜", typeIcon: "broccoli"),
        FoodType(categoryId: 1, typeId: 103, typeName: "洋蔥", typeIcon: "onion"),
        FoodType(categoryId: 1, typeId: 104, typeName: "南瓜", typeIcon: "pumpkin"),
        FoodType(categoryId: 1, typeId: 105, typeName: "紅羅蔔", typeIcon: "carrot"),
        FoodType(categoryId: 2, typeId: 201, typeName: "櫻桃", typeIcon: "cherry"),
        FoodType(categoryId: 2, typeId: 202, typeName: "蘋果", typeIcon: "apple"),
        FoodType(categoryId: 2, typeId: 203, typeName: "檸檬", typeIcon: "lemon"),
        FoodType(categoryId: 2, typeId: 204, typeName: "酪梨", typeIcon: "avocado"),
        FoodType(categoryId: 2, typeId: 205, typeName: "草莓", typeIcon: "strawberry")
    ]
}

struct FoodCategory: Codable {
    var categoryId: Int
    var categoryName: String
    var categoryIcon: String
    var categoryColor: String
}

struct CategoryData {
    static let share = CategoryData()
    let data: [FoodCategory] = [
        FoodCategory(categoryId: 1, categoryName: "蔬菜", categoryIcon: "lettuce", categoryColor: "FF34FF"),
        FoodCategory(categoryId: 2, categoryName: "水果", categoryIcon: "apple", categoryColor: "FF34BB")
    ]
}
