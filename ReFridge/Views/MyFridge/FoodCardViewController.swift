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
        if let foodTypeVC = children.compactMap({ $0 as? FoodTypeViewController }).first {
            foodTypeVC.onSelectFoodType = { [self] foodType in
                print("card vc knows the selected foodtype: \(foodType)")
                foodCard.categoryId = foodType.categoryId
                foodCard.typeId = foodType.typeId
                foodCard.name = foodType.typeName
                foodCard.iconName = foodType.typeIcon
                nameLabel.text = foodType.typeName
                imageView.image = UIImage(named: foodType.typeIcon)
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
        let expiredDate = datePicker.date
        foodCard.expireDate = expiredDate
        expireTimeTextField.text = formatter.string(from: expiredDate)
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

    private func saveData() {
        print(foodCard)
        print("save data")
        guard let qty = qtyTextField.text,
            let barCode = barcodeTextField.text,
            let notificationTime = notificationTimeTextField.text
        else {
           print("empty data")
           return
        }
        foodCard.cardId = foodCard.cardId == "" ? UUID().uuidString : foodCard.cardId
        foodCard.qty = Int(qty) ?? 1
        foodCard.barCode = Int(barCode) ?? 0
        foodCard.notificationTime = Int(notificationTime) ?? 0
        foodCard.storageType = storageSegment.selectedSegmentIndex
        foodCard.notes = noteTextField.text ?? ""
        print(foodCard)
        
        
        Task {
            await firestoreManager.addFoodCard(foodCard) { result in
                switch result {
                case .success:
                    print("Document successfully written!")
                    resetData()
                case .failure(let error):
                    print("Error adding document: \(error)")
                }

            }
        }
    }
    
    private func addDefaultTypes() {
        Task {
            await firestoreManager.addDefaultTypes()
        }
    }
    
}
