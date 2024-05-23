//
//  ShoppingListViewModel.swift
//  ReFridge
//
//  Created by Melody Lee on 2024/5/17.
//

import Foundation

class ShoppingListViewModel {
    private let firestoreManager = FirestoreManager.shared
    
    var list = [ListItem]()
    
    func fetchList(completion: @escaping (Result<[ListItem], Error>) -> Void) {
        Task {
            let colRef = firestoreManager.shoppingListRef
            firestoreManager.fetchDatas(from: colRef) { [self] (result: Result<[ListItem], RFError>) in
                switch result {
                case .success(let list):
                    let sortedList = list.sorted { $0.createDate > $1.createDate }
                    self.list = sortedList
                    completion(.success(list))
                case .failure(let error):
                    print("error: \(error)")
                    completion(.failure(error))
                }
            }
        }
    }
    
    func addAllCheckedItemToFridge(completion: @escaping () -> Void) {
        let dispatchGroup = DispatchGroup()
        
        let checkItems = list.filter { $0.checkStatus == 1 }
        
        // create card
        for item in checkItems {
            dispatchGroup.enter()
            let foodCard = createFoodCard(item: item)
            postFoodCard(foodCard: foodCard) { result in
                switch result {
                case .success:
                    dispatchGroup.leave()
                    self.deleteItem(item: item)
                case .failure(let error):
                    print("error: \(error)")
                    dispatchGroup.leave()
                }
            }
        }
        dispatchGroup.notify(queue: .main) {
            completion()
        }
    }
    
    private func createFoodCard(item: ListItem) -> FoodCard {
        let foodCard = FoodCard(
            cardId: UUID().uuidString,
            name: item.name,
            categoryId: item.categoryId,
            typeId: item.typeId,
            iconName: item.iconName,
            qty: item.qty,
            mesureWord: item.mesureWord,
            createDate: Date(),
            expireDate: Date().createExpiredDate(afterDays: 7) ?? Date(),
            isRoutineItem: item.isRoutineItem,
            barCode: "",
            storageType: 0,
            notes: "")
        return foodCard
    }
    
    private func postFoodCard(foodCard: FoodCard, completion: @escaping (Result<Void, Error>) -> Void) {
        let docRef = firestoreManager.foodCardsRef.document(foodCard.cardId)
        Task {
            firestoreManager.updateDatas(to: docRef, with: foodCard) { (result: Result< Void, RFError>) in
                switch result {
                case .success:
                    print("update food card successfully")
                    completion(.success(()))
                case .failure(let error):
                    print("error: \(error)")
                    completion(.failure(error))
                }
            }
        }
    }
    
    // MARK: - delete item
    func deleteItem(item: ListItem) {
        let docRef = firestoreManager.shoppingListRef.document(item.itemId)
        Task {
            firestoreManager.deleteDatas(from: docRef) { result in
                switch result {
                case .success:
                    print("delete document successfully")
                case .failure(let error):
                    print("error: \(error)")
                }
            }
        }
    }
    
    
    // MARK: - update item
   func updateItem(item: ListItem) {
        let docRef = firestoreManager.shoppingListRef.document(item.itemId)
        Task {
            firestoreManager.updateDatas(to: docRef, with: item) { result in
                switch result {
                case .success:
                    print("did update checkStatus for \(item.itemId)")
                case .failure(let error):
                    print("error: \(error)")
                }
            }
        }
    }
}
