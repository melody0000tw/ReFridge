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
    var typeId: String
    var typeName: String
    var typeIcon: String
    var isDeletable: Bool
    var createTime: Date?
}

struct FoodCategory: Codable {
    var categoryId: Int
    var categoryName: String
    var categoryIcon: String
    var categoryColor: String
}

// MARK: - Food Type Data
struct FoodTypeData {
    static let share = FoodTypeData()
    
    let data: [FoodType] = [
        FoodType(categoryId: 1, typeId: "101", typeName: "萵苣", typeIcon: "lettuce", isDeletable: false),
        FoodType(categoryId: 1, typeId: "102", typeName: "花椰菜", typeIcon: "broccoli", isDeletable: false),
        FoodType(categoryId: 1, typeId: "103", typeName: "洋蔥", typeIcon: "onion", isDeletable: false),
        FoodType(categoryId: 1, typeId: "104", typeName: "南瓜", typeIcon: "pumpkin", isDeletable: false),
        FoodType(categoryId: 1, typeId: "105", typeName: "紅羅蔔", typeIcon: "carrot", isDeletable: false),
        FoodType(categoryId: 2, typeId: "201", typeName: "櫻桃", typeIcon: "cherry", isDeletable: false),
        FoodType(categoryId: 2, typeId: "202", typeName: "蘋果", typeIcon: "apple", isDeletable: false),
        FoodType(categoryId: 2, typeId: "203", typeName: "檸檬", typeIcon: "lemon", isDeletable: false),
        FoodType(categoryId: 2, typeId: "204", typeName: "酪梨", typeIcon: "avocado", isDeletable: false),
        FoodType(categoryId: 2, typeId: "205", typeName: "草莓", typeIcon: "strawberry", isDeletable: false),
        FoodType(categoryId: 3, typeId: "301", typeName: "肉類", typeIcon: "meat", isDeletable: false),
        FoodType(categoryId: 3, typeId: "302", typeName: "海鮮", typeIcon: "fish", isDeletable: false),
        FoodType(categoryId: 3, typeId: "303", typeName: "豆類", typeIcon: "beans", isDeletable: false),
        FoodType(categoryId: 3, typeId: "304", typeName: "奶製品", typeIcon: "cheese", isDeletable: false),
        FoodType(categoryId: 3, typeId: "305", typeName: "蛋", typeIcon: "egg", isDeletable: false),
        FoodType(categoryId: 4, typeId: "401", typeName: "麥片", typeIcon: "wheat", isDeletable: false),
        FoodType(categoryId: 4, typeId: "402", typeName: "麵條", typeIcon: "noodles", isDeletable: false),
        FoodType(categoryId: 4, typeId: "403", typeName: "米飯", typeIcon: "rice", isDeletable: false),
        FoodType(categoryId: 4, typeId: "404", typeName: "麵包", typeIcon: "bread", isDeletable: false),
        FoodType(categoryId: 5, typeId: "501", typeName: "其他", typeIcon: "other", isDeletable: false),
        FoodType(categoryId: 5, typeId: "502", typeName: "飲料", typeIcon: "drink", isDeletable: false),
        FoodType(categoryId: 5, typeId: "503", typeName: "零食", typeIcon: "cookie", isDeletable: false),
        FoodType(categoryId: 5, typeId: "504", typeName: "甜點", typeIcon: "cupcake", isDeletable: false)
    ]
    
    func queryFoodType(typeId: String) -> FoodType? {
        let foodType = data.first { type in
            type.typeId == typeId
        }
        guard let foodType = foodType else { return nil }
        return foodType
    }
}

// MARK: - Category Data
struct CategoryData {
    static let share = CategoryData()
    
    let data: [FoodCategory] = [
        FoodCategory(categoryId: 1, categoryName: "蔬菜", categoryIcon: "lettuce", categoryColor: "FF34FF"),
        FoodCategory(categoryId: 2, categoryName: "水果", categoryIcon: "apple", categoryColor: "FF34BB"),
        FoodCategory(categoryId: 3, categoryName: "蛋白質", categoryIcon: "lettuce", categoryColor: "FF34FF"),
        FoodCategory(categoryId: 4, categoryName: "穀物", categoryIcon: "apple", categoryColor: "FF34BB"),
        FoodCategory(categoryId: 5, categoryName: "其他", categoryIcon: "other", categoryColor: "FF34BB")
    ]
    
    func queryFoodCategory(categoryId: Int) -> FoodCategory? {
        let category = data.first { type in
            type.categoryId == categoryId
        }
        guard let category = category else { return nil }
        return category
    }
}
