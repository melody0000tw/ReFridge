//
//  AddFoodCardViewController.swift
//  ReFridge
//
//  Created by Melody Lee on 2024/4/20.
//

import UIKit
import VisionKit
import Vision

enum FoodCardMode {
    case adding
    case editing
    case editingBatch
}

class AddFoodCardViewController: UIViewController {
    private let firestoreManager = FirestoreManager.shared
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBAction func deleteByThrown(_ sender: Any) {
        changeScore(deleteWay: .thrown)
        deleteData()
    }
    @IBAction func deleteByFinished(_ sender: Any) {
        changeScore(deleteWay: .consumed)
        deleteData()
    }
    
    let typeVC = FoodTypeViewController()
    let saveBtn = UIBarButtonItem()
    let closeBtn = UIBarButtonItem()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setupTypeView()
        setupNavigationView()
        self.tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super .viewWillDisappear(animated)
        self.tabBarController?.tabBar.isHidden = false
    }
    
    var foodCard = FoodCard()
    var mode = FoodCardMode.adding
    var onChangeFoodCard: ((FoodCard) -> Void)?
    
    private func setupTypeView() {
        addChild(typeVC)
        typeVC.onSelectFoodType = { [self] foodType in
            print("card vc knows the selected foodtype: \(foodType)")
            // 選擇完 foodType 後
            foodCard.categoryId = foodType.categoryId
            foodCard.typeId = foodType.typeId
            foodCard.name = foodType.typeName
            foodCard.iconName = foodType.typeIcon
            updateCardInfo()
        }
    }
    
    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.RF_registerCellWithNib(identifier: CardTypeCell.reuseIdentifier, bundle: nil)
        tableView.RF_registerCellWithNib(identifier: CardInfoCell.reuseIdentifier, bundle: nil)
    }
    
    private func setupNavigationView() {
        saveBtn.tintColor = .C2
        saveBtn.image = UIImage(systemName: "checkmark")
        saveBtn.target = self
        saveBtn.action = #selector(saveData)
        navigationItem.rightBarButtonItem = saveBtn
        closeBtn.tintColor = .C2
        closeBtn.image = UIImage(systemName: "xmark")
        closeBtn.target = self
        closeBtn.action = #selector(closePage)
        navigationItem.backBarButtonItem?.isHidden = true
        navigationItem.leftBarButtonItem = closeBtn
    }
    
    private func updateCardInfo() {
        guard let typeCell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? CardTypeCell,
            let infoCell = tableView.cellForRow(at: IndexPath(row: 1, section: 0)) as? CardInfoCell
        else {
            return
        }
        typeCell.nameLabel.text = foodCard.name
        infoCell.iconImage.image = UIImage(named: foodCard.iconName)
        infoCell.barcodeTextField.text = foodCard.barCode
    }
    
    // MARK: - Data
    @objc func saveData() {
        print("didTapped save data")
        switch mode {
        case .adding:
            saveFoodCard()
        case .editing:
            saveFoodCard()
        case .editingBatch:
            guard let onChangeFoodCard = onChangeFoodCard else {
                print("did not set closure")
                return
            }
            
            onChangeFoodCard(foodCard)
            self.navigationController?.popViewController(animated: true)
            
        }
    }
    
    @objc func closePage() {
        self.navigationController?.popViewController(animated: true)
    }
    
    // edit or adding
    private func saveFoodCard() {
        foodCard.cardId = foodCard.cardId == "" ? UUID().uuidString : foodCard.cardId
        
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
    
    private func changeScore(deleteWay: DeleteWay) {
        let way = deleteWay.rawValue
        Task {
            await firestoreManager.changeScores(deleteWay: way) { result in
                switch result {
                case .success(let newScore):
                    print("successfully change score of \(way) to \(String(describing: newScore))")
                case .failure(let error):
                    print("Error adding document: \(error)")
                }
            }
        }
    }
}

extension AddFoodCardViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            if let cell = tableView.dequeueReusableCell(withIdentifier: CardTypeCell.reuseIdentifier, for: indexPath) as? CardTypeCell {
                cell.delegate = self
                typeVC.view.frame = cell.typeContainerView.bounds
                cell.typeContainerView.addSubview(typeVC.view)
                cell.nameLabel.text = foodCard.name == "" ? "請選取食物種類" : foodCard.name
                return cell
            }
        }
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: CardInfoCell.reuseIdentifier, for: indexPath) as? CardInfoCell {
            cell.delegate = self
            cell.foodCard = foodCard
            cell.setupData()
            return cell
        }
        return UITableViewCell()
    }
}

// MARK: - CardTypeCellDelegate, CardInfoCellDelegate
extension AddFoodCardViewController: CardTypeCellDelegate, CardInfoCellDelegate {
    func didTappedBarcodeBtn() {
        let documentCameraViewController = VNDocumentCameraViewController()
        documentCameraViewController.delegate = self
        present(documentCameraViewController, animated: true)
        
        print("============ vc 召喚 bar code")
    }
    
    func didChangeCardInfo(foodCard: FoodCard) {
        self.foodCard.qty = foodCard.qty
        self.foodCard.expireDate = foodCard.expireDate
        self.foodCard.barCode = foodCard.barCode
        self.foodCard.storageType = foodCard.storageType
        self.foodCard.notes = foodCard.notes
    }
    
    func didToggleTypeView() {
        print("didToggle")
    }
}

// MARK: - BarCode
extension AddFoodCardViewController: VNDocumentCameraViewControllerDelegate {
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
                        self.updateCardInfo()
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



