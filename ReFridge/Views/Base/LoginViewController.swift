//
//  LoginViewController.swift
//  ReFridge
//
//  Created by Melody Lee on 2024/4/29.
//

import UIKit
import AuthenticationServices
import CryptoKit
import FirebaseAuth

class LoginViewController: UIViewController {
    
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
    
    
//    @IBAction func didTappedSignInWithApple(_ sender: Any) {
//        print("sign in with apple")
//        performAppleSignIn()
//        
//    }
    
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
      
      accountManager.didCompleteWithAppleAuth(controller: controller, authorization: authorization) { result in
          switch result {
          case .success(let user):
              print("UID: \(user.uid), user name: \(user.displayName ?? "unknown"), email: \(user.email ?? "unknown")")
              self.presentingViewController?.dismiss(animated: true)
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
