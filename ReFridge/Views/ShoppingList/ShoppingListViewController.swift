//
//  ShoppingListViewController.swift
//  ReFridge
//
//  Created by Melody Lee on 2024/4/14.
//

import UIKit

class ShoppingListViewController: UIViewController {
    private let firestoreManager = FirestoreManager.shared
    var list = [ListItem]() {
        didSet {
            DispatchQueue.main.async {
                print("new list count: \(self.list.count)")
                self.tableView.reloadData()
            }
        }
    }
    
    @IBOutlet weak var tableView: UITableView!
    @IBAction func addToFridge(_ sender: Any) {
        addCheckItemToFridge()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchList()
    }
    
    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    private func fetchList() {
        Task {
            await firestoreManager.fetchListItems { result in
                switch result {
                case .success(let list):
                    print("did get list")
                    self.list = list
                case .failure(let error):
                    print("error: \(error)")
                }
            }
        }
    }
    
    private func addCheckItemToFridge() {
        let dispatchGroup = DispatchGroup()
        // filter checkItems
        let checkItems = list.filter { item in
            item.checkStatus == 1
        }
        // create card
        for item in checkItems {
            dispatchGroup.enter()
            Task {
                await firestoreManager.queryFoodType(typeId: item.typeId) { result in
                    switch result {
                    case .success(let foodType):
                        print("取得foodType 資料: \(foodType.typeName)")
                        createFoodCard(foodType: foodType, item: item, group: dispatchGroup)
                    case .failure(let error):
                        print("error: \(error)")
                    }
                }
            }
        }
        dispatchGroup.notify(queue: .main) { [self] in
            fetchList()
        }
    }
    
    private func createFoodCard(foodType: FoodType, item: ListItem, group: DispatchGroup) {
        // make food card
        let foodCard = FoodCard(
            cardId: UUID().uuidString,
            name: foodType.typeName,
            categoryId: foodType.categoryId,
            typeId: foodType.typeId,
            iconName: foodType.typeIcon,
            qty: item.qty,
            createDate: Date(),
            expireDate: Date().createExpiredDate(afterDays: 7) ?? Date(),
            notificationTime: 3,
            barCode: "",
            storageType: 2, // default 值常溫？
            notes: "")
        
        // post card
        Task {
            await firestoreManager.saveFoodCard(foodCard) { result in
                switch result {
                case .success:
                    print("成功新增小卡 \(foodCard.name)")
                    deleteItem(item: item, group: group)
                case .failure(let error):
                    print("Error adding document: \(error)")
                }
            }
        }
    }
    
    private func deleteItem(item: ListItem, group: DispatchGroup) {
        Task {
            await firestoreManager.deleteListItem(by: item.itemId) { result in
                switch result {
                case .success(let itemId):
                    print("成功刪除itemId: \(String(describing: itemId))")
                case .failure(let error):
                    print("error: \(error)")
                }
            }
            group.leave()
        }
    }
        
}

extension ShoppingListViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        list.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ListCell.reuseIdentifier, for: indexPath) as? ListCell
        else {
            return UITableViewCell()
        }
        
        cell.delegate = self
        let item = list[indexPath.row]
        guard let foodType = FoodTypeData.share.queryFoodType(typeId: item.typeId) else {
            return cell
        }
        cell.itemLabel.text = foodType.typeName
        cell.toggleStyle(checkStatus: item.checkStatus)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let originalStatus = list[indexPath.row].checkStatus
        list[indexPath.row].checkStatus = originalStatus == 0 ? 1 : 0 // tableView.reloadData
        let newItem = list[indexPath.row]
        Task {
            await firestoreManager.updateCheckStatus(newItem: newItem) { result in
                switch result {
                case .success:
                    print("did update checkStatus for \(newItem.itemId)")
                case .failure(let error):
                    print("error: \(error)")
                }
            }
        }
    }
}

// MARK: - ListCellDelegate
extension ShoppingListViewController: ListCellDelegate {
    func delete(cell: UITableViewCell) {
        guard let indexPath = tableView.indexPath(for: cell) else {
            return
        }
        // 要刪除的 item
        let itemToDelete = list.remove(at: indexPath.row)
        
        // 將刪除更新到資料庫
        Task {
            await firestoreManager.deleteListItem(by: itemToDelete.itemId) { result in
                switch result {
                case .success:
                    print("did delete item")
                case .failure(let error):
                    print("error: \(error)")
                }
            }
        }
        
    }
}
