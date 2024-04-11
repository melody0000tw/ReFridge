//
//  FoodType.swift
//  ReFridge
//
//  Created by Melody Lee on 2024/4/11.
//

import Foundation
import UIKit

struct FoodCategory {
    var id: Int
    var name: String
    var iconName: String
    var colorCode: String
    var foodTypes: [FoodType]
}

struct FoodType {
    var id: Int
    var name: String
    var iconName: String
}

struct FoodTypeData {
    static let share = FoodTypeData()
    
    let data: [FoodCategory] = [
        FoodCategory(
            id: 0,
            name: "蔬菜",
            iconName: "lettuce",
            colorCode: "FF23FF",
            foodTypes: [
                FoodType(id: 0, name: "萵苣", iconName: "lettuce"),
                FoodType(id: 1, name: "花椰菜", iconName: "broccoli"),
                FoodType(id: 2, name: "洋蔥", iconName: "onion"),
                FoodType(id: 3, name: "南瓜", iconName: "pumpkin"),
                FoodType(id: 4, name: "紅羅蔔", iconName: "carrot")
            ]),
        FoodCategory(
            id: 1,
            name: "水果",
            iconName: "apple",
            colorCode: "FF34FF",
            foodTypes: [
                FoodType(id: 0, name: "櫻桃", iconName: "cherry"),
                FoodType(id: 1, name: "蘋果", iconName: "apple"),
                FoodType(id: 2, name: "檸檬", iconName: "lemon"),
                FoodType(id: 3, name: "酪梨", iconName: "avocado"),
                FoodType(id: 4, name: "草莓", iconName: "strawberry"),
//                FoodType(id: 0, name: "櫻桃", icon: UIImage.asset(.cherry)),
//                FoodType(id: 1, name: "蘋果", icon: UIImage.asset(.apple)),
//                FoodType(id: 2, name: "檸檬", icon: UIImage.asset(.lemon)),
//                FoodType(id: 3, name: "酪梨", icon: UIImage.asset(.avocado)),
//                FoodType(id: 4, name: "草莓", icon: UIImage.asset(.strawberry)),
            ])
    ]
}
