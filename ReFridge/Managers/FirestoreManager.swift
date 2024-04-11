//
//  FirestoreManager.swift
//  ReFridge
//
//  Created by Melody Lee on 2024/4/11.
//

import Foundation

import Foundation
import FirebaseFirestore

class FirestoreManager {
    static let shared = FirestoreManager()
    let db: Firestore

    private init() {
        db = Firestore.firestore()
    }
}
