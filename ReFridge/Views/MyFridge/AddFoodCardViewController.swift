//
//  AddFoodCardViewController.swift
//  ReFridge
//
//  Created by Melody Lee on 2024/4/20.
//

import UIKit
import VisionKit
import Vision
import Combine

enum FoodCardMode {
    case adding
    case editing
    case editingBatch
}

class AddFoodCardViewController: BaseViewController {
    let viewModel = AddFoodCardViewModel()
    private var cancellables: Set<AnyCancellable> = []
    
    @IBOutlet weak var btnViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var buttonsView: UIView!
    @IBOutlet weak var deleteByThrownBtn: UIButton!
    @IBOutlet weak var deleteByConsumedBtn: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    let typeVC = FoodTypeViewController()
    let saveBtn = UIBarButtonItem()
    let closeBtn = UIBarButtonItem()
    
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
        bindViewModel()
        self.tabBarController?.tabBar.isHidden = true
        if mode == .editing {
            typeViewIsOpen = false
            typeVC.mode = .editing
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if mode == .editing {
            let foodCard = viewModel.foodCard
            typeVC.setupInitialFoodType(typeId: foodCard.typeId)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super .viewWillDisappear(animated)
        self.tabBarController?.tabBar.isHidden = false
    }
    
    // MARK: - Setups
    private func setupTypeView() {
        addChild(typeVC)
        typeVC.onSelectFoodType = { [self] foodType in
            viewModel.updateFoodCard(name: foodType.typeName, typeId: foodType.typeId, categoryId: foodType.categoryId, iconName: foodType.typeIcon)
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
        saveBtn.action = #selector(didTappedSaveBtn)
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
    
    private func bindViewModel() {
        viewModel.$foodCard
            .receive(on: RunLoop.main)
            .dropFirst()
            .sink { [weak self] foodCard in
                self?.updateCardTypeUI(with: foodCard)
            }
            .store(in: &cancellables)
    }
    
    private func updateCardTypeUI(with foodCard: FoodCard) {
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
    @objc func didTappedSaveBtn() {
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
            let foodCard = viewModel.foodCard
            onChangeFoodCard(foodCard)
            self.navigationController?.popViewController(animated: true)
            
        }
    }
    
    @objc func closePage() {
        self.navigationController?.popViewController(animated: true)
    }
    
    // edit or adding
    private func saveFoodCard() {
        viewModel.saveFoodCard { [self] result in
            DispatchQueue.main.async { [self] in
                switch result {
                case .success:
                    print("Document successfully written!")
                    removeLoadingIndicator()
                    navigationController?.popViewController(animated: true)
                case .failure(let error):
                    removeLoadingIndicator()
                    if error == .incompletedInfo {
                        presentIncompletionAlert()
                    } else {
                        presentInternetAlert()
                    }
                }
            }
        }
    }
    
    private func presentIncompletionAlert() {
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
    }
    
    @objc func didTappedDelete(sender: UIButton) {
        showLoadingIndicator()
        var deleteWay = DeleteWay.consumed
        if sender == deleteByConsumedBtn {
            deleteWay = .consumed
        } else if sender == deleteByThrownBtn {
            deleteWay = .thrown
        }
        
        viewModel.didTappedDeleteBtn(deleteWay: deleteWay) { result in
            DispatchQueue.main.async { [self] in
                switch result {
                case .success:
                    print("Document successfully delete!")
                    presentAlert(title: "刪除成功", description: "已將小卡從冰箱中刪除", image: UIImage(systemName: "checkmark.circle"))
                    self.removeLoadingIndicator()
                    self.navigationController?.popViewController(animated: true)
                case .failure(let error):
                    print("Error adding document: \(error)")
                    presentInternetAlert()
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
                
                let card = viewModel.foodCard
                cell.nameLabel.text = card.name == "" ? "請選取食物種類" : card.name
                cell.nameLabel.textColor = .darkGray
                cell.toggleTypeView(shouldOpen: typeViewIsOpen)
                return cell
            }
        }
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: CardInfoCell.reuseIdentifier, for: indexPath) as? CardInfoCell {
            cell.delegate = self
            let card = viewModel.foodCard
            cell.foodCard = card
            cell.setupData()
            return cell
        }
        return UITableViewCell()
    }
}

// MARK: - CardTypeCellDelegate, CardInfoCellDelegate
extension AddFoodCardViewController: CardTypeCellDelegate, CardInfoCellDelegate {
    func didTappedIconImg() {
        typeViewIsOpen = !typeViewIsOpen
        tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
    }
    
    func didTappedBarcodeBtn() {
        let documentCameraViewController = VNDocumentCameraViewController()
        documentCameraViewController.delegate = self
        present(documentCameraViewController, animated: true)
    }
    
    func didChangeCardInfo(foodCard: FoodCard) {
        viewModel.updateFoodCard(
            qty: foodCard.qty,
            mesureWord: foodCard.mesureWord,
            expireDate: foodCard.expireDate,
            isRoutineItem: foodCard.isRoutineItem,
            barCode: foodCard.barCode,
            storageType: foodCard.storageType,
            notes: foodCard.notes)
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
                    self.viewModel.updateFoodCard(barCode: barcode)
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
