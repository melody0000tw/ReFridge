//
//  AccountManager.swift
//  ReFridge
//
//  Created by Melody Lee on 2024/4/29.
//

import Foundation
import FirebaseAuth
import CryptoKit
import AuthenticationServices

class AccountManager {
    static let share = AccountManager()
    
    var user: User?
    let firebaseAuth = Auth.auth()
    private var currentNonce: String?
    
    private init() {}
    
    func getCurrentUser() -> User? {
        guard let currentUser = firebaseAuth.currentUser else {
            return nil
        }
        self.user = currentUser
        return currentUser
    }
    
    func signoutFireBase(completion: (Result<Any?, Error>) -> Void) {
        do {
          try firebaseAuth.signOut()
            guard let currentUser = firebaseAuth.currentUser else {
                completion(.success(nil))
                return
            }
        } catch let signOutError as NSError {
            completion(.failure(signOutError))
        }
    }
    
    // MARK: - Apple Sign in
    func createAppleIdRequest() -> ASAuthorizationAppleIDRequest {
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        let nonce = randomNonceString()
        currentNonce = nonce
        request.nonce = sha256(nonce)
        return request
    }
    
    func didCompleteWithAppleAuth(controller: ASAuthorizationController, authorization: ASAuthorization, completion: @escaping (Result<User, Error>) -> Void) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            guard let nonce = currentNonce else {
                fatalError("Invalid state: A login callback was received, but no login request was sent.")
            }
            guard let appleIDToken = appleIDCredential.identityToken else {
                print("Unable to fetch identity token")
                return
            }
            guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                print("Unable to serialize token string from data: \(appleIDToken.debugDescription)")
                return
            }
            // Initialize a Firebase credential, including the user's full name.
            let credential = OAuthProvider.appleCredential(
                withIDToken: idTokenString,
                rawNonce: nonce,
                fullName: appleIDCredential.fullName
            )
            
            Auth.auth().signIn(with: credential) { (authResult, error) in
                if let error = error {
                    print(error.localizedDescription)
                    completion(.failure(error))
                    return
                }
                
                guard let user = authResult?.user else {
                    return
                }
                
                completion(.success(user))
                }
        }
        
    }

    // MARK: - Nounce
    private func randomNonceString(length: Int = 32) -> String {
      precondition(length > 0)
      var randomBytes = [UInt8](repeating: 0, count: length)
      let errorCode = SecRandomCopyBytes(kSecRandomDefault, randomBytes.count, &randomBytes)
      if errorCode != errSecSuccess {
        fatalError(
          "Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)"
        )
      }

      let charset: [Character] =
        Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")

      let nonce = randomBytes.map { byte in
        // Pick a random character from the set, wrapping around if needed.
        charset[Int(byte) % charset.count]
      }

      return String(nonce)
    }

    @available(iOS 13, *)
    private func sha256(_ input: String) -> String {
      let inputData = Data(input.utf8)
      let hashedData = SHA256.hash(data: inputData)
      let hashString = hashedData.compactMap {
        String(format: "%02x", $0)
      }.joined()

      return hashString
    }
}
