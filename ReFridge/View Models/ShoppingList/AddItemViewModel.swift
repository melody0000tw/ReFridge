//
//  AddItemViewModel.swift
//  ReFridge
//
//  Created by Melody Lee on 2024/5/17.
//

import Foundation
import Combine

class AddItemViewModel {
    private let firestoreManager = FirestoreManager.shared
    
    @Published var listItem: ListItem
    private var cancellables = Set<AnyCancellable>()
    
    init(listItem: ListItem = ListItem()) {
        self.listItem = listItem
    }
    
    func updateItem(
        name: String? = nil,
        typeId: String? = nil,
        categoryId: Int? = nil,
        iconName: String? = nil,
        qty: Int? = nil,
        mesureWord: String? = nil,
        notes: String? = nil) {
            updateProperty(&listItem.name, value: name)
            updateProperty(&listItem.typeId, value: typeId)
            updateProperty(&listItem.categoryId, value: categoryId)
            updateProperty(&listItem.iconName, value: iconName)
            updateProperty(&listItem.qty, value: qty)
            updateProperty(&listItem.mesureWord, value: mesureWord)
            updateProperty(&listItem.notes, value: notes)
    }
    
    private func updateProperty<T>(_ property: inout T, value: T?) {
        if let value = value {
            property = value
        }
    }
    
    func saveItem(completion: @escaping (Result<Void, Error>) -> Void) {
        Task {
            let docRef = firestoreManager.shoppingListRef.document(listItem.itemId)
            firestoreManager.updateDatas(to: docRef, with: listItem) { result in
                switch result {
                case .success:
                    completion(.success(()))
                case .failure(let error):
                    print("error: \(error)")
                    completion(.failure(error))
                }
            }
        }
    }
    
}
