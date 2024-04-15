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
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
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
            // 用id 找到 local type (因為大家的default值都一樣，食譜也只會有 default 的那些 type)
            let queryId = ingredient.typeId
            guard let foodType = FoodTypeData.share.queryFoodType(typeId: queryId) else {
                print("找不到 food type")
                return cell
            }
            ingredientString.append(foodType.typeName)
            ingredientString.append(" ")
            cell.ingredientLabel.text = "所需食材: \(ingredientString)"
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let recipe = recipes[indexPath.row]
        performSegue(withIdentifier: "showRecipeDetailVC", sender: recipe)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let detailVC = segue.destination as? RecipeDetailViewController,
           let recipe = sender as? Recipe {
            detailVC.recipe = recipe
        }
    }
}
