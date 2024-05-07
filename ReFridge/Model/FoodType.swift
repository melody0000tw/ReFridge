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
        FoodType(categoryId: 1, typeId: "101", typeName: "高麗菜", typeIcon: "cabbage", isDeletable: false),
        FoodType(categoryId: 1, typeId: "102", typeName: "花椰菜", typeIcon: "broccoli", isDeletable: false),
        FoodType(categoryId: 1, typeId: "103", typeName: "洋蔥", typeIcon: "onion", isDeletable: false),
        FoodType(categoryId: 1, typeId: "104", typeName: "南瓜", typeIcon: "pumpkin", isDeletable: false),
        FoodType(categoryId: 1, typeId: "105", typeName: "青椒", typeIcon: "green-pepper", isDeletable: false),
        FoodType(categoryId: 1, typeId: "106", typeName: "菠菜", typeIcon: "spinach", isDeletable: false),
        FoodType(categoryId: 1, typeId: "107", typeName: "番茄", typeIcon: "tomato", isDeletable: false),
        FoodType(categoryId: 1, typeId: "108", typeName: "紅蘿蔔", typeIcon: "carrot", isDeletable: false),
        FoodType(categoryId: 1, typeId: "109", typeName: "蘆筍", typeIcon: "asparagus", isDeletable: false),
        FoodType(categoryId: 1, typeId: "110", typeName: "茄子", typeIcon: "eggplant", isDeletable: false),
        FoodType(categoryId: 1, typeId: "111", typeName: "辣椒", typeIcon: "chili-pepper", isDeletable: false),
        FoodType(categoryId: 1, typeId: "112", typeName: "甜菜根", typeIcon: "beetroot", isDeletable: false),
        FoodType(categoryId: 1, typeId: "113", typeName: "豌豆", typeIcon: "pea", isDeletable: false),
        FoodType(categoryId: 1, typeId: "114", typeName: "菇類", typeIcon: "mashroom", isDeletable: false),
        FoodType(categoryId: 2, typeId: "201", typeName: "櫻桃", typeIcon: "cherry", isDeletable: false),
        FoodType(categoryId: 2, typeId: "202", typeName: "蘋果", typeIcon: "apple", isDeletable: false),
        FoodType(categoryId: 2, typeId: "203", typeName: "檸檬", typeIcon: "lemon", isDeletable: false),
        FoodType(categoryId: 2, typeId: "204", typeName: "酪梨", typeIcon: "avocado", isDeletable: false),
        FoodType(categoryId: 2, typeId: "205", typeName: "草莓", typeIcon: "strawberry", isDeletable: false),
        FoodType(categoryId: 2, typeId: "206", typeName: "香蕉", typeIcon: "banana", isDeletable: false),
        FoodType(categoryId: 2, typeId: "207", typeName: "梨子", typeIcon: "pear", isDeletable: false),
        FoodType(categoryId: 3, typeId: "301", typeName: "肉類", typeIcon: "meat", isDeletable: false),
        FoodType(categoryId: 3, typeId: "302", typeName: "魚", typeIcon: "fish", isDeletable: false),
        FoodType(categoryId: 3, typeId: "303", typeName: "起士", typeIcon: "cheese", isDeletable: false),
        FoodType(categoryId: 3, typeId: "304", typeName: "蛋", typeIcon: "egg", isDeletable: false),
        FoodType(categoryId: 3, typeId: "305", typeName: "雞肉", typeIcon: "chicken", isDeletable: false),
        FoodType(categoryId: 3, typeId: "306", typeName: "香腸", typeIcon: "sausage", isDeletable: false),
        FoodType(categoryId: 3, typeId: "307", typeName: "蝦", typeIcon: "shrimp", isDeletable: false),
//        FoodType(categoryId: 3, typeId: "308", typeName: "豆類", typeIcon: "bean", isDeletable: false),
        FoodType(categoryId: 4, typeId: "401", typeName: "麥片", typeIcon: "wheat", isDeletable: false),
        FoodType(categoryId: 4, typeId: "402", typeName: "麵條", typeIcon: "noodles", isDeletable: false),
        FoodType(categoryId: 4, typeId: "403", typeName: "米飯", typeIcon: "rice", isDeletable: false),
        FoodType(categoryId: 4, typeId: "404", typeName: "麵包", typeIcon: "bread", isDeletable: false),
        FoodType(categoryId: 4, typeId: "405", typeName: "吐司", typeIcon: "toast", isDeletable: false),
        FoodType(categoryId: 5, typeId: "501", typeName: "其他", typeIcon: "other", isDeletable: false),
        FoodType(categoryId: 5, typeId: "502", typeName: "飲料", typeIcon: "drink", isDeletable: false),
        FoodType(categoryId: 5, typeId: "503", typeName: "零食", typeIcon: "cookie", isDeletable: false),
        FoodType(categoryId: 5, typeId: "504", typeName: "甜點", typeIcon: "cupcake", isDeletable: false),
        FoodType(categoryId: 5, typeId: "505", typeName: "冰品", typeIcon: "icecream", isDeletable: false)
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
        FoodCategory(categoryId: 1, categoryName: "蔬菜", categoryIcon: "spinach", categoryColor: "D6DAC8"),
        FoodCategory(categoryId: 2, categoryName: "水果", categoryIcon: "apple", categoryColor: "FBF3D5"),
        FoodCategory(categoryId: 3, categoryName: "蛋白質", categoryIcon: "fish", categoryColor: "EFBC9B"),
        FoodCategory(categoryId: 4, categoryName: "穀物", categoryIcon: "bread", categoryColor: "E0D8B0"),
        FoodCategory(categoryId: 5, categoryName: "其他", categoryIcon: "hamberger", categoryColor: "DBD0C0")
    ]
    
    func queryFoodCategory(categoryId: Int) -> FoodCategory? {
        let category = data.first { type in
            type.categoryId == categoryId
        }
        guard let category = category else { return nil }
        return category
    }
}
