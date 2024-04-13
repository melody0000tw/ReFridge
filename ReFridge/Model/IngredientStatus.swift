//
//  IngredientStatus.swift
//  ReFridge
//
//  Created by Melody Lee on 2024/4/13.
//

import Foundation

struct IngredientStatus {
    var recipeId: String
    var allIngredients: [Ingredient] // 不存 food type 因為食譜中的type只會有本地端的type 本地端就可以找到
    var checkIngredients: [Ingredient]
    var lackIngredients: [Ingredient]
}

// 使用者自定義type就直接
