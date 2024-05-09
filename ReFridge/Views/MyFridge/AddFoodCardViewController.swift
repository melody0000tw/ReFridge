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

class AddFoodCardViewController: BaseViewController {
    private let firestoreManager = FirestoreManager.shared
    
    @IBOutlet weak var btnViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var buttonsView: UIView!
    @IBOutlet weak var deleteByThrownBtn: UIButton!
    @IBOutlet weak var deleteByConsumedBtn: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    let typeVC = FoodTypeViewController()
    let saveBtn = UIBarButtonItem()
    let closeBtn = UIBarButtonItem()
    
    var foodCard = FoodCard()
    var mode = FoodCardMode.adding
    var typeViewIsOpen = true
    var onChangeFoodCard: ((FoodCard) -> Void)? // for editingBatch
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setupTypeView()
        setupNavigationView()
        setupDeleteBtns()
        toggleBtnView()
        self.tabBarController?.tabBar.isHidden = true
        if mode == .editing {
            typeViewIsOpen = false
            typeVC.mode = .editing
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super .viewWillDisappear(animated)
        self.tabBarController?.tabBar.isHidden = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if mode == .editing {
            typeVC.setupInitialFoodType(typeId: foodCard.typeId)
        }
    }
    
    // MARK: - Setups
    private func setupTypeView() {
        addChild(typeVC)
        typeVC.onSelectFoodType = { [self] foodType in
            foodCard.categoryId = foodType.categoryId
            foodCard.typeId = foodType.typeId
            foodCard.name = foodType.typeName
            foodCard.iconName = foodType.typeIcon
            updateCardInfoCell()
            typeViewIsOpen = !typeViewIsOpen
            tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
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
    
    private func setupDeleteBtns() {
        deleteByThrownBtn.setTitleColor(.lightGray, for: .disabled)
        deleteByThrownBtn.addTarget(self, action: #selector(didTappedDelete(sender:)), for: .touchUpInside)
        deleteByConsumedBtn.setTitleColor(.lightGray, for: .disabled)
        deleteByConsumedBtn.addTarget(self, action: #selector(didTappedDelete(sender:)), for: .touchUpInside)
    }
    
    private func toggleBtnView() {
        btnViewHeightConstraint.constant = 0
        buttonsView.isHidden = true
        if mode == .editing {
            btnViewHeightConstraint.constant = 60
            buttonsView.isHidden = false
        }
    }
    
    private func updateCardInfoCell() {
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
            view.endEditing(true)
            onChangeFoodCard(foodCard)
            self.navigationController?.popViewController(animated: true)
            
        }
    }
    
    @objc func closePage() {
        self.navigationController?.popViewController(animated: true)
    }
    
    // edit or adding
    private func saveFoodCard() {
        view.endEditing(true)
        guard foodCard.name != "" else {
            typeViewIsOpen = true
            tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
            guard let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? CardTypeCell else {
                return
            }
            cell.nameLabel.text = "尚未選取食物種類"
            cell.nameLabel.textColor = .red
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.typeVC.selectTypeBtn.clickBounce()
            }
            return
        }
        
        foodCard.cardId = foodCard.cardId == "" ? UUID().uuidString : foodCard.cardId
        showLoadingIndicator()
        Task {
            await firestoreManager.saveFoodCard(foodCard) { result in
                switch result {
                case .success:
                    print("Document successfully written!")
                    DispatchQueue.main.async {
                        self.removeLoadingIndicator()
                        self.navigationController?.popViewController(animated: true)
                    }
                case .failure(let error):
                    print("Error adding document: \(error)")
                    self.removeLoadingIndicator()
                    presentInternetAlert()
                }
            }
        }
    }
    
    @objc func didTappedDelete(sender: UIButton) {
        if foodCard.isRoutineItem {
            addToShoopingList()
        }
        
        if sender == deleteByConsumedBtn {
            changeScore(deleteWay: .consumed)
        } else if sender == deleteByThrownBtn {
            changeScore(deleteWay: .thrown)
        }
        
        deleteData()
    }
    
    private func deleteData() {
        if foodCard.cardId != "" {
            showLoadingIndicator()
            Task {
                await firestoreManager.deleteFoodCard( foodCard.cardId) { result in
                    switch result {
                    case .success:
                        print("Document successfully delete!")
                        presentAlert(title: "刪除成功", description: "已將小卡從冰箱中刪除", image: UIImage(systemName: "checkmark.circle"))
                        DispatchQueue.main.async {
                            self.removeLoadingIndicator()
                            self.navigationController?.popViewController(animated: true)
                        }
                    case .failure(let error):
                        print("Error adding document: \(error)")
                        presentInternetAlert()
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
    
    private func addToShoopingList() {
        var item = ListItem()
        item.checkStatus = 0
        item.itemId = UUID().uuidString
        item.categoryId = foodCard.categoryId
        item.name = foodCard.name
        item.qty = foodCard.qty
        item.mesureWord = foodCard.mesureWord
        item.typeId = foodCard.typeId
        item.isRoutineItem = foodCard.isRoutineItem
        
        Task {
            await firestoreManager.addListItem(item) { result in
                switch result {
                case .success:
                    print("Document successfully written!")
                case .failure(let error):
                    print("Error adding list item: \(error)")
                }
            }
        }
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource
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
                cell.nameLabel.textColor = .darkGray
                cell.toggleTypeView(shouldOpen: typeViewIsOpen)
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
    }
    
    func didChangeCardInfo(foodCard: FoodCard) {
        self.foodCard.qty = foodCard.qty
        self.foodCard.mesureWord = foodCard.mesureWord
        self.foodCard.expireDate = foodCard.expireDate
        self.foodCard.barCode = foodCard.barCode
        self.foodCard.storageType = foodCard.storageType
        self.foodCard.isRoutineItem = foodCard.isRoutineItem
        self.foodCard.notes = foodCard.notes
    }
    
    func didToggleTypeView() {
        typeViewIsOpen = !typeViewIsOpen
        tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
    }
}

// MARK: - BarCode
extension AddFoodCardViewController: VNDocumentCameraViewControllerDelegate {
    func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFinishWith scan: VNDocumentCameraScan) {
            let image = scan.imageOfPage(at: scan.pageCount - 1)
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
                    self.foodCard.barCode = barcode
                    
                    DispatchQueue.main.async {
                        self.updateCardInfoCell()
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
