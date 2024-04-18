//
//  RecipeDetailViewController.swift
//  ReFridge
//
//  Created by Melody Lee on 2024/4/13.
//

import UIKit
import SnapKit

class RecipeDetailViewController: UIViewController {
    private let firestoreManager = FirestoreManager.shared
    
    var recipe: Recipe?
    var ingredientStatus: IngredientStatus?
    var isLiked = false
    
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
    }
    
    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate
extension RecipeDetailViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        4
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 3:
            if let recipe = recipe {
                return recipe.steps.count
            }
            return 1
        default:
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let recipe = recipe else {
            return UITableViewCell()
        }
        
        switch indexPath.section {
        case 0:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: RecipeTitleCell.reuseIdentifier, for: indexPath) as? RecipeTitleCell else {
                return UITableViewCell()
            }
            
            cell.delegate = self
            cell.titleLabel.text = recipe.title
            cell.cookingTimeLabel.text = "\(String(recipe.cookingTime))分鐘"
            cell.servingLabel.text = "\(String(recipe.servings))人份"
            cell.caloriesLabel.text = "\(String(recipe.calories))大卡"
            cell.toggleLikeBtn(isLiked: isLiked)
            
            return cell
            
        case 1:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: RecipeDescriptionCell.reuseIdentifier, for: indexPath) as? RecipeDescriptionCell else {
                return UITableViewCell()
            }
            
            cell.descriptionLabel.text = recipe.description
            return cell
            
        case 2:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: RecipeIngredientCell.reuseIdentifier, for: indexPath) as? RecipeIngredientCell else {
                return UITableViewCell()
            }
            
            guard let ingredientStatus = ingredientStatus else { return cell }
            cell.ingredientStatus = ingredientStatus
            cell.setupCell()
            
            return cell
            
        default:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: RecipeStepCell.reuseIdentifier, for: indexPath) as? RecipeStepCell else {
                return UITableViewCell()
            }
            
            let step = recipe.steps[indexPath.row]
            cell.numberLabel.text = String(indexPath.row + 1)
            cell.stepTextLabel.text = step
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let sections = ["料理介紹", "食材", "料理步驟"]
        if section != 0 {
            let view = UIView()
            let label = UILabel()
            label.text = sections[section - 1]
            label.font = UIFont(name: "PingFangHK-Medium", size: 20)
            label.textColor = .darkGray
            view.addSubview(label)
            label.snp.makeConstraints { make in
                make.top.equalTo(view.snp.top)
                make.leading.equalTo(view.snp.leading).offset(16)
            }
            
            return view
        }
        return nil
    }
}

extension RecipeDetailViewController: RecipeTitleCellDelegate {
    func didTappedLikeBtn() {
        // 確認現在狀態
        isLiked = isLiked ? false : true
        guard let recipeTitleCell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? RecipeTitleCell else {
            print("cannot find the cell")
            return
        }
        recipeTitleCell.toggleLikeBtn(isLiked: isLiked)
        
        Task {
            guard let recipe = recipe else { return }
            switch isLiked {
            case true:
                await firestoreManager.addLikedRecipe(by: recipe.recipeId) { result in
                    switch result {
                    case .success:
                        print("成功加入收藏清單")
                    case .failure(let error):
                        print(error.localizedDescription)
                    }
                }
            case false:
                await firestoreManager.removeLikedRecipe(by: recipe.recipeId) { result in
                    switch result {
                    case .success:
                        print("成功刪除清單")
                    case .failure(let error):
                        print(error.localizedDescription)
                    }
                }
            }
        }
    }
    
    
}
