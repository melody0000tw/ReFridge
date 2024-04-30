//
//  TabBarController.swift
//  ReFridge
//
//  Created by Melody Lee on 2024/4/29.
//

import UIKit
import FirebaseCore
import FirebaseFirestore
import FirebaseAuth

class TabBarController: UITabBarController {
    private let accountManager = AccountManager.share
    private let firestoreManager = FirestoreManager.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkLoginStatus()
    }
    
    func checkLoginStatus() {
        guard let currentUser = accountManager.getCurrentUser() else {
            presentLoginPage()
            return
        }
        print("Welcome! \(currentUser.displayName ?? "stranger!")")
        //  fetch 看看有沒有 score，沒有的話就建立
        Task {
            await firestoreManager.fetchScores { result in
                switch result {
                case .success(let scores):
                    print("已取得使用者分數 score: \(scores)")
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        }
        
        
        // fetch 看看有沒有 user Name or avatar 資料，沒有的話就顯示要選擇的內容！
        
    }

    private func presentLoginPage() {
        let loginVC = LoginViewController()
        loginVC.modalPresentationStyle = .fullScreen
        self.present(loginVC, animated: true)
    }
    
}
