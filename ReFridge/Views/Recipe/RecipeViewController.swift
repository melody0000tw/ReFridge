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
    
    @IBAction func filterAction(_ sender: Any) {
        toggleFilterStatus()
    }
    
    var allRecipes: [Recipe] = []
    var showRecipes: [Recipe] = [] {
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    var isFilterd = false
    
    var ingredientsDict: [String: IngredientStatus] = [:] {
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setupSearchBar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchRecipes()
    }
    
    // MARK: - Setups
    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    private func setupSearchBar() {
        let searchController = UISearchController()
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
    }
    
    // MARK: - Data
    private func fetchRecipes() {
        Task {
            await firestoreManager.fetchRecipes { result in
                switch result {
                case .success(let recipes):
                    print("got recipes! \(recipes)")
                    self.allRecipes = recipes
                    self.showRecipes = recipes
                    checkAllStatus(recipes: self.allRecipes) { dict in
                        self.ingredientsDict = dict
                        print("ingredientsDicts fetch 成功")
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
    
    private func checkAllStatus(recipes: [Recipe], completion: @escaping ([String: IngredientStatus]) -> Void) {
        var ingredientsDict: [String: IngredientStatus] = [:]
        let dispatchGroup = DispatchGroup()
        for recipe in recipes {
            dispatchGroup.enter()
            print("Recipe id: \(recipe.recipeId) 小組任務開始")
            checkIngredientStatus(recipe: recipe) { ingredientStatus in
                ingredientsDict[ingredientStatus.recipeId] = ingredientStatus
                dispatchGroup.leave()
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            print("全部小組任務結束，回傳 filterd Recipe")
            completion(ingredientsDict)
        }
    }
    
    private func checkIngredientStatus(recipe: Recipe, completion: @escaping (IngredientStatus) -> Void ) {
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
            let ingredientStatus = IngredientStatus(
                recipeId: recipe.recipeId,
                allTypes: allTypes,
                checkTypes: checkTypes,
                lackTypes: lackTypes,
                fitPercentage: (Double(checkTypes.count) / Double(allTypes.count)).rounding(toDecimal: 2)
            )
            completion(ingredientStatus)
        }
    }
    
    private func toggleFilterStatus() {
        switch isFilterd {
        case true:
            showRecipes = allRecipes
            isFilterd = false
        case false:
            filterRecipe(over: 0.5)
            isFilterd = true
        }
    }
    
    private func filterRecipe(over fitPercentage: Double) {
        guard allRecipes.count != 0, ingredientsDict.count != 0 else {
            print("all recipe or ingredientDict is empty")
            return
        }
        
        var filteredRecipes = allRecipes.filter { recipe in
            guard let ingredientStatus = ingredientsDict[recipe.recipeId] else {
                print("cannot find percentage info")
                return false
            }
            return ingredientStatus.fitPercentage >= fitPercentage
        }
        showRecipes = filteredRecipes
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate

extension RecipeViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        showRecipes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: RecipeCell.self), for: indexPath) as? RecipeCell
        else {
            return UITableViewCell()
        }
        
        let recipe = showRecipes[indexPath.row]
        cell.recipe = recipe
        cell.setupRecipeInfo()
        
        if let ingredientStatus = ingredientsDict[recipe.recipeId] {
            cell.ingredientStatus = ingredientStatus
            cell.setupRecipeInfo()
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let recipe = showRecipes[indexPath.row]
        performSegue(withIdentifier: "showRecipeDetailVC", sender: recipe)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let detailVC = segue.destination as? RecipeDetailViewController,
           let recipe = sender as? Recipe,
           let ingredientStatus = ingredientsDict[recipe.recipeId] {
            detailVC.recipe = recipe
            detailVC.ingredientStatus = ingredientStatus
        }
    }
}

// MARK: - UISearchResultsUpdating
extension RecipeViewController: UISearchResultsUpdating, UISearchBarDelegate {
    func updateSearchResults(for searchController: UISearchController) {
        if let searchText = searchController.searchBar.text,
           searchText.isEmpty != true {
            let filteredRecipes = allRecipes.filter({ recipe in
                recipe.title.localizedCaseInsensitiveContains(searchText)
            })
            showRecipes = filteredRecipes
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        showRecipes = allRecipes
    }
}
