//
//  TabBarController.swift
//  ReFridge
//
//  Created by Melody Lee on 2024/4/29.
//

import UIKit

class TabBarController: UITabBarController {
    private let networkManager = NetworkManager.shared
    private var noInternetView: UIView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNetworkManager()
    }
    
    func presentNoInternetVC() {
        let noInternetVC = NoInternetViewController()
        noInternetVC.modalPresentationStyle = .fullScreen
        self.present(noInternetVC, animated: false)
    }
    
    func setupNetworkManager() {
        networkManager.onChangeInternetConnection = { isConnected in
            print("======= is connected to internet: \(isConnected)=======")
            DispatchQueue.main.async {
                if !isConnected {
                    self.presentNoInternetVC()
                } else {
                    self.dismiss(animated: false)
                }
            }
        }
    }
    
}
