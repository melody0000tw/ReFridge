//
//  RecipeDetailViewModel.swift
//  ReFridge
//
//  Created by Melody Lee on 2024/5/16.
//

import UIKit

class RecipeDetailViewModel {
    private let firestoreManager = FirestoreManager.shared
    
    var recipe: Recipe?
    var ingredientStatus: IngredientStatus?
    var isLiked: Bool
    
    init(recipe: Recipe? = nil, ingredientStatus: IngredientStatus? = nil, isLiked: Bool = false) {
        self.recipe = recipe
        self.ingredientStatus = ingredientStatus
        self.isLiked = isLiked
    }
    
    // MARK: - Shopping List
    func addToList(ingredient: Ingredient, completion: @escaping (Result<FoodType, Error>) -> Void ) {
        guard let type = queryIngredientFoodType(ingredient: ingredient) else {
            print("cannot get ingrednet type")
            return
        }
        let item = createListItem(ingredient: ingredient, type: type)
        postList(item: item) { result in
            switch result {
            case .success:
                print("Written data successfully!)")
                completion(.success(type))
            case .failure(let error):
                print("error: \(error)")
                completion(.failure(error))
            }
        }
        
    }
    
    func addAllLackIngredientsToList(completion: @escaping (Result<Void, Error>) -> Void ) {
        guard let ingredientStatus = ingredientStatus else {
            print("cannot get ingredient status")
            return
        }
        
        for type in ingredientStatus.lackTypes {
            guard let recipe = recipe else {
                print("cannot get recipe")
                return
            }
            let ingredient = recipe.ingredients.first { ingredient in
                ingredient.typeId == type.typeId
            }
            
            guard let ingredient = ingredient else {
                print("cannot get recipe ingredient")
                return
            }
            
            let item = createListItem(ingredient: ingredient, type: type)
            postList(item: item) { result in
                switch result {
                case .success:
                    print("Written data successfully!)")
                    completion(.success(()))
                case .failure(let error):
                    print("error: \(error)")
                    completion(.failure(error))
                }
            }
        }
    }
    
    private func queryIngredientFoodType(ingredient: Ingredient) -> FoodType? {
        let foodType = ingredientStatus?.allTypes.first(where: { type in
            type.typeId == ingredient.typeId
        })
        
        return foodType
    }
    
    private func createListItem(ingredient: Ingredient, type: FoodType) -> ListItem {
        var item = ListItem()
        
        item.typeId = type.typeId
        item.categoryId = type.categoryId
        item.name = type.typeName
        item.iconName = type.typeIcon
        item.checkStatus = 0
        item.mesureWord = ingredient.mesureWord
        item.qty = ingredient.qty
        item.isRoutineItem = false
        
        return item
    }
    
    private func postList(item: ListItem, completion: @escaping (Result<Void, Error>) -> Void ) {
        Task {
            let docRef = firestoreManager.shoppingListRef.document(item.itemId)
            firestoreManager.updateDatas(to: docRef, with: item) { result in
                switch result {
                case .success:
                    print("Written data successfully!)")
                    completion(.success(()))
                case .failure(let error):
                    print("error: \(error)")
                    completion(.failure(error))
                }
            }
        }
    }
    
    // MARK: - Finish List
    func addToFinishList(completion: @escaping (Result<Void, Error>) -> Void ) {
        Task {
            guard let recipe = recipe else { return }
            let docRef = firestoreManager.finishedRecipesRef.document(recipe.recipeId)
            let finishedRecipe = FinishedRecipe(recipeId: recipe.recipeId)
            firestoreManager.updateDatas(to: docRef, with: finishedRecipe) { result in
                switch result {
                case .success:
                    print("成功加入完成食譜清單")
                    completion(.success(()))
                case .failure(let error):
                    print(error.localizedDescription)
                    completion(.failure(error))
                }
            }
        }
    }
    
    // MARK: - Liked List
    func updateLikedStatus(isLiked: Bool) {
        Task {
            guard let recipe = recipe else { return }
            let docRef = firestoreManager.likedRecipesRef.document(recipe.recipeId)
            switch isLiked {
            case true:
                let likedRecipe = LikedRecipe(recipeId: recipe.recipeId)
                firestoreManager.updateDatas(to: docRef, with: likedRecipe) { result in
                    switch result {
                    case .success:
                        print("成功加入收藏清單")
                    case .failure(let error):
                        print(error.localizedDescription)
                    }
                }
            case false:
                firestoreManager.deleteDatas(from: docRef) { result in
                    switch result {
                    case .success:
                        print("成功刪除清單")
                    case .failure(let error):
                        print(error.localizedDescription)
                    }
                }
            }
        }
        
    }
}
