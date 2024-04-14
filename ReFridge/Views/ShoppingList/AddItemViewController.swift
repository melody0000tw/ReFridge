//
//  AddItemViewController.swift
//  ReFridge
//
//  Created by Melody Lee on 2024/4/14.
//

import UIKit

class AddItemViewController: UIViewController {
    private let firestoreManager = FirestoreManager.shared
    private let formatter = FormatterManager.share.formatter
    var listItem = ListItem.share
    lazy var datePicker = UIDatePicker()
    
    @IBAction func save(_ sender: Any) {
        addData()
    }
    
    @IBOutlet weak var isRoutineButton: UIButton!
    @IBOutlet weak var qtyTextField: UITextField!
    @IBOutlet weak var iconImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var routineView: UIView!
    @IBOutlet weak var routineStartTimeTextField: UITextField!
    @IBOutlet weak var routinePeriodTextField: UITextField!
    @IBOutlet weak var foodTypeView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupFoodTypeVC()
        setupDatePicker()
        resetData()
    }
    
    // MARK: setups
    private func setupFoodTypeVC() {
        if let foodTypeVC = children.compactMap({ $0 as? FoodTypeViewController }).first {
            foodTypeVC.onSelectFoodType = { [self] foodType in
                print("list vc knows the selected foodtype: \(foodType)")
                // 選擇完 foodType 後
                listItem.typeId = foodType.typeId
                nameLabel.text = foodType.typeName
                iconImage.image = UIImage(named: foodType.typeIcon)
            }
        }
    }
    
    private func setupDatePicker() {
        datePicker.preferredDatePickerStyle = .wheels
        datePicker.datePickerMode = .date
        routineStartTimeTextField.inputView = datePicker
        
        // Toolbar
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneAction))
        toolbar.setItems([doneButton], animated: true)
        routineStartTimeTextField.inputAccessoryView = toolbar
    }
    
    @objc func doneAction() {
        listItem.routineStartTime = datePicker.date
        routineStartTimeTextField.text =  formatter.string(from: listItem.routineStartTime)
        routineStartTimeTextField.resignFirstResponder()
    }
    
    // MARK: - Data
    private func resetData() {
        DispatchQueue.main.async { [self] in
            nameLabel.text = "請選取食物種類"
            iconImage.image = UIImage(systemName: "fork.knife.circle")
            qtyTextField.text = String(listItem.qty)
            routinePeriodTextField.text = nil
            routineStartTimeTextField.text = nil
        }
    }
    
    private func addData() {
        guard listItem.typeId != 0,
              let qty = Int(qtyTextField.text ?? "1"),
              let routinePeriod = Int(routinePeriodTextField.text ?? "0")
        else {
            print("輸入有誤")
            return
        }
        
        listItem.routinePeriod = routinePeriod
        listItem.qty = qty
        print("準備添加item: \(listItem)")
        Task {
            await firestoreManager.addListItem(listItem) {
                result in
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
    

}
