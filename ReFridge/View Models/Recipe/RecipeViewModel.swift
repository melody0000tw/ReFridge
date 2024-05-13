//
//  RecipeViewModel.swift
//  ReFridge
//
//  Created by Melody Lee on 2024/5/12.
//

import Foundation
import Combine
import FirebaseFirestore

class RecipeViewModel {
    private let firestoreManager = FirestoreManager.shared
    
    var allRecipes: [Recipe]
    var ingredientsDict: [String: IngredientStatus]
    var likedRecipeId: [String]
    var finishedRecipeId: [String]
    
    var recipeFilter: RecipeFilter {
        didSet {
            filterRecipes()
        }
    }
    
    @Published var showRecipes: [Recipe]
    @Published var error: Error?
    @Published var isLoading: Bool = false
    
    private var cancellables = Set<AnyCancellable>()
    
    init(
        allRecipes: [Recipe] = [],
        showRecipes: [Recipe] = [],
        recipeFilter: RecipeFilter = .all,
        ingredientsDict: [String: IngredientStatus] = [:],
        likedRecipeId: [String] = [],
        finishedRecipeId: [String] = []){
        self.allRecipes = allRecipes
        self.showRecipes = showRecipes
        self.recipeFilter = recipeFilter
        self.ingredientsDict = ingredientsDict
        self.likedRecipeId = likedRecipeId
        self.finishedRecipeId = finishedRecipeId
    }
    
    // MARK: - Fetch Datas
    func fetchDatas() {
        fetchRecipes()
        fetchLikedRecipeId()
        fetchFinishedRecipeId()
    }
    
    func fetchRecipes() {
        isLoading = true
        let colRef = firestoreManager.recipeRef
        Task {
            firestoreManager.fetchDatas(from: colRef) { [self] (result: Result<[Recipe], Error>) in
                switch result {
                case .success(let recipes):
                    allRecipes = recipes
                    checkAllStatus { [self] in
                        filterRecipes()
//                        showRecipes = allRecipes
                    }
                case .failure(let error):
                    print("error: \(error)")
                    self.error = error
                }
                isLoading = false
            }
        }
    }
    
    private func fetchLikedRecipeId() {
        let colRef = firestoreManager.likedRecipesRef
        Task {
            firestoreManager.fetchDatas(from: colRef) { [self] (result: Result<[LikedRecipe], Error>) in
                switch result {
                case .success(let recipes):
                    var likedRecipes = [String]()
                    recipes.forEach { recipe in
                        likedRecipes.append(recipe.recipeId)
                    }
                    self.likedRecipeId = likedRecipes
                case .failure(let error):
                    print("error: \(error)")
                    self.error = error
                }
            }
        }
    }
    
    private func fetchFinishedRecipeId() {
        let colRef = firestoreManager.finishedRecipesRef
        Task {
            firestoreManager.fetchDatas(from: colRef) { [self] (result: Result<[FinishedRecipe], Error>) in
                switch result {
                case .success(let recipes):
                    var finishedRecipes = [String]()
                    recipes.forEach { recipe in
                        finishedRecipes.append(recipe.recipeId)
                    }
                    self.finishedRecipeId = finishedRecipes
                case .failure(let error):
                    print("error: \(error)")
                    self.error = error
                }
            }
        }
    }
    
