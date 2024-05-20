//
//  FirestoreManager.swift
//  ReFridge
//
//  Created by Melody Lee on 2024/4/11.
//

import Foundation
import FirebaseFirestore
import Network

class FirestoreManager {
    static let shared = FirestoreManager()
    private let accountManager = AccountManager.share
    private let networkManager = NetworkManager.shared
    let database: Firestore
    
    var uid: String? {
        didSet {
            if let uid = uid {
                updateDatabaseReferences(uid: uid)
            }
        }
    }
    
    lazy var userInfoRef = database.collection("users").document("userId").collection("userInfo").document("data")
    lazy var foodCardsRef = database.collection("users").document("userId").collection("foodCards")
    lazy var foodTypesRef = database.collection("users").document("userId").collection("foodTypes")
    lazy var shoppingListRef = database.collection("users").document("userId").collection("shoppingList")
    lazy var likedRecipesRef = database.collection("users").document("userId").collection("likedRecipes")
    lazy var finishedRecipesRef = database.collection("users").document("userId").collection("finishedRecipes")
    lazy var scoresRef = database.collection("users").document("userId").collection("scores")
    lazy var recipeRef = database.collection("recipes")

    private init() {
        database = Firestore.firestore()
    }
    
    // MARK: - UserInfo
    private func updateDatabaseReferences(uid: String) {
            userInfoRef = database.collection("users").document(uid).collection("userInfo").document("data")
            foodCardsRef = database.collection("users").document(uid).collection("foodCards")
            foodTypesRef = database.collection("users").document(uid).collection("foodTypes")
            shoppingListRef = database.collection("users").document(uid).collection("shoppingList")
            likedRecipesRef = database.collection("users").document(uid).collection("likedRecipes")
            finishedRecipesRef = database.collection("users").document(uid).collection("finishedRecipes")
            scoresRef = database.collection("users").document(uid).collection("scores")
        }
        
    func configure(withUID uid: String) {
        self.uid = uid
    }
    
    // MARK: - Base Functions
    func fetchDatas<T: Codable>(from reference: CollectionReference, completion: @escaping (Result<[T], RFError>) -> Void) {
        guard networkManager.checkInternetConnetcion() else {
            completion(.failure(RFError.noInternet))
            return
        }
        print("fetchDatas starts!")
        reference.getDocuments { (snapshot, error) in
            if let error = error {
                completion(.failure(RFError.firebaseError(error)))
            } else {
                var items = [T]()
                snapshot?.documents.forEach { document in
                    if let item = try? document.data(as: T.self) {
                        items.append(item)
                    }
                }
                completion(.success(items))
            }
        }
    }
    
    func fetchData<T: Codable>(from reference: DocumentReference, completion: @escaping (Result<T, RFError>) -> Void) {
        guard networkManager.checkInternetConnetcion() else {
            completion(.failure(RFError.noInternet))
            return
        }
        
        reference.getDocument(as: T.self) { result in
            switch result {
            case .success(let data):
                completion(.success(data))
            case .failure(let error):
                completion(.failure(.firebaseError(error)))
            }
        }
    }
    
    func updateDatas<T: Codable>(to reference: DocumentReference, with data: T, completion: @escaping (Result<Void, RFError>) -> Void) {
        guard networkManager.checkInternetConnetcion() else {
            completion(.failure(RFError.noInternet))
            return
        }
        
        do {
            try reference.setData(from: data) { error in
                if let error = error {
                    completion(.failure(.firebaseError(error)))
                } else {
                    completion(.success(()))
                }
            }
        } catch {
            completion(.failure(.firebaseError(error)))
        }
    }
    
    func deleteDatas(from reference: DocumentReference, completion: @escaping (Result<Void, RFError>) -> Void) {
        guard networkManager.checkInternetConnetcion() else {
            completion(.failure(RFError.noInternet))
            return
        }
        
        reference.delete { error in
            if let error = error {
                completion(.failure(.firebaseError(error)))
            } else {
                completion(.success(()))
            }
        }
    }
    
    func queryDatas<T: Codable>(query: Query, completion: @escaping (Result<[T], RFError>) -> Void) {
        guard networkManager.checkInternetConnetcion() else {
            completion(.failure(RFError.noInternet))
            return
        }
        
        query.getDocuments { (snapshot, error) in
            if let error = error {
                completion(.failure(.firebaseError(error)))
            } else {
                var items = [T]()
                snapshot?.documents.forEach { document in
                    if let item = try? document.data(as: T.self) {
                        items.append(item)
                    }
                }
                completion(.success(items))
            }
        }
    }
    
    func createQuery<T: Codable>(reference: CollectionReference, field: String, isEqualTo value: T) -> Query {
        let query = reference.whereField(field, isEqualTo: value)
        return query
    }
}
