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
    let database: Firestore
    lazy var foodCardsRef = database.collection("users").document("userId").collection("foodCards")
    lazy var foodTypesRef = database.collection("users").document("userId").collection("foodTypes")
    lazy var shoppingListRef = database.collection("users").document("userId").collection("shoppingList")
    lazy var likedRecipesRef = database.collection("users").document("userId").collection("likedRecipes")
    lazy var scoresRef = database.collection("users").document("userId").collection("cherishScores")

    private init() {
        database = Firestore.firestore()
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
//            let docRef
//            let data: [String: Any] = [
//                "cardId": foodCard.cardId,
//                "name": foodCard.name,
//                "categoryId": foodCard.categoryId,
//                "typeId": foodCard.typeId,
//                "iconName": foodCard.iconName,
//                "qty": foodCard.qty,
//                "createDate": foodCard.createDate,
//                "expireDate": foodCard.expireDate,
//                "notificationTime": foodCard.notificationTime,
//                "barCode": foodCard.barCode,
//                "storageType": foodCard.storageType,
//                "notes": foodCard.notes
//            ]
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
                print("cannot get the score number")
                return
            }
            
            let scores = Scores(consumed: consumedNum, thrown: thrownNum)
            completion(.success(scores))
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
    
    // MARK: - Shopping List
    func addListItem(_ item: ListItem, completion: (Result<Any?, Error>) -> Void) async {
        do {
//            let docRef = shoppingListRef.document()
            let docRef = shoppingListRef.document(item.itemId)
//            let data: [String: Any] = [
//                "itemId": docRef.documentID,
//                "typeId": item.typeId,
//                "qty": item.qty,
//                "checkStatus": item.checkStatus,
//                "isRoutineItem": item.isRoutineItem,
//                "routinePeriod": item.routinePeriod,
//                "routineStartTime": item.routineStartTime
//            ]
//            try await docRef.setData(data)
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
