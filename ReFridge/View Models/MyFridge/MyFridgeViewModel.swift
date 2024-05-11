//
//  MyFridgeViewModel.swift
//  ReFridge
//
//  Created by Melody Lee on 2024/5/11.
//

import Foundation

class MyFridgeViewModel {
    private let firestoreManager = FirestoreManager.shared
    private let accountManager = AccountManager.share
    private var allCards = [FoodCard]()
    
    func fetchFoodCards(filter: CardFilter, completion: @escaping (Result<[FoodCard], Error>) -> Void) {
        
        let reference = firestoreManager.foodCardsRef
        
        Task {
            firestoreManager.fetchDatas(from: reference) { [self] (result: Result<[FoodCard], Error>) in
                switch result {
                case .success(let foodCards):
                    allCards = foodCards
                    let filteredCards = filterFoodCards(by: filter)
                    completion(.success(filteredCards))
                case .failure(let error):
                    print("error: \(error)")
                    completion(.failure(error))
                }
            }
        }
    }
    
    func filterFoodCards(by filter: CardFilter) -> [FoodCard] {
        // filter
        var filteredCards = [FoodCard]()
        if let categoryId = filter.categoryId {
            filteredCards = allCards.filter { card in
                card.categoryId == categoryId
            }
        } else {
            filteredCards = allCards
        }
        
        // sort
        let sortBy = filter.sortBy
        switch sortBy {
        case .remainingDay:
            filteredCards.sort { lhs, rhs in
                lhs.expireDate.calculateRemainingDays() ?? 0 <= rhs.expireDate.calculateRemainingDays() ?? 0
            }
        case .createDay:
            filteredCards.sort { lhs, rhs in
                lhs.createDate >= rhs.createDate
            }
        case .category:
            filteredCards.sort { lhs, rhs in
                lhs.categoryId <= rhs.categoryId
            }
        }
        
        return filteredCards
    }
    
    func searchFoodCards(with searchText: String) -> [FoodCard] {
        var filteredCards = allCards.filter({ card in
            card.name.localizedCaseInsensitiveContains(searchText) || card.barCode.localizedCaseInsensitiveContains(searchText)
        })
        
        return filteredCards
    }
    
}
