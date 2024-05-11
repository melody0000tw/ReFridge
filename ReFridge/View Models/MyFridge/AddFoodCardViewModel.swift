//
//  AddFoodCardViewModel.swift
//  ReFridge
//
//  Created by Melody Lee on 2024/5/11.
//

import Foundation
import Combine

class AddFoodCardViewModel {
    private let firestoreManager = FirestoreManager.shared
    private let accountManager = AccountManager.share
    
    @Published var foodCard: FoodCard
    private var cancellables = Set<AnyCancellable>()
    
    
    
    init(foodCard: FoodCard = FoodCard()) {
            self.foodCard = foodCard
        }
    
    func updateFoodCard(
        name: String? = nil,
        typeId: String? = nil,
        categoryId: Int? = nil,
        iconName: String? = nil,
        qty: Int? = nil,
        mesureWord: String? = nil,
        expireDate: Date? = nil,
        isRoutineItem: Bool? = nil,
        barCode: String? = nil,
        storageType: Int? = nil,
        notes: String? = nil) {
            updateProperty(&foodCard.name, value: name)
            updateProperty(&foodCard.typeId, value: typeId)
            updateProperty(&foodCard.categoryId, value: categoryId)
            updateProperty(&foodCard.iconName, value: iconName)
            updateProperty(&foodCard.qty, value: qty)
            updateProperty(&foodCard.mesureWord, value: mesureWord)
            updateProperty(&foodCard.expireDate, value: expireDate)
            updateProperty(&foodCard.isRoutineItem, value: isRoutineItem)
            updateProperty(&foodCard.barCode, value: barCode)
            updateProperty(&foodCard.storageType, value: storageType)
            updateProperty(&foodCard.notes, value: notes)
        }
    
    private func updateProperty<T>(_ property: inout T, value: T?) {
        if let value = value {
            property = value
        }
    }
    
    func saveFoodCard(completion: @escaping (Result<Void, ErrorType>) -> Void) {

        guard foodCard.name != "" else {
            completion(.failure(.incompletedInfo))
            return
        }
        
        if foodCard.cardId == "" {
            foodCard.cardId = UUID().uuidString
        }
        
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
        }
    }
    
    func didTappedDeleteBtn(deleteWay: DeleteWay, completion: @escaping (Result<Void, ErrorType>) -> Void) {
        if foodCard.isRoutineItem {
            addToShoppingList()
        }
        updateScores(deleteWay: deleteWay)
        deleteFoodCard(completion: completion)
    }
    
    func deleteFoodCard(completion: @escaping (Result<Void, ErrorType>) -> Void) {
        guard foodCard.cardId != "" else {
            print("no food card id")
            return
        }
        let docRef = firestoreManager.foodCardsRef.document(foodCard.cardId)
        Task {
            firestoreManager.deleteDatas(from: docRef) { (result: Result< Void, Error>) in
                switch result {
                case .success:
                    print("delete food card successfully")
                    completion(.success(()))
                case .failure(let error):
                    print("error: \(error)")
                    completion(.failure(.firebaseError(error)))
                }
                
            }
        }
    }
    
    private func updateScores(deleteWay: DeleteWay) {
        let way = deleteWay.rawValue
        let docRef = firestoreManager.scoresRef.document(way)
        
        Task {
            firestoreManager.fetchData(from: docRef) { (result: Result<Score, Error>) in
                switch result {
                case .success(let score):
                    print("successfully fetch old score")
                    let newNum = score.number + 1
                    let newScore = Score(number: newNum)
                    self.firestoreManager.updateDatas(to: docRef, with: newScore) { (result: Result<Void, Error>) in
                        switch result {
                        case .success():
                            print("update scores successfully")
                        case .failure(let error):
                            print("error: \(error)")
                        }
                    }
                case .failure(let error):
                    print("error: \(error)")
                }
            }
        }
    }
    
    private func addToShoppingList() {
        var item = ListItem()
        item.checkStatus = 0
        item.itemId = UUID().uuidString
        item.categoryId = foodCard.categoryId
        item.name = foodCard.name
        item.qty = foodCard.qty
        item.mesureWord = foodCard.mesureWord
        item.typeId = foodCard.typeId
        item.isRoutineItem = foodCard.isRoutineItem
        
        let docRef = firestoreManager.shoppingListRef.document(item.itemId)
        
        Task { [item] in
            firestoreManager.updateDatas(to: docRef, with: item) { (result: Result< Void, Error>) in
                switch result {
                case .success:
                    print("Document successfully written!")
                case .failure(let error):
                    print("Error adding list item: \(error)")
                }
            }
        }
    }
}
