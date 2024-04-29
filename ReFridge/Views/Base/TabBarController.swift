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
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        checkLoginStatus()
    }
    
    func checkLoginStatus() {
        accountManager.getCurrentUser { user in
            guard let user = user else {
                presentLoginPage()
                return
            }
            print("Welcome! \(user.displayName ?? "stranger!")")
        }
    }

    
    private func presentLoginPage() {
//        guard let loginVC = storyboard?.instantiateViewController(withIdentifier: "LoginViewController") else {
//            return
//        }
        let loginVC = LoginViewController()
        loginVC.modalPresentationStyle = .fullScreen
        self.present(loginVC, animated: true)
    }
    
}