    // MARK: - Check status
    private func checkAllStatus(completion: @escaping (() -> Void)) {
        var dict: [String: IngredientStatus] = [:]
        let dispatchGroup = DispatchGroup()
        for recipe in allRecipes {
            dispatchGroup.enter()
            checkIngredientStatus(recipe: recipe) { ingredientStatus in
                dict[ingredientStatus.recipeId] = ingredientStatus
                dispatchGroup.leave()
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            self.ingredientsDict = dict
            completion()
        }
    }
    
    private func checkIngredientStatus(recipe: Recipe, completion: @escaping (IngredientStatus) -> Void ) {
        var allTypes = [FoodType]()
        var lackTypes = [FoodType]()
        var checkTypes = [FoodType]()
        
        let arrayAccessQueue = DispatchQueue(label: "arrayAccessQueue")
        
        let dispatchGroup = DispatchGroup()
        for ingredient in recipe.ingredients {
            dispatchGroup.enter()
            let typeId = ingredient.typeId
            let query = firestoreManager.foodCardsRef.whereField("typeId", isEqualTo: typeId)
            Task {
                firestoreManager.queryDatas(query: query) {(result: Result<[FoodCard], Error>) in
                    arrayAccessQueue.sync {
                        switch result {
                        case .success(let foodCards):
                            let foodType = FoodTypeData.share.queryFoodType(typeId: typeId)
                            if let foodType = foodType {
                                if foodCards.isEmpty {
                                    lackTypes.append(foodType)
                                } else {
                                    checkTypes.append(foodType)
                                }
                                allTypes.append(foodType)
                            } else {
                                print("Food type not found for typeId: \(typeId)")
                            }
                        case .failure(let error):
                            print("error: \(error)")
                        }
                        dispatchGroup.leave()
                    }
                }
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            let ingredientStatus = IngredientStatus(
                recipeId: recipe.recipeId,
                allTypes: allTypes,
                checkTypes: checkTypes,
                lackTypes: lackTypes,
                fitPercentage: (Double(checkTypes.count) / Double(allTypes.count)).rounding(toDecimal: 2)
            )
            completion(ingredientStatus)
        }
    }
    
    // MARK: - Filter Recipes
    func filterRecipes() {
        switch recipeFilter {
        case .all:
            showRecipes = allRecipes
        case .favorite:
            getLikedRecipes()
        case .fit:
            getFitRecipes(over: 0.5)
        case .finished:
            getFinishedRecipes()
        }
    }
    
    private func getFitRecipes(over fitPercentage: Double) {
        guard allRecipes.count != 0, ingredientsDict.count != 0 else {
            print("all recipe or ingredientDict is empty")
            return
        }
        
        let filteredRecipes = allRecipes.filter { recipe in
            guard let ingredientStatus = ingredientsDict[recipe.recipeId] else {
                print("cannot find percentage info")
                return false
            }
            return ingredientStatus.fitPercentage >= fitPercentage
        }
        showRecipes = filteredRecipes
    }
    
    private func getLikedRecipes() {
        guard allRecipes.count != 0 else {
            print("all recipe is empty")
            return
        }
        
        let filteredRecipes = allRecipes.filter { recipe in
            likedRecipeId.contains([recipe.recipeId])
        }
        
        showRecipes = filteredRecipes
    }
    
    private func getFinishedRecipes() {
        guard allRecipes.count != 0 else {
            print("all recipe is empty")
            return
        }
        
        let filteredRecipes = allRecipes.filter { recipe in
            finishedRecipeId.contains([recipe.recipeId])
        }
        
        showRecipes = filteredRecipes
    }
    
    // MARK: - update liked status
    func updateLikedStatus(isLiked: Bool, recipe: Recipe) {
        Task {
            let docRef = firestoreManager.likedRecipesRef.document(recipe.recipeId)
            switch isLiked {
            case true:
                let likedRecipe = LikedRecipe(recipeId: recipe.recipeId)
                firestoreManager.updateDatas(to: docRef, with: likedRecipe) { result in
                    switch result {
                    case .success:
                        self.fetchLikedRecipeId()
                    case .failure(let error):
                        print(error.localizedDescription)
                    }
                }
            case false:
                firestoreManager.deleteDatas(from: docRef) { result in
                    switch result {
                    case .success:
                        self.fetchLikedRecipeId()
                    case .failure(let error):
                        print(error.localizedDescription)
                    }
                }
            }
        }
    }
    
    func searchRecipe(with searchText: String) {
        let filteredRecipes = allRecipes.filter { recipe in
            recipe.title.localizedCaseInsensitiveContains(searchText)
        }
        showRecipes = filteredRecipes
    }
}
