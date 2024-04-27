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
    
    @IBOutlet weak var filterBtn: UIBarButtonItem!
    
    var allRecipes: [Recipe] = []
    var showRecipes: [Recipe] = [] {
        didSet {
            DispatchQueue.main.async {
                self.tableView.isHidden = false
                self.tableView.reloadData()
                self.emptyDataManager.toggleLabel(shouldShow: (self.showRecipes.count == 0))
            }
        }
    }
    
    var recipeFilter = RecipeFilter.all {
        didSet {
            filterRecipes()
        }
    }
    
    var ingredientsDict: [String: IngredientStatus] = [:] {
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    var likedRecipeId = [String]()
    var finishedRecipeId = [String]()
    
    lazy var emptyDataManager = EmptyDataManager(view: self.view, emptyMessage: "尚無相關食譜")
    
    private lazy var refreshControl = RefresherManager()
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setupSearchBar()
        setupFilterBtn()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchRecipes()
        fetchLikedRecipeId()
        fetchFinishedRecipeId()
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        tableView.isHidden = true
    }
    
    // MARK: - Setups
    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        refreshControl.addTarget(self, action: #selector(fetchRecipes), for: .valueChanged)
        tableView.refreshControl = refreshControl
        tableView.refreshControl?.tintColor = .clear
    }
    
    private func setupSearchBar() {
        let searchController = UISearchController()
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling =  false
    }
    
    private func setupFilterBtn() {
        filterBtn.primaryAction = nil
        
        filterBtn.menu = UIMenu(title: "篩選方式", options: .singleSelection, children: [
            UIAction(title: "顯示全部食譜", handler: { _ in
                self.recipeFilter = .all
            }),
            UIAction(title: "推薦清冰箱食譜", handler: { _ in
                self.recipeFilter = .fit
            }),
            UIAction(title: "已收藏食譜", handler: { _ in
                self.recipeFilter = .favorite
            }),
            UIAction(title: "已完成食譜", handler: { _ in
                self.recipeFilter = .finished
            })
        ])
    }
    
    // MARK: - Data
    @objc private func fetchRecipes() {
        refreshControl.startRefresh()
        Task {
            await firestoreManager.fetchRecipes { result in
                switch result {
                case .success(let recipes):
                    print("got recipes! \(recipes)")
                    refreshControl.endRefresh()
                    self.allRecipes = recipes
//                    self.showRecipes = recipes
                    checkAllStatus(recipes: self.allRecipes) { dict in
                        self.ingredientsDict = dict
                        print("ingredientsDicts fetch 成功")
                        self.filterRecipes()
                    }
                    
                case .failure(let error):
                    print("error: \(error)")
                }
            }
        }
    }
    
    private func fetchLikedRecipeId() {
        Task {
            await firestoreManager.fetchLikedRecipeId { result in
                switch result {
                case .success(let ids):
                    print("got id: \(ids.count)")
                    likedRecipeId = ids
                case .failure(let error):
                    print("error: \(error)")
                }
                
            }
        }
    }
    
    private func fetchFinishedRecipeId() {
        Task {
            await firestoreManager.fetchFinishedRecipeId { result in
                switch result {
                case .success(let ids):
                    print("got id: \(ids.count)")
                    finishedRecipeId = ids
                case .failure(let error):
                    print("error: \(error)")
                }
                
            }
        }
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
    
    private func filterRecipes() {
        switch recipeFilter {
        case .all:
            showRecipes = allRecipes
        case .favorite:
            getLikedRecipes()
        case .fit:
            getFitRecipes(over: 0.5)
        case .finished:
            getFinishedRecipes()
        }
    }
    
    private func getFitRecipes(over fitPercentage: Double) {
        guard allRecipes.count != 0, ingredientsDict.count != 0 else {
            print("all recipe or ingredientDict is empty")
            return
        }
        
        let filteredRecipes = allRecipes.filter { recipe in
            guard let ingredientStatus = ingredientsDict[recipe.recipeId] else {
                print("cannot find percentage info")
                return false
            }
            return ingredientStatus.fitPercentage >= fitPercentage
        }
        showRecipes = filteredRecipes
    }
    
    private func getLikedRecipes() {
        guard allRecipes.count != 0 else {
            print("all recipe is empty")
            return
        }
        
        let filteredRecipes = allRecipes.filter { recipe in
            likedRecipeId.contains([recipe.recipeId])
        }
        
        showRecipes = filteredRecipes
    }
    
    private func getFinishedRecipes() {
        guard allRecipes.count != 0 else {
            print("all recipe is empty")
            return
        }
        
        let filteredRecipes = allRecipes.filter { recipe in
            finishedRecipeId.contains([recipe.recipeId])
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
        
        if !likedRecipeId.isEmpty {
            let isLiked = likedRecipeId.contains([recipe.recipeId])
            cell.toggleLikeBtn(isLiked: isLiked)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let recipe = showRecipes[indexPath.row]
        performSegue(withIdentifier: "showRecipeDetailVC", sender: recipe)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.transform = CGAffineTransform(translationX: 0, y: cell.contentView.frame.height)
        
        UIView.animate(withDuration: 0.5, delay: 0.05 * Double(indexPath.row)) {
            cell.transform = CGAffineTransform(translationX: cell.contentView.frame.width, y: cell.contentView.frame.height)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let detailVC = segue.destination as? RecipeDetailViewController,
           let recipe = sender as? Recipe,
           let ingredientStatus = ingredientsDict[recipe.recipeId] {
            detailVC.recipe = recipe
            detailVC.ingredientStatus = ingredientStatus
            let isLiked = likedRecipeId.contains([recipe.recipeId])
            detailVC.isLiked = isLiked
        }
    }
}

// MARK: - UISearchResultsUpdating, UISearchBarDelegate
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
