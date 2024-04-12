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
    
    // 要移到View中
    private var allFoodTypes = [FoodType]()
    private var selectedTypes = [FoodType]() {
        didSet {
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        }
    }
//    private var data = FoodTypeData.share.data
    
    
//    private var selectedFoodCategory = FoodTypeData.share.data[0]
//    private var selectedFoodType: FoodType? {
//        didSet {
//            if let selectedFoodType = selectedFoodType {
//                nameLabel.text = selectedFoodType.name
//                imageView.image = UIImage(named: selectedFoodType.iconName)
//            }
//        }
//    }
    private var expiredDate: Date? {
        didSet {
            if let expiredDate = expiredDate {
                expireTimeTextField.text = formatter.string(from: expiredDate)
            }
        }
    }
    
    let datePicker = UIDatePicker()
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
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
        setupCollectionView()
        setupDatePicker()
        setupInitialData()
        fetchFoodTypes()
    }
    
    // MARK: Setups
    private func setupCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.RF_registerCellWithNib(identifier: String(describing: FoodTypeCell.self), bundle: nil)
        collectionView.register(FoodCategoryHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: String(describing: FoodCategoryHeaderView.self))
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 100, height: 120)
        layout.minimumLineSpacing = 16
        layout.minimumInteritemSpacing = 8
        layout.sectionInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        layout.sectionHeadersPinToVisibleBounds = true
        collectionView.collectionViewLayout = layout
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
    // collectionView
    private func fetchFoodTypes() {
        Task {
            await firestoreManager.fetchFoodType { result in
                switch result {
                case .success(let foodTypes):
                    allFoodTypes = foodTypes
                    selectedTypes = foodTypes
                    print("已取得所有 foodTypes")
                case .failure(let error):
                    print(error)
                }
            }
        }
    }
    
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

extension FoodCardViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        return selectedFoodCategory.foodTypes.count
        selectedTypes.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: FoodTypeCell.self), for: indexPath) as? FoodTypeCell
        else {
            return UICollectionViewCell()
        }
//        let foodType = selectedFoodCategory.foodTypes[indexPath.item]
//        cell.iconImage.image = UIImage(named: foodType.iconName)
//        cell.titleLabel.text = foodType.name
        let foodType = selectedTypes[indexPath.item]
        cell.iconImage.image = UIImage(named: foodType.typeIcon)
        cell.titleLabel.text = foodType.typeName
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("indexPath.item = \(indexPath.item)")
//        let foodType = selectedFoodCategory.foodTypes[indexPath.item]
//        selectedFoodType = foodType
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: String(describing: FoodCategoryHeaderView.self), for: indexPath) as? FoodCategoryHeaderView
        else {
            return UICollectionReusableView()
        }
//        headerView.onChangeCategory = { id in
//            self.selectedFoodCategory = self.data[id]
//            DispatchQueue.main.async {
//                collectionView.reloadData()
//            }
//        }
        return headerView
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 60)
    }
}
