//
//  ViewController.swift
//  ReFridge
//
//  Created by Melody Lee on 2024/4/9.
//

import UIKit

class MyFridgeViewController: UIViewController {

    let db = FirestoreManager.shared.database

    override func viewDidLoad() {
        super.viewDidLoad()
        print("123")
        Task {
            await addData()
        }
    }

    func addData() async {
        do {
            let foodCards = db.collection("users").document("userId").collection("foodCards")
            let foodCard = foodCards.document()
            let data: [String: Any] = [
                "name": "善美的花椰菜",
                "categoryId": 1,
                "typeId": 2,
                "quantity": 5,
                "createTime": Date().timeIntervalSince1970,
                "expireDate": Date().timeIntervalSince1970 + 10000000,
                "notificationTime": 7,
                "barcode": 12345678,
                "storageType": 0,
                "notes": "使用者記錄使用者紀錄"
            ]
            try await foodCard.setData(data)
            print("Document successfully written!")
        } catch {
            print("Error adding document: \(error)")
        }
    }
}
