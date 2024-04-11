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
            let foodCards = database.collection("users").document("userId").collection("foodCards")
            let document = foodCards.document()
            let data: [String: Any] = [
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
            try await document.setData(data)
            completion(.success(nil))
        } catch {
            completion(.failure(error))
        }
    }
}
