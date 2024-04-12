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

    private init() {
        database = Firestore.firestore()
    }
    
    // MARK: -Food Type
    // 剛註冊時加入即可
    func addDefaultTypes() async {
        let types: [FoodType] = DefaultTypeData.share.data
        
        for type in types {
            do {
                let foodTypesRef = database.collection("users").document("userId").collection("foodTypes")
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
    
 
    func fetchFoodType(completion: (Result<[FoodType], Error>) -> Void) async {
        do {
            let querySnapshot = try await database.collection("users").document("userId").collection("foodTypes").getDocuments()
            var foodTypes = [FoodType]()
            for document in querySnapshot.documents {
                let foodType = try document.data(as: FoodType.self)
                print(foodType)
                foodTypes.append(foodType)
            }
            completion(.success(foodTypes))
        } catch {
            completion(.failure(error))
        }
    }
    
    // MARK: -Food Card
    func fetchFoodCard(completion: (Result<[FoodCard], Error>) -> Void) async {
        do {
            let querySnapshot = try await database.collection("users").document("userId").collection("foodCards").getDocuments()
            
            var foodCards = [FoodCard]()
            for document in querySnapshot.documents {
                let foodCard = try document.data(as: FoodCard.self)
                print(foodCard.name)
                foodCards.append(foodCard)
            }
            completion(.success(foodCards))
        } catch {
            completion(.failure(error))
        }
    }
    
    func addFoodCard(_ foodCard: FoodCard, completion: (Result<Any?, Error>) -> Void) async {
        do {
            let foodCardsRef = database.collection("users").document("userId").collection("foodCards")
            let docRef = foodCardsRef.document(foodCard.cardId)
            let data: [String: Any] = [
                "cardId": foodCard.cardId,
                "name": foodCard.name,
                "categoryId": foodCard.categoryId,
                "typeId": foodCard.typeId,
                "iconName": foodCard.iconName,
                "qty": foodCard.qty,
                "createDate": foodCard.createDate,
                "expireDate": foodCard.expireDate,
                "notificationTime": foodCard.notificationTime,
                "barCode": foodCard.barCode,
                "storageType": foodCard.storageType,
                "notes": foodCard.notes
            ]
            try await docRef.setData(data)
            completion(.success(nil))
        } catch {
            completion(.failure(error))
        }
    }
}
