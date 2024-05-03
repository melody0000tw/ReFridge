//
//  FirestoreManager.swift
//  ReFridge
//
//  Created by Melody Lee on 2024/4/11.
//

import Foundation
import FirebaseFirestore

class FirestoreManager {
    
    static let shared = FirestoreManager()
    private let accountManager = AccountManager.share
    
    let database: Firestore
    
    var uid: String? {
        didSet {
            if let uid = uid {
                updateDatabaseReferences(uid: uid)
            }
        }
    }
    
    lazy var userInfoRef = database.collection("users").document("userId").collection("userInfo").document("data")
    lazy var foodCardsRef = database.collection("users").document("userId").collection("foodCards")
    lazy var foodTypesRef = database.collection("users").document("userId").collection("foodTypes")
    lazy var shoppingListRef = database.collection("users").document("userId").collection("shoppingList")
    lazy var likedRecipesRef = database.collection("users").document("userId").collection("likedRecipes")
    lazy var finishedRecipesRef = database.collection("users").document(uid!).collection("finishedRecipes")
    lazy var scoresRef = database.collection("users").document(uid!).collection("scores")

    private init() {
        database = Firestore.firestore()
    }
    
    // MARK: - UserInfo
    func updateDatabaseReferences(uid: String) {
            userInfoRef = database.collection("users").document(uid).collection("userInfo").document("data")
            foodCardsRef = database.collection("users").document(uid).collection("foodCards")
            foodTypesRef = database.collection("users").document(uid).collection("foodTypes")
            shoppingListRef = database.collection("users").document(uid).collection("shoppingList")
            likedRecipesRef = database.collection("users").document(uid).collection("likedRecipes")
            finishedRecipesRef = database.collection("users").document(uid).collection("finishedRecipes")
            scoresRef = database.collection("users").document(uid).collection("scores")
        }
        
    func configure(withUID uid: String) {
        self.uid = uid
    }
    
    
    func fetchUserInfo(completion: (Result<UserInfo?, Error>) -> Void) async {
        do {
            let querySnapshot = try await userInfoRef.getDocument()
            if querySnapshot.exists {
                print("document exsist")
                let userInfo = try querySnapshot.data(as: UserInfo.self)
                completion(.success(userInfo))
            } else {
                print("document not exxist, createing a default user Info...")
                completion(.success(nil))
            }
        } catch {
            completion(.failure(error))
        }
    }
    
    func updateUserInfo(userInfo: UserInfo, completion: (Result<Any?, Error>) -> Void) async {
        do {
            try userInfoRef.setData(from: userInfo)
            completion(.success(nil))
        } catch {
            completion(.failure(error))
        }
    }
    
    // MARK: - Food Type
    // 剛註冊時加入即可
    func addDefaultTypes() async {
        let types: [FoodType] = FoodTypeData.share.data
        
        for type in types {
            do {
                let docRef = foodTypesRef.document(String(type.typeId))
                let data: [String: Any] = [
                    "categoryId": type.categoryId,
                    "typeId": type.typeId,
                    "typeName": type.typeName,
                    "typeIcon": type.typeIcon
                ]
                try await docRef.setData(data)
                print("default data was written!")
            } catch {
                print("error: \(error)")
            }
        }
        
    }
    
    func addUserFoodTypes(foodType: FoodType, completion: (Result<Any?, Error>) -> Void) async {
        do {
            let docRef = foodTypesRef.document(String(foodType.typeId))
            try docRef.setData(from: foodType)
            print("default data was written!")
            completion(.success(nil))
        } catch {
            print("error: \(error)")
            completion(.failure(error))
        }
    }
    
    func deleteUserFoodTypes(typeId: String, completion: (Result<Any?, Error>) -> Void) async {
        do {
            try await foodTypesRef.document(typeId).delete()
            completion(.success(nil))
        } catch {
            completion(.failure(error))
        }
    }
    
