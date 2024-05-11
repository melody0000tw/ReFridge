//
//  ScanResultViewModel.swift
//  ReFridge
//
//  Created by Melody Lee on 2024/5/11.
//

import Foundation

class ScanResultViewModel {
    private let firestoreManager = FirestoreManager.shared
    var scanResult: ScanResult
    
    init(scanResult: ScanResult) {
        self.scanResult = scanResult
    }
    
    func saveFoodCards(completion: @escaping (Result<Void, ErrorType>) -> Void) {
        let dispatchGroup = DispatchGroup()
        for foodCard in scanResult.recongItems {
            dispatchGroup.enter()
            let docRef = firestoreManager.foodCardsRef.document(foodCard.cardId)
            Task {
                firestoreManager.updateDatas(to: docRef, with: foodCard) { (result: Result< Void, Error>) in
                    switch result {
                    case .success():
                        completion(.success(()))
                    case .failure(let error):
                        print("error: \(error)")
                        completion(.failure(.firebaseError(error)))
                    }
                }
                dispatchGroup.leave()
            }
        }
        dispatchGroup.notify(queue: .main) {
            completion(.success(()))
        }
    }
    
    func addRecogCard(withNotRecogAt index: Int, completion: @escaping () -> Void) {
        let text = scanResult.notRecongItems.remove(at: index)
        let foodCard = FoodCard(
            cardId: UUID().uuidString,
            name: text,
            categoryId: 5,
            typeId: "501",
            iconName: "other",
            qty: 1, createDate: Date(),
            expireDate: Date().createExpiredDate(afterDays: 7) ?? Date(),
            isRoutineItem: false,
            barCode: "",
            storageType: 0,
            notes: "")
        scanResult.recongItems.insert(foodCard, at: 0)
        completion()
    }
    
    func deleteRecogCard(at index: Int, completion: @escaping () -> Void) {
        scanResult.recongItems.remove(at: index)
        completion()
    }
    
    func updateRecogCard(newCard: FoodCard, completion: @escaping () -> Void) {
        if let index = scanResult.recongItems.firstIndex(where: { $0.cardId == newCard.cardId }) {
            scanResult.recongItems[index] = newCard
            completion()
        }
    }
}
