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
                self.tableView.reloadData()
            }
        }
    }
    
    @IBOutlet weak var tableView: UITableView!
    @IBAction func addToFridge(_ sender: Any) {
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
        
        return cell
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
        tableView.deleteRows(at: [indexPath], with: .automatic)
        
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
