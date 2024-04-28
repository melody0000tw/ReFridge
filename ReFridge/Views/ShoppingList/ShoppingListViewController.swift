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
            DispatchQueue.main.async { [self] in
                print("new list count: \(self.list.count)")
                tableView.isHidden = false
                tableView.reloadData()
                emptyDataManager.toggleLabel(shouldShow: (self.list.count == 0))
            }
        }
    }
    
    @IBOutlet weak var tableView: UITableView!
    @IBAction func addToFridge(_ sender: UIButton) {
        sender.clickBounce()
        addCheckItemToFridge()
    }
    
    lazy var emptyDataManager = EmptyDataManager(view: self.view, emptyMessage: "尚未建立購物清單")
    
    private lazy var refreshControl = RefresherManager()
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchList()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        tableView.isHidden = true
    }
    
    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.RF_registerCellWithNib(identifier: ShoppingListCell.reuseIdentifier, bundle: nil)
        refreshControl.addTarget(self, action: #selector(fetchList), for: .valueChanged)
        tableView.refreshControl = refreshControl
        tableView.refreshControl?.tintColor = .clear
    }
    
    // MARK: - Datas
    @objc private func fetchList() {
        refreshControl.startRefresh()
        Task {
            await firestoreManager.fetchListItems { result in
                switch result {
                case .success(let list):
                    print("did get list")
                    self.list = list
                    refreshControl.endRefresh()
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
            
            let foodCard = FoodCard(
                cardId: UUID().uuidString,
                name: item.name,
                categoryId: item.categoryId,
                typeId: item.typeId,
                iconName: item.iconName,
                qty: item.qty,
                mesureWord: item.mesureWord,
                createDate: Date(),
                expireDate: Date().createExpiredDate(afterDays: 7) ?? Date(),
                isRoutineItem: item.isRoutineItem,
                barCode: "",
                storageType: 0,
                notes: "")
            
            // post card
            Task {
                await firestoreManager.saveFoodCard(foodCard) { result in
                    switch result {
                    case .success:
                        print("成功新增小卡 \(foodCard.name)")
                        presentAlert(title: "加入成功", description: "已將完成項目加入我的冰箱", image: UIImage(systemName: "checkmark.circle"))
                        // delete card
                        deleteItem(item: item, group: dispatchGroup)
                    case .failure(let error):
                        print("Error adding document: \(error)")
                    }
                }
            }
        }
        dispatchGroup.notify(queue: .main) { [self] in
            fetchList()
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

// MARK: - UITableViewDataSource, UITableViewDelegate
extension ShoppingListViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        list.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ShoppingListCell.reuseIdentifier, for: indexPath) as? ShoppingListCell
        else {
            return UITableViewCell()
        }
        cell.delegate = self
        let item = list[indexPath.row]
        cell.itemLabel.text = item.name
        cell.qtyLabel.text = "\(String(item.qty))\(item.mesureWord)"
        cell.toggleStyle(checkStatus: item.checkStatus)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        cell?.clickBounce(action: { [self] in
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
        })
    }
    
//    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
//        cell.transform = CGAffineTransform(translationX: 0, y: cell.contentView.frame.height)
//        
//        UIView.animate(withDuration: 0.5, delay: 0.05 * Double(indexPath.row)) {
//            cell.transform = CGAffineTransform(translationX: cell.contentView.frame.width, y: cell.contentView.frame.height)
//        }
//    }
}

// MARK: - ListCellDelegate
extension ShoppingListViewController: ShoppingListCellDelegate {
    func edit(cell: UITableViewCell) {
        guard let indexPath = tableView.indexPath(for: cell) else {
            return
        }
        let itemToEdit = list[indexPath.row]
        
        guard let addItemVC = storyboard?.instantiateViewController(withIdentifier: "AddItemViewController") as? AddItemViewController else {
            print("can not get addItemVC")
            return
        }
        
        addItemVC.listItem = itemToEdit
        navigationController?.pushViewController(addItemVC, animated: true)
        
    }
    
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
