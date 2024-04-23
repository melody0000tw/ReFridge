//
//  AddItemViewController.swift
//  ReFridge
//
//  Created by Melody Lee on 2024/4/14.
//

import UIKit

class AddItemViewController: UIViewController {
    private let firestoreManager = FirestoreManager.shared
    
    var listItem = ListItem()
    
    @IBOutlet weak var tableView: UITableView!
    
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
    
    // MARK: setups
    private func setupTypeView() {
        addChild(typeVC)
        typeVC.onSelectFoodType = { [self] foodType in
            print("card vc knows the selected foodtype: \(foodType)")
            // 選擇完 foodType 後
            listItem.typeId = foodType.typeId
            listItem.categoryId = foodType.categoryId
            listItem.name = foodType.typeName
            listItem.iconName = foodType.typeIcon
            updateCardInfoCell()
        }
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
    
    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.RF_registerCellWithNib(identifier: CardTypeCell.reuseIdentifier, bundle: nil)
        tableView.RF_registerCellWithNib(identifier: CardQtyCell.reuseIdentifier, bundle: nil)
    }
    

    // MARK: - Data
    
    private func updateCardInfoCell() {
        guard let typeCell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? CardTypeCell,
            let qtyCell = tableView.cellForRow(at: IndexPath(row: 1, section: 0)) as? CardQtyCell
        else {
            return
        }
        typeCell.nameLabel.text = listItem.name
        qtyCell.iconImage.image = UIImage(named: listItem.iconName)
        qtyCell.nameLabel.text = listItem.name
    }
    
    @objc func closePage() {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func saveData() {
        guard listItem.name != "" else {
            print("沒有選擇 type")
            return
        }
        
        view.endEditing(true)
        print(listItem)

        Task {
            await firestoreManager.addListItem(listItem) { result in
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
    
}

extension AddItemViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            if let cell = tableView.dequeueReusableCell(withIdentifier: CardTypeCell.reuseIdentifier, for: indexPath) as? CardTypeCell {
                typeVC.view.frame = cell.typeContainerView.bounds
                cell.typeContainerView.addSubview(typeVC.view)
                cell.nameLabel.text = listItem.name == "" ? "請選取食物種類" : listItem.name
                return cell
            }
        }
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: CardQtyCell.reuseIdentifier, for: indexPath) as? CardQtyCell {
            cell.delegate = self
            cell.iconImage.image = UIImage(named: listItem.iconName)
            cell.nameLabel.text = listItem.name == "" ? "請選取食物種類" : listItem.name
            cell.qtyTextField.text = listItem.qty == 1 ? "1" : String(listItem.qty)
            cell.mesureWordTextField.text = listItem.mesureWord
            return cell
        }
        return UITableViewCell()
    }
    
}

extension  AddItemViewController: CardQtyCellDelegate {
    func didChangeQty(qty: Int, mesureWord: String) {
        listItem.qty = qty
        listItem.mesureWord = mesureWord
    }
}
