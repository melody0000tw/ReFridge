//
//  AddItemViewController.swift
//  ReFridge
//
//  Created by Melody Lee on 2024/4/14.
//

import UIKit
import Combine

class AddItemViewController: BaseViewController {
    var viewModel = AddItemViewModel()
    private var cancellables: Set<AnyCancellable> = []

    var typeViewIsOpen = true
    var mode = FoodCardMode.adding
    
    @IBOutlet weak var tableView: UITableView!
    let typeVC = FoodTypeViewController()
    let saveBtn = UIBarButtonItem()
    let closeBtn = UIBarButtonItem()
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setupTypeView()
        setupNavigationView()
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
            let typeId = viewModel.listItem.typeId
            typeVC.setupInitialFoodType(typeId: typeId)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super .viewWillDisappear(animated)
        self.tabBarController?.tabBar.isHidden = false
    }
    
    // MARK: - setups
    private func setupTypeView() {
        addChild(typeVC)
        typeVC.onSelectFoodType = { [self] foodType in
            viewModel.updateItem(name: foodType.typeName, typeId: foodType.typeId, categoryId: foodType.categoryId, iconName: foodType.typeIcon)
            if typeViewIsOpen {
                typeViewIsOpen = false
                tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
            }
        }
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
    
    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.RF_registerCellWithNib(identifier: CardTypeCell.reuseIdentifier, bundle: nil)
        tableView.RF_registerCellWithNib(identifier: ItemInfoCell.reuseIdentifier, bundle: nil)
    }
    
    // MARK: - Data
    private func bindViewModel() {
        viewModel.$listItem
            .receive(on: RunLoop.main)
            .dropFirst()
            .sink { [weak self] item in
                self?.updateCardInfoCell(with: item)
            }
            .store(in: &cancellables)
    }
    
    private func updateCardInfoCell(with item: ListItem) {
        guard let typeCell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? CardTypeCell,
            let infoCell = tableView.cellForRow(at: IndexPath(row: 1, section: 0)) as? ItemInfoCell
        else {
            return
        }
        typeCell.nameLabel.text = item.name
        infoCell.iconImage.image = UIImage(named: item.iconName)
        infoCell.qtyTextField.text = String(item.qty)
        infoCell.mesureWordTextField.text = item.mesureWord
        infoCell.noteTextField.text = item.notes == "" ? nil : item.notes
    }
    
    @objc func closePage() {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func didTappedSaveBtn() {
        let item = viewModel.listItem
        guard item.name != "" else {
            presentIncompletionAlert()
            return
        }
        
        view.endEditing(true)
        showLoadingIndicator()
        viewModel.saveItem { result in
            switch result {
            case .success:
                print("Document successfully written!")
                DispatchQueue.main.async {
                    self.removeLoadingIndicator()
                    self.navigationController?.popViewController(animated: true)
                }
            case .failure(let error):
                print("error: \(error)")
                self.removeLoadingIndicator()
                self.presentInternetAlert()
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
    }
    
}

// MARK: - UITableViewDataSource, UITableViewDelegate
extension AddItemViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            if let cell = tableView.dequeueReusableCell(withIdentifier: CardTypeCell.reuseIdentifier, for: indexPath) as? CardTypeCell {
                cell.delegate = self
                typeVC.view.frame = cell.typeContainerView.bounds
                cell.typeContainerView.addSubview(typeVC.view)
                
                let item = viewModel.listItem
                cell.nameLabel.text = item.name == "" ? "請選取食物種類" : item.name
                cell.nameLabel.textColor = .darkGray
                cell.toggleTypeView(shouldOpen: typeViewIsOpen)
                return cell
            }
        }
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: ItemInfoCell.reuseIdentifier, for: indexPath) as? ItemInfoCell {
            cell.delegate = self
            let item = viewModel.listItem
            cell.iconImage.image = item.name == "" ? UIImage(systemName: "fork.knife.circle") : UIImage(named: item.iconName)
            cell.qtyTextField.text = String(item.qty)
            cell.mesureWordTextField.text = item.mesureWord
            cell.noteTextField.text = item.notes == "" ? nil : item.notes
            return cell
        }
        return UITableViewCell()
    }
    
}

// MARK: - CardTypeCellDelegate, ItemInfoCellDelegate
extension  AddItemViewController: CardTypeCellDelegate, ItemInfoCellDelegate {
    func didTappedIconImg() {
        typeViewIsOpen = !typeViewIsOpen
        tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
    }
    
    func didToggleTypeView() {
        typeViewIsOpen = !typeViewIsOpen
        tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
    }
    
    func didChangeQty(qty: Int, mesureWord: String, notes: String) {
        viewModel.updateItem(qty: qty, mesureWord: mesureWord, notes: notes)
    }
}
