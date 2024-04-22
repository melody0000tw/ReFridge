//
//  Recipe.swift
//  ReFridge
//
//  Created by Melody Lee on 2024/4/13.
//

import Foundation

struct Recipe: Codable {
    let recipeId: String
    let title: String
    let cookingTime: Int
    let calories: Int
    let servings: Int
    let description: String
    let ingredients: [Ingredient]
    let steps: [String]
    let image: String
}

struct Ingredient: Codable {
    let typeId: String
    let qty: Int
    let mesureWord: String
//    let mesureWord: String
}
