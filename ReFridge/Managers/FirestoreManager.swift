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
    
    func addFoodCard(_ foodCard: FoodCard, completion: (Result<Any?, Error>) -> Void) async {
        do {
            let foodCards = database.collection("users").document("userId").collection("foodCards")
            let document = foodCards.document()
            let data: [String: Any] = [
                "name": foodCard.name,
                "categoryId": foodCard.categoryId,
                "typeId": foodCard.typeId,
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