    func fetchFoodType(completion: (Result<[FoodType], Error>) -> Void) async {
        do {
            let querySnapshot = try await foodTypesRef.getDocuments()
            var foodTypes = [FoodType]()
            for document in querySnapshot.documents {
                let foodType = try document.data(as: FoodType.self)
                foodTypes.append(foodType)
            }
            completion(.success(foodTypes))
        } catch {
            completion(.failure(error))
        }
    }
    
    func queryFoodType(typeId: String, completion: (Result< FoodType, Error>) -> Void) async {
        do {
            let querySnapshot = try await foodTypesRef.document(String(describing: typeId)).getDocument()
            let foodType = try querySnapshot.data(as: FoodType.self)
            completion(.success(foodType))
        } catch {
            completion(.failure(error))
        }
    }
    
    // MARK: - Food Card
    func fetchFoodCard(completion: (Result<[FoodCard], Error>) -> Void) async {
        guard let uid = uid else {
            print("cannot get uid")
            return
        }
        do {
            let querySnapshot = try await foodCardsRef.getDocuments()
            var foodCards = [FoodCard]()
            for document in querySnapshot.documents {
                let foodCard = try document.data(as: FoodCard.self)
                foodCards.append(foodCard)
            }
            completion(.success(foodCards))
        } catch {
            completion(.failure(error))
        }
    }
    
    func saveFoodCard(_ foodCard: FoodCard, completion: (Result<Any?, Error>) -> Void) async {
        do {
            let docRef = foodCardsRef.document(foodCard.cardId)
            try docRef.setData(from: foodCard)
            completion(.success(foodCard))
        } catch {
            completion(.failure(error))
        }
    }
    
    func deleteFoodCard(_ cardId: String, completion: (Result<Any?, Error>) -> Void) async {
        do {
            try await foodCardsRef.document(cardId).delete()
            completion(.success(nil))
        } catch {
            completion(.failure(error))
        }
    }
    
    func queryFoodCard(by typeId: String, completion: (Result<[FoodCard], Error>) -> Void) async {
        do {
            let querySnapshot = try await foodCardsRef.whereField("typeId", isEqualTo: typeId).getDocuments()
            var foodCards = [FoodCard]()
            for document in querySnapshot.documents {
                let foodCard = try document.data(as: FoodCard.self)
                foodCards.append(foodCard)
            }
            
            completion(.success(foodCards))
        } catch {
            completion(.failure(error))
        }
    }
    
    // MARK: - Scores
    func fetchScores(completion: (Result<Scores, Error>) -> Void) async {
        do {
            let consumedNum = try await scoresRef.document("consumed").getDocument().get("number")
            let thrownNum = try await scoresRef.document("thrown").getDocument().get("number")
            guard let consumedNum = consumedNum as? Int, let thrownNum = thrownNum as? Int else {
                // set up initial store 0:0
                print("setting up initial score...")
                await setupInitialScores { result in
                    switch result {
                    case .success(let scores):
                        completion(.success(scores))
                    case .failure(let error):
                        completion(.failure(error))
                    }
                }
                return
            }
            
            let scores = Scores(consumed: consumedNum, thrown: thrownNum)
            completion(.success(scores))
        } catch {
            completion(.failure(error))
        }
    }
    
    func setupInitialScores(completion: (Result<Scores, Error>) -> Void) async {
        do {
            let initialScore = Scores(consumed: 0, thrown: 0)
            let consumedRef = scoresRef.document("consumed")
            let consumedData: [String: Any] = ["number": initialScore.consumed]
            
            let thrownRef = scoresRef.document("thrown")
            let thrownData: [String: Any] = ["number": initialScore.thrown]
            
            try await consumedRef.setData(consumedData)
            try await thrownRef.setData(thrownData)
            
            completion(.success(initialScore))
        } catch {
            completion(.failure(error))
        }
    }
    
