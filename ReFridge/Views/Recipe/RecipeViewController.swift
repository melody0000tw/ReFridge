//
//  RecipeViewController.swift
//  ReFridge
//
//  Created by Melody Lee on 2024/4/13.
//

import UIKit

class RecipeViewController: UIViewController {
    private let firestoreManager = FirestoreManager.shared
    @IBOutlet weak var tableView: UITableView!
    
    var recipes: [Recipe] = [] {
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        fetchRecipes()
    }
    
    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    private func fetchRecipes() {
        Task {
            await firestoreManager.fetchRecipes { result in
                switch result {
                case .success(let recipes):
                    print("got recipes! \(recipes)")
                    self.recipes = recipes
                case .failure(let error):
                    print("error: \(error)")
                }
            }
        }
    }
    
    private func queryFoodType(typeId: Int) -> FoodType? {
        var queryFoodType: FoodType?
        Task {
            await firestoreManager.queryFoodType(typeId: typeId, completion: { result in
                switch result {
                case .success(let foodType):
                    print("vc got foodType! \(foodType)")
                    queryFoodType = foodType
                case .failure(let error):
                    print("error: \(error)")
                }
            })
        }
        return queryFoodType
    }
}

extension RecipeViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        recipes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: RecipeCell.self), for: indexPath) as? RecipeCell
        else {
            return UITableViewCell()
        }
        
        let recipe = recipes[indexPath.row]
        cell.titleLabel.text = recipe.title
        cell.cookingTimeLabel.text = "\(String(recipe.cookingTime))分鐘"
        
        var ingredientString = String()
        for ingredient in recipe.ingredients {
            // 用id 找到 local type (因為大家的default值都一樣，食譜也只會有 default值得)
            let queryId = ingredient.typeId
            let foodTypes = FoodTypeData.share.data
            let foodType = foodTypes.first { type in
                type.typeId == queryId
            }
            if let foodType = foodType {
                ingredientString.append(foodType.typeName)
                ingredientString.append(" ")
            }
            
            // 用id 看 foodCard
            // 比對是否有一樣的 foodCard
            // 顯示內容
            
//            ingredientString += ingredient.
        }
        cell.ingredientLabel.text = "所需食材: \(ingredientString)"
        return cell
    }
}
