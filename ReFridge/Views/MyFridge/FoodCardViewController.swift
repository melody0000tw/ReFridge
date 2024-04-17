//
//  FoodCardViewController.swift
//  ReFridge
//
//  Created by Melody Lee on 2024/4/11.
//

import UIKit
import SnapKit
import IQKeyboardManagerSwift
import VisionKit
import Vision

class FoodCardViewController: UIViewController {
    let formatter = FormatterManager.share.formatter
    private let firestoreManager = FirestoreManager.shared
    
    var foodCard = FoodCard()
    var isAddingMode = false
    var onChangeFoodCard: ((FoodCard) -> Void)?
    
    let datePicker = UIDatePicker()
    
    @IBAction func scanBarCode(_ sender: Any) {
        let documentCameraViewController = VNDocumentCameraViewController()
        documentCameraViewController.delegate = self
        present(documentCameraViewController, animated: true)
    }
    
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
    
    @IBAction func didTappedDelete(_ sender: Any) {
       deleteData()
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
                // 選擇完 foodType 後
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
        datePicker.preferredDatePickerStyle = .inline
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
        if isAddingMode {
            nameLabel.text = "請選取食物種類"
            imageView.image = UIImage(named: foodCard.iconName)
            barcodeTextField.text = nil
            expireTimeTextField.text = nil
            qtyTextField.text = nil
            notificationTimeTextField.text = nil
            noteTextField.text = nil
            storageSegment.selectedSegmentIndex = 0
        } else {
            nameLabel.text = foodCard.name
            imageView.image = UIImage(named: foodCard.iconName)
            barcodeTextField.text = foodCard.barCode == "" ? nil : foodCard.barCode
            expireTimeTextField.text = formatter.string(from: foodCard.expireDate)
            qtyTextField.text = String(foodCard.qty)
            notificationTimeTextField.text = foodCard.notificationTime == 0 ? nil : String(foodCard.notificationTime)
            noteTextField.text = foodCard.notes
            storageSegment.selectedSegmentIndex = foodCard.storageType
        }
    }
    
    // add & edit
    private func saveData() {
        print("save data")
        
        if isAddingMode, foodCard.name.isEmpty {
            print("Adding mode can not be empty name!")
            return
        }
        
        guard let qty = qtyTextField.text,
            let barCode = barcodeTextField.text,
            let notificationTime = notificationTimeTextField.text
        else {
           print("empty data")
           return
        }
        foodCard.cardId = foodCard.cardId == "" ? UUID().uuidString : foodCard.cardId
        foodCard.qty = Int(qty) ?? 1
        foodCard.barCode = barCode
        foodCard.notificationTime = Int(notificationTime) ?? 0
        foodCard.storageType = storageSegment.selectedSegmentIndex
        foodCard.notes = noteTextField.text ?? ""

        if let onChangeFoodCard = onChangeFoodCard {
            onChangeFoodCard(foodCard)
            self.navigationController?.popViewController(animated: true)
            return
        } else {
            
        }
        
        Task {
            await firestoreManager.saveFoodCard(foodCard) { result in
                switch result {
                case .success:
                    print("Document successfully written!")
                    DispatchQueue.main.async {
                        self.navigationController?.popViewController(animated: true)
                    }
                case .failure(let error):
                    print("Error adding document: \(error)")
                }
            }
        }
    }
    
    private func deleteData() {
        if foodCard.cardId != "" {
            Task {
                await firestoreManager.deleteFoodCard( foodCard.cardId) { result in
                    switch result {
                    case .success:
                        print("Document successfully delete!")
                        DispatchQueue.main.async {
                            self.navigationController?.popViewController(animated: true)
                        }
                    case .failure(let error):
                        print("Error adding document: \(error)")
                    }
                }
            }
        }
    }
    
    // TODO: 是否刪除
    private func addDefaultTypes() {
        Task {
            await firestoreManager.addDefaultTypes()
        }
    }
    
}

// MARK: - BarCode
extension FoodCardViewController: VNDocumentCameraViewControllerDelegate {
    func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFinishWith scan: VNDocumentCameraScan) {
            let image = scan.imageOfPage(at: scan.pageCount - 1)
            print(image)
            processImage(image: image)
            dismiss(animated: true, completion: nil)
        }
    
    func processImage(image: UIImage) {
            guard let cgImage = image.cgImage else {
                print("Failed to get cgimage from input image")
                return
            }
            let handler = VNImageRequestHandler(cgImage: cgImage)
            let request = VNDetectBarcodesRequest { request, error in
                if let observation = request.results?.first as? VNBarcodeObservation,
                   observation.symbology == .ean13 {
                    guard let barcode = observation.payloadStringValue else {
                        return
                    }
                    print("get barcode: \(barcode)")
                    self.foodCard.barCode = barcode
                    DispatchQueue.main.async {
                        self.barcodeTextField.text = barcode
                    }
                } else {
                    print(error.debugDescription)
                }
            }
            do {
                try handler.perform([request])
            } catch {
                print(error)
            }
    }
}
