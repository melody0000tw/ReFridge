//
//  RecipeDetailViewController.swift
//  ReFridge
//
//  Created by Melody Lee on 2024/4/13.
//

import UIKit

class RecipeDetailViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()

    }
    
    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
    }

}

extension RecipeDetailViewController: UITableViewDataSource, UITableViewDelegate {
    
}
