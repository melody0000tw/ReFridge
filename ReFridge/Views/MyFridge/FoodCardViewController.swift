//
//  FoodCardViewController.swift
//  ReFridge
//
//  Created by Melody Lee on 2024/4/11.
//

import UIKit
import SnapKit
import IQKeyboardManagerSwift

class FoodCardViewController: UIViewController {
    var foodCard = FoodCard.share
    
    let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }()
    
    private let firestoreManager = FirestoreManager.shared
    
    private var expiredDate: Date? {
        didSet {
            if let expiredDate = expiredDate {
                expireTimeTextField.text = formatter.string(from: expiredDate)
            }
        }
    }
    
    let datePicker = UIDatePicker()
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var barcodeTextField: UITextField!
    @IBOutlet weak var expireTimeTextField: UITextField!
    @IBOutlet weak var qtyTextField: UITextField!
    @IBOutlet weak var notificationTimeTextField: UITextField!
    @IBOutlet weak var storageSegment: UISegmentedControl!
    @IBOutlet weak var noteTextField: UITextField!
    @IBAction func didTappedSave(_ sender: Any) {
        saveData()
    }
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupFoodTypeCollection()
        setupDatePicker()
        setupInitialData()
    }
    
    // MARK: Setups
    private func setupFoodTypeCollection() {
        if let foodTypeVC = children.compactMap({ $0 as? FoodTypeCollectionViewController }).first {
            foodTypeVC.onSelectFoodType = { foodType in
                print("card vc knows the selected foodtype: \(foodType)")
            }
        }
    }
    
    private func setupDatePicker() {
        datePicker.preferredDatePickerStyle = .wheels
        datePicker.datePickerMode = .date
        expireTimeTextField.inputView = datePicker
        
        // Toolbar
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneAction))
        toolbar.setItems([doneButton], animated: true)
        expireTimeTextField.inputAccessoryView = toolbar
    }
    
    @objc func doneAction() {
        expiredDate = datePicker.date
        expireTimeTextField.resignFirstResponder()
    }
    
    // MARK: - Data
    
    private func setupInitialData() {
        if foodCard.cardId != "" {
            nameLabel.text = foodCard.name
            imageView.image = UIImage(named: foodCard.iconName)
            barcodeTextField.text = String(foodCard.barCode)
            expireTimeTextField.text = formatter.string(from: foodCard.expireDate)
            qtyTextField.text = String(foodCard.qty)
            notificationTimeTextField.text = String(foodCard.notificationTime)
            noteTextField.text = foodCard.notes
            storageSegment.selectedSegmentIndex = foodCard.storageType
        } else {
            resetData()
        }
    }
    
    private func resetData() {
        DispatchQueue.main.async { [self] in
            nameLabel.text = "請選取食物種類"
            imageView.image = UIImage(systemName: "fork.knife.circle")
            barcodeTextField.text = nil
            expireTimeTextField.text = ""
            qtyTextField.text = nil
            notificationTimeTextField.text = nil
            noteTextField.text = nil
            storageSegment.selectedSegmentIndex = 0
        }
    }
    
//    private func saveData() {
//        print("save data")
//        guard let name = nameLabel.text,
//              let typeId = selectedFoodType?.id,
//              let iconName = selectedFoodType?.iconName,
//              let barCode = barcodeTextField.text,
//              let expireDate = expiredDate,
//              let qty = qtyTextField.text,
//              let notificationTime = notificationTimeTextField.text
//        else {
//            print("empty data")
//            return
//        }
//        let foodCard = FoodCard(
//            cardId: UUID().uuidString,
//            name: name,
//            categoryId: selectedFoodCategory.id,
//            typeId: typeId,
//            iconName: iconName,
//            qty: Int(qty) ?? 0,
//            createDate: Date(),
//            expireDate: expireDate,
//            notificationTime: Int(notificationTime) ?? 0,
//            barCode: Int(barCode) ?? 0,
//            storageType: storageSegment.selectedSegmentIndex,
//            notes: noteTextField.text ?? "")
//        
//        print(foodCard)
//        
//        Task {
//            await firestoreManager.addFoodCard(foodCard) { result in
//                switch result {
//                case .success:
//                    print("Document successfully written!")
//                    resetData()
//                case .failure(let error):
//                    print("Error adding document: \(error)")
//                }
//                
//            }
//        }
//    }
    
    private func saveData() {
        print("save data")
//        guard let name = nameLabel.text,
//              let typeId = selectedFoodType?.typeId,
//              let iconName = selectedFoodType?.typeIcon,
//              let barCode = barcodeTextField.text,
//              let expireDate = expiredDate,
//              let qty = qtyTextField.text,
//              let notificationTime = notificationTimeTextField.text
//        else {
//            print("empty data")
//            return
//        }
//        let foodCard = FoodCard(
//            cardId: UUID().uuidString,
//            name: name,
//            categoryId: selectedFoodCategory.id,
//            typeId: typeId,
//            iconName: iconName,
//            qty: Int(qty) ?? 0,
//            createDate: Date(),
//            expireDate: expireDate,
//            notificationTime: Int(notificationTime) ?? 0,
//            barCode: Int(barCode) ?? 0,
//            storageType: storageSegment.selectedSegmentIndex,
//            notes: noteTextField.text ?? "")
//        
//        print(foodCard)
//        
//        Task {
//            await firestoreManager.addFoodCard(foodCard) { result in
//                switch result {
//                case .success:
//                    print("Document successfully written!")
//                    resetData()
//                case .failure(let error):
//                    print("Error adding document: \(error)")
//                }
//                
//            }
//        }
    }
    
    private func addDefaultTypes() {
        Task {
            await firestoreManager.addDefaultTypes()
        }
    }
    
}
