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
    var colorCode: String
    var foodTypes: [FoodType]
}

struct FoodType {
    var id: Int
    var name: String
    var icon: UIImage?
}

struct FoodTypeData {
    static let share = FoodTypeData()
    
    let data: [FoodCategory] = [
        FoodCategory(
            id: 0,
            name: "蔬菜",
            colorCode: "FF23FF",
            foodTypes: [
                FoodType(id: 0, name: "萵苣", icon: UIImage.asset(.lettuce)),
                FoodType(id: 1, name: "花椰菜", icon: UIImage.asset(.broccoli)),
                FoodType(id: 2, name: "洋蔥", icon: UIImage.asset(.onion)),
                FoodType(id: 3, name: "南瓜", icon: UIImage.asset(.pumpkin)),
                FoodType(id: 4, name: "紅羅蔔", icon: UIImage.asset(.carrot))
            ]),
        FoodCategory(
            id: 1,
            name: "水果",
            colorCode: "FF34FF",
            foodTypes: [
                FoodType(id: 0, name: "櫻桃", icon: UIImage.asset(.cherry)),
                FoodType(id: 1, name: "蘋果", icon: UIImage.asset(.apple)),
                FoodType(id: 2, name: "檸檬", icon: UIImage.asset(.lemon)),
                FoodType(id: 3, name: "酪梨", icon: UIImage.asset(.avocado)),
                FoodType(id: 4, name: "草莓", icon: UIImage.asset(.strawberry)),
            ])
    ]
}
