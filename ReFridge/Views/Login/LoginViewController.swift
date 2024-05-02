//
//  LoginViewController.swift
//  ReFridge
//
//  Created by Melody Lee on 2024/5/1.
//

import UIKit
import AuthenticationServices
import CryptoKit
import FirebaseAuth

class LoginViewController: UIViewController {
    let firestoreManager = FirestoreManager.shared
    private let accountManager = AccountManager.share

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupViews()
    }
    
    private func setupViews() {
        let label = UILabel()
        label.text = "請先登入帳戶"
        label.font = UIFont(name: "PingFangTC-Regular", size: 20)
        label.textAlignment = .left
        label.textColor = .darkGray
        label.numberOfLines = 1
        label.sizeToFit()
        view.addSubview(label)
        label.snp.makeConstraints { make in
            make.top.equalTo(view.snp.top).offset(250)
            make.centerX.equalTo(view.snp.centerX)
        }
        
        let button = ASAuthorizationAppleIDButton()
        button.addTarget(self, action: #selector(performAppleSignIn), for: .touchUpInside)
        view.addSubview(button)
        button.snp.makeConstraints { make in
            make.centerX.equalTo(view.snp.centerX)
            make.centerY.equalTo(view.snp.centerY)
            make.width.equalTo(180)
            make.height.equalTo(40)
        }
    }
    
    private func configureUserInfo(user: User) {
        firestoreManager.configure(withUID: user.uid)
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
        Task {
            await firestoreManager.fetchUserInfo { result in
                switch result {
                case .success(let userInfo):
                    print("已取得 userInfo : \(userInfo)")
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        }
        
    }
    
    private func presentAvatarVC() {
        let storyboard = UIStoryboard(name: "Login", bundle: nil)
        let avatarVC = storyboard.instantiateViewController(withIdentifier: "AvatarViewController")
        navigationController?.pushViewController(avatarVC, animated: true)
    }
    
    
    private func presentMyFridgeVC() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let initialViewController = storyboard.instantiateInitialViewController() {
            initialViewController.modalPresentationStyle = .fullScreen
            present(initialViewController, animated: true)
        }
    }
    
    @objc func performAppleSignIn() {
        let request = accountManager.createAppleIdRequest()
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
}

// MARK: - SignInWithApple
@available(iOS 13.0, *)
extension LoginViewController: ASAuthorizationControllerDelegate {

  func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
      
      accountManager.signInWithApple(controller: controller, authorization: authorization) { result in
          switch result {
          case .success(let user):
              print(" 已成功登入，UID: \(user.uid)")
              self.configureUserInfo(user: user)
              self.presentAvatarVC()
//              self.presentMyFridgeVC()
              
          case .failure(let error):
              print(error.localizedDescription)
          }
      }
  }

  func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
    print("Sign in with Apple errored: \(error)")
  }

}

extension LoginViewController: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
}
