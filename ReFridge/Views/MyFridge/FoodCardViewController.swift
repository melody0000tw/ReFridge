//
//  FoodCardViewController.swift
//  ReFridge
//
//  Created by Melody Lee on 2024/4/11.
//

import UIKit
import SnapKit

class FoodCardViewController: UIViewController {
    let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }()
    
    
    private let firestoreManager = FirestoreManager.shared
    private var data = FoodTypeData.share.data
    private var selectedFoodCategory = FoodTypeData.share.data[0]
    private var selectedFoodType: FoodType? {
        didSet {
            if let selectedFoodType = selectedFoodType {
                nameLabel.text = selectedFoodType.name
                imageView.image = UIImage(named: selectedFoodType.iconName)
            }
        }
    }
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
    @IBAction func didTappedSave(_ sender: UIButton) {
        saveData()
    }
    @IBAction func didTappedDelete(_ sender: UIButton) {
    }
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        setupDatePicker()
    }
    
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
    
    private func saveData() {
        print("save data")
        guard let name = nameLabel.text,
              let typeId = selectedFoodType?.id,
              let iconName = selectedFoodType?.iconName,
              let barCode = barcodeTextField.text,
              let expireDate = expiredDate,
              let qty = qtyTextField.text,
              let notificationTime = notificationTimeTextField.text
        else {
            print("empty data")
            return
        }
        let foodCard = FoodCard(
            name: name,
            categoryId: selectedFoodCategory.id,
            typeId: typeId,
            iconName: iconName,
            qty: Int(qty) ?? 0,
            createDate: Date().timeIntervalSince1970,
            expireDate: expireDate.timeIntervalSince1970,
            notificationTime: Int(notificationTime) ?? 0,
            barCode: Int(barCode) ?? 0,
            storageType: storageSegment.selectedSegmentIndex,
            notes: "notenote")
        
        print(foodCard)
        
        Task {
            await firestoreManager.addFoodCard(foodCard) { result in
                switch result {
                case .success:
                    print("Document successfully written!")
                case .failure(let error):
                    print("Error adding document: \(error)")
                }
                
            }
        }
    }
}

extension FoodCardViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return selectedFoodCategory.foodTypes.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: FoodTypeCell.self), for: indexPath) as? FoodTypeCell
        else {
            return UICollectionViewCell()
        }
        let foodType = selectedFoodCategory.foodTypes[indexPath.item]
        cell.iconImage.image = UIImage(named: foodType.iconName)
        cell.titleLabel.text = foodType.name
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("indexPath.item = \(indexPath.item)")
        let foodType = selectedFoodCategory.foodTypes[indexPath.item]
        selectedFoodType = foodType
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: String(describing: FoodCategoryHeaderView.self), for: indexPath) as? FoodCategoryHeaderView
        else {
            return UICollectionReusableView()
        }
        headerView.onChangeCategory = { id in
            self.selectedFoodCategory = self.data[id]
            DispatchQueue.main.async {
                collectionView.reloadData()
            }
        }
        return headerView
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 60)
    }
}
