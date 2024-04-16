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
    
    var filterdRecipes: [Recipe] = []
    
    
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
                    filterRecipes(recipes: self.recipes) { filterdRecipes in
                        self.filterdRecipes = filterdRecipes
                        print("filterRecipe fetch 成功: \(self.filterdRecipes)")
                    }
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
    
    
    private func filterRecipes(recipes: [Recipe], completion: @escaping ([Recipe]) -> Void) {
        var filterdRecipes = [Recipe]()
        let dispatchGroup = DispatchGroup()
        for recipe in recipes {
            dispatchGroup.enter()
            print("Recipe id: \(recipe.recipeId) 小組任務開始")
            checkFitness(for: recipe) { percentage in
                if percentage >= 0.5 {
                    filterdRecipes.append(recipe)
                }
                dispatchGroup.leave()
                print("Recipe id: \(recipe.recipeId) 小組任務結束")
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            print("全部小組任務結束，回傳 filterd Recipe")
            completion(filterdRecipes)
        }
    }
    
    
    
    private func checkFitness(for recipe: Recipe, completion: @escaping (Double) -> Void) {
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
        dispatchGroup.notify(queue: .main) {
            let fitPercentage = Double(checkTypes.count) / Double(allTypes.count)
            print("Recipe id: \(recipe.recipeId) 比對冰箱吻合度: \(fitPercentage.rounding(toDecimal: 3))")
            completion(fitPercentage.rounding(toDecimal: 3))
        }
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
