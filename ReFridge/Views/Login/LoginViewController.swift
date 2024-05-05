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
    
    private lazy var logoImageView = UIImageView(image: UIImage(named: "appIcon"))
    private lazy var titleLabel = UILabel()
    private lazy var sloganLabel = UILabel()
    private lazy var button = ASAuthorizationAppleIDButton()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupViews()
        logoImageView.alpha = 0
        titleLabel.alpha = 0
        sloganLabel.alpha = 0
        button.alpha = 0
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UIView.animate(withDuration: 1, delay: 1) { [self] in
            logoImageView.alpha = 1
        }
        UIView.animate(withDuration: 1, delay: 2) { [self] in
            titleLabel.alpha = 1
        }
        UIView.animate(withDuration: 1, delay: 3) { [self] in
            sloganLabel.alpha = 1
        }
        UIView.animate(withDuration: 1, delay: 4) { [self] in
            button.alpha = 1
        }
    }
    
    private func setupViews() {
        view.backgroundColor = UIColor(hex: "CBD2A4")
        view.addSubview(logoImageView)
        logoImageView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(48)
            make.width.height.equalTo(view.snp.width).multipliedBy(0.8)
            make.centerX.equalTo(view.snp.centerX)
        }
        
        titleLabel.text = "ReFridge"
        titleLabel.font = UIFont(name: "NothingYouCouldDo", size: 40)
        titleLabel.textAlignment = .center
        titleLabel.textColor = .darkGray
        titleLabel.numberOfLines = 1
        titleLabel.sizeToFit()
        view.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(logoImageView.snp.bottom).offset(48)
            make.centerX.equalTo(view.snp.centerX)
        }
        
        sloganLabel.text = "Rebuilding the relationship with your fridge."
        sloganLabel.font = UIFont(name: "NothingYouCouldDo", size: 24)
        sloganLabel.textAlignment = .center
        sloganLabel.textColor = .darkGray
        sloganLabel.numberOfLines = 0
        sloganLabel.sizeToFit()
        view.addSubview(sloganLabel)
        sloganLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(24)
            make.leading.equalTo(view.safeAreaLayoutGuide.snp.leading).offset(24)
            make.trailing.equalTo(view.safeAreaLayoutGuide.snp.trailing).offset(-24)
            make.centerX.equalTo(view.snp.centerX)
        }
        
        button.addTarget(self, action: #selector(performAppleSignIn), for: .touchUpInside)
        view.addSubview(button)
        button.snp.makeConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-24)
            make.leading.equalTo(view.safeAreaLayoutGuide.snp.leading).offset(24)
            make.trailing.equalTo(view.safeAreaLayoutGuide.snp.trailing).offset(-24)
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
                    guard userInfo != nil else {
                        print("沒有 user Info！建立 userInfo")
                        presentAvatarVC()
                        return
                    }
                    print("已取得 userInfo : \(String(describing: userInfo))")
                    presentMyFridgeVC()
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        }
        
    }
    
    private func presentAvatarVC() {
        DispatchQueue.main.async { [self] in
            let storyboard = UIStoryboard(name: "Login", bundle: nil)
            guard let avatarVC = storyboard.instantiateViewController(withIdentifier: "AvatarViewController") as? AvatarViewController else {
                print("cannot get avatar vc")
                return
            }
            
            guard let currentUser = accountManager.getCurrentUser() else {
                print("cannot get current user")
                return
            }
            
            let userInfo = UserInfo(
                uid: currentUser.uid,
                name: currentUser.displayName ?? "unkown",
                email: currentUser.email ?? "unknown",
                avatar: "avatar-avocado",
                accountStatus: 1
            )
            
            avatarVC.mode = .setup
            avatarVC.userInfo = userInfo
            navigationController?.pushViewController(avatarVC, animated: true)
        }
    }
    
    private func presentMyFridgeVC() {
        DispatchQueue.main.async {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if let initialViewController = storyboard.instantiateInitialViewController() {
                initialViewController.modalPresentationStyle = .fullScreen
                self.present(initialViewController, animated: false)
            }
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
