//
//  ChartViewModel.swift
//  ReFridge
//
//  Created by Melody Lee on 2024/5/12.
//

import Foundation
import Combine

class ChartViewModel {
    private let firestoreManager = FirestoreManager.shared
    
    @Published var userInfo: UserInfo = UserInfo(uid: "", name: "", email: "", avatar: "", accountStatus: 2)
    @Published var foodCards = [FoodCard]()
    @Published var scores = Scores(consumed: 0, thrown: 0)
    private var cancellables = Set<AnyCancellable>()
    
    func fetchDatas() {
        fetchUserInfo()
        fetchFoodCards()
        fetchScores()
    }
    
    private func fetchUserInfo() {
        let docRef = firestoreManager.userInfoRef
        Task {
            firestoreManager.fetchData(from: docRef) { (result: Result<UserInfo, RFError>) in
                switch result {
                case .success(let userInfo):
                    self.userInfo = userInfo
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        }
    }
    
    private func fetchFoodCards() {
        let colRef = firestoreManager.foodCardsRef
        Task {
            firestoreManager.fetchDatas(from: colRef) { (result: Result<[FoodCard], RFError>) in
                switch result {
                case .success(let foodCards):
                    self.foodCards = foodCards
                case .failure(let error):
                    print("error: \(error)")
                }
            }
        }
    }
    
    private func fetchScores() {
        for way in DeleteWay.allCases {
            let docRef = firestoreManager.scoresRef.document(way.rawValue)
            _Concurrency.Task {
                firestoreManager.fetchData(from: docRef) { (result: Result<Score, RFError>) in
                    switch result {
                    case .success(let score):
                        if way == .consumed {
                            self.scores.consumed = score.number
                        } else if way == .thrown {
                            self.scores.thrown = score.number
                        }
                    case .failure(let error):
                        print("error: \(error)")
                    }
                }
            }
        }
    }
    
    func updateAccountStatus() {
        userInfo.accountStatus = 0
        let docRef = firestoreManager.userInfoRef
        Task {
            firestoreManager.updateDatas(to: docRef, with: userInfo) { result in
                switch result {
                case .success:
                    print("userInfo is updated")
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        }
    }
}
