//
//  MyFridgeViewModel.swift
//  ReFridge
//
//  Created by Melody Lee on 2024/5/11.
//

import Foundation
import Combine

class MyFridgeViewModel {
    private let firestoreManager = FirestoreManager.shared
    var allCards = [FoodCard]()
    var filter: CardFilter {
        didSet {
            filterFoodCards()
        }
    }
    
    @Published var showCards = [FoodCard]()
    @Published var error: Error?
    @Published var isLoading: Bool = false
    
    private var cancellables = Set<AnyCancellable>()
    
    init(filter: CardFilter = CardFilter(categoryId: nil, sortBy: .remainingDay)) {
        self.filter = filter
        fetchFoodCards()
    }
    
    func fetchFoodCards() {
        isLoading = true
        let colRef = firestoreManager.foodCardsRef
        Task {
            self.firestoreManager.fetchDatas(from: colRef) { [self] (result: Result<[FoodCard], Error>) in
                switch result {
                case .success(let foodCards):
                    allCards = foodCards
                    filterFoodCards()
                case .failure(let error):
                    print("error: \(error)")
                    self.error = error
                }
                isLoading = false
            }
        }
    }
    
    func filterFoodCards() {
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
        showCards = filteredCards
    }
    
    func searchFoodCards(with searchText: String) {
        let filteredCards = allCards.filter({ card in
            card.name.localizedCaseInsensitiveContains(searchText) || card.barCode.localizedCaseInsensitiveContains(searchText)
        })
        
        showCards = filteredCards
    }
}
