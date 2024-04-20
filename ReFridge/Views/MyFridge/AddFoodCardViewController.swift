//
//  AddFoodCardViewController.swift
//  ReFridge
//
//  Created by Melody Lee on 2024/4/20.
//

import UIKit

enum FoodCardMode {
    case adding
    case editing
    case editingBatch
}

class AddFoodCardViewController: UIViewController {
    private let firestoreManager = FirestoreManager.shared
    @IBOutlet weak var tableView: UITableView!
    
    let typeVC = FoodTypeViewController()
    let saveBtn = UIBarButtonItem()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setupTypeView()
        setupNavigationView()
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
    }
    
    private func updateCardInfo() {
        guard let typeCell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? CardTypeCell,
            let infoCell = tableView.cellForRow(at: IndexPath(row: 1, section: 0)) as? CardInfoCell
        else {
            return
        }
        typeCell.nameLabel.text = foodCard.name
        infoCell.iconImage.image = UIImage(named: foodCard.iconName)
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

extension AddFoodCardViewController: CardTypeCellDelegate, CardInfoCellDelegate {
    func didTappedBarcodeBtn() {
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
//        guard let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? CardTypeCell else {
//            return
//        }
//        tableView.reloadData()
    }
}


