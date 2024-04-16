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
    
    var ingredientStatus: IngredientStatus? {
        didSet {
            self.tableView.reloadData()
        }
    }
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let recipe = recipe {
            checkIngredientStatus(recipe: recipe)
        }
    }
    
    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
    }
    
    private func checkIngredientStatus(recipe: Recipe) {
        var allTypes = [FoodType]()
        var lackTypes = [FoodType]()
        var checkTypes = [FoodType]()
        
        let dispatchGroup = DispatchGroup() // 建立小組任務
        for ingredient in recipe.ingredients {
            dispatchGroup.enter() // 小組任務開始
            let typeId = ingredient.typeId
            
            // 找小卡有沒有，歸類到 lack or check
            Task {
                await firestoreManager.queryFoodCard(by: typeId, completion: { result in
                    switch result {
                    case .success(let foodCards):
                        if foodCards.count == 0 {
                            // 缺乏的食材，先用id找到type
                            let foodType = FoodTypeData.share.queryFoodType(typeId: typeId)
                            guard let foodType = foodType else {
                                print("找不到 foodtype")
                                return
                            }
                            print("把\(foodType.typeName)放到 lack")
                            lackTypes.append(foodType)
                            allTypes.append(foodType)
                        } else {
                            // 冰箱有的，用id找到type
                            let foodType = FoodTypeData.share.queryFoodType(typeId: typeId)
                            guard let foodType = foodType else {
                                print("找不到 foodtype")
                                return
                            }
                            print("把\(foodType.typeName)放到 check")
                            checkTypes.append(foodType)
                            allTypes.append(foodType)
                        }
                    case .failure(let error):
                        print("error: \(error)")
                    }
                })
                dispatchGroup.leave()
            }
        }
        dispatchGroup.notify(queue: .main) { [self] in
            ingredientStatus = IngredientStatus(
                recipeId: recipe.recipeId,
                allTypes: allTypes,
                checkTypes: checkTypes,
                lackTypes: lackTypes,
                fitPercentage: (Double(checkTypes.count) / Double(allTypes.count)).rounding(toDecimal: 2)
            )
        }
    }
}

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
            
            cell.titleLabel.text = recipe.title
            cell.cookingTimeLabel.text = "\(String(recipe.cookingTime))分鐘"
            cell.servingLabel.text = "\(String(recipe.servings))人份"
            cell.caloriesLabel.text = "\(String(recipe.calories))大卡"
            
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