    func changeScores(deleteWay: String, completion: (Result<Any?, Error>) -> Void) async {
        do {
            
            let docRef = scoresRef.document(deleteWay)
            let number = try await docRef.getDocument().get("number")
            guard let oldScore = number as? Int else {
                print("cannot get the score number")
                return
            }
            let newScore = oldScore + 1
            let data: [String: Any] = [ "number": newScore ]
            try await docRef.setData(data)
            completion(.success(newScore))
        } catch {
            completion(.failure(error))
        }
    }
    
    // MARK: - Recipe
    func fetchRecipes(completion: (Result<[Recipe], Error>) -> Void) async {
        do {
            let querySnapshot = try await database.collection("recipes").getDocuments()
            var recipes = [Recipe]()
            for document in querySnapshot.documents {
                let recipe = try document.data(as: Recipe.self)
                recipes.append(recipe)
            }
            completion(.success(recipes))
        } catch {
            completion(.failure(error))
        }
    }
    
    func fetchLikedRecipeId(completion: (Result<[String], Error>) -> Void ) async {
        do {
            let querySnapshot = try await likedRecipesRef.getDocuments()
            var likedRecipes = [String]()
            for document in querySnapshot.documents {
                let recipeid = document.documentID
                likedRecipes.append(recipeid)
            }
            completion(.success(likedRecipes))
        } catch {
            completion(.failure(error))
        }
    }
    
    func addLikedRecipe(by recipeId: String, completion: (Result<Any?, Error>) -> Void) async {
        do {
            let docRef = likedRecipesRef.document(recipeId)
            let data: [String: Any] = [ "recipeId": recipeId ]
            try await docRef.setData(data)
            completion(.success(recipeId))
        } catch {
            completion(.failure(error))
        }
    }
    
    func removeLikedRecipe(by recipeId: String, completion: (Result<Any?, Error>) -> Void) async {
        do {
            try await likedRecipesRef.document(recipeId).delete()
            completion(.success(recipeId))
        } catch {
            completion(.failure(error))
        }
    }
    
    func addFinishedRecipe(by recipeId: String, completion: (Result<Any?, Error>) -> Void) async {
        do {
            let docRef = finishedRecipesRef.document(recipeId)
            let data: [String: Any] = [ "recipeId": recipeId ]
            try await docRef.setData(data)
            completion(.success(recipeId))
        } catch {
            completion(.failure(error))
        }
    }
    
    func fetchFinishedRecipeId(completion: (Result<[String], Error>) -> Void ) async {
        do {
            let querySnapshot = try await finishedRecipesRef.getDocuments()
            var finishedRecipes = [String]()
            for document in querySnapshot.documents {
                let recipeid = document.documentID
                finishedRecipes.append(recipeid)
            }
            completion(.success(finishedRecipes))
        } catch {
            completion(.failure(error))
        }
    }

    // MARK: - Shopping List
    func addListItem(_ item: ListItem, completion: (Result<Any?, Error>) -> Void) async {
        do {
            let docRef = shoppingListRef.document(item.itemId)
            try docRef.setData(from: item)
            completion(.success(nil))
        } catch {
            completion(.failure(error))
        }
    }
    
    func updateCheckStatus(newItem: ListItem, completion: (Result<Any?, Error>) -> Void) async {
        do {
            let docRef = shoppingListRef.document(newItem.itemId)
            try await docRef.updateData([
                "checkStatus": newItem.checkStatus
              ])
            completion(.success(nil))
        } catch {
            completion(.failure(error))
        }
    }
    
    func fetchListItems(completion: (Result<[ListItem], Error>) -> Void) async {
        do {
            let querySnapshot = try await shoppingListRef.getDocuments()
            var list = [ListItem]()
            for document in querySnapshot.documents {
                let item = try document.data(as: ListItem.self)
                list.append(item)
            }
            completion(.success(list))
        } catch {
            completion(.failure(error))
        }
    }
    
    func deleteListItem(by itemId: String, completion: (Result<Any?, Error>) -> Void) async {
        do {
            try await shoppingListRef.document(itemId).delete()
            completion(.success(itemId))
        } catch {
            completion(.failure(error))
        }
    }
}
