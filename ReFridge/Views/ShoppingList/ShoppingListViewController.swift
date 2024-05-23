//
//  ShoppingListViewController.swift
//  ReFridge
//
//  Created by Melody Lee on 2024/4/14.
//

import UIKit

class ShoppingListViewController: BaseViewController {
    var viewModel = ShoppingListViewModel()
    
    @IBOutlet weak var tableView: UITableView!
    @IBAction func addToFridge(_ sender: UIButton) {
        sender.clickBounce()
        viewModel.addAllCheckedItemToFridge {
            self.fetchList()
            self.presentAlert(title: "加入成功", description: "已將完成項目加入我的冰箱", image: UIImage(systemName: "checkmark.circle"))
        }
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
        tableView.separatorStyle = .none
        tableView.RF_registerCellWithNib(identifier: ShoppingListCell.reuseIdentifier, bundle: nil)
        refreshControl.addTarget(self, action: #selector(fetchList), for: .valueChanged)
        tableView.refreshControl = refreshControl
        tableView.refreshControl?.tintColor = .clear
    }
    
    // MARK: - Datas
    @objc private func fetchList() {
        refreshControl.startRefresh()
        showLoadingIndicator()
        viewModel.fetchList { [self] result in
            switch result {
            case .success(let list):
                tableView.reloadData()
                tableView.isHidden = false
                emptyDataManager.toggleLabel(shouldShow: (list.isEmpty))
            case .failure(let error):
                presentInternetAlert()
                tableView.isHidden = false
            }
            removeLoadingIndicator()
            refreshControl.endRefresh()
        }
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate
extension ShoppingListViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.list.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ShoppingListCell.reuseIdentifier, for: indexPath) as? ShoppingListCell
        else {
            return UITableViewCell()
        }
        cell.delegate = self
        let item = viewModel.list[indexPath.row]
        cell.itemLabel.text = item.name
        cell.qtyLabel.text = "\(String(item.qty))\(item.mesureWord)"
        cell.toggleStyle(checkStatus: item.checkStatus)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? ShoppingListCell else {
            return
        }
        cell.clickBounce()
        var item = viewModel.list[indexPath.row]
        item.checkStatus = item.checkStatus == 0 ? 1 : 0
        viewModel.list[indexPath.row] = item
        
        cell.toggleStyle(checkStatus: item.checkStatus)
        viewModel.updateItem(item: item)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.alpha = 0
        
        UIView.animate(withDuration: 0.5, delay: 0.05 * Double(indexPath.row)) {
            cell.alpha = 1
        }
    }
}

// MARK: - ListCellDelegate
extension ShoppingListViewController: ShoppingListCellDelegate {
    func edit(cell: UITableViewCell) {
        guard let indexPath = tableView.indexPath(for: cell) else {
            return
        }
        let itemToEdit = viewModel.list[indexPath.row]
        guard let addItemVC = storyboard?.instantiateViewController(withIdentifier: "AddItemViewController") as? AddItemViewController else {
            print("can not get addItemVC")
            return
        }
        let viewModel = AddItemViewModel(listItem: itemToEdit)
        addItemVC.viewModel = viewModel
        addItemVC.mode = .editing
        navigationController?.pushViewController(addItemVC, animated: true)
        
    }
    
    func delete(cell: UITableViewCell) {
        guard let indexPath = tableView.indexPath(for: cell) else {
            return
        }
        let itemToDelete = viewModel.list.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .automatic)
        emptyDataManager.toggleLabel(shouldShow: viewModel.list.isEmpty)
        viewModel.deleteItem(item: itemToDelete)
    }
}
