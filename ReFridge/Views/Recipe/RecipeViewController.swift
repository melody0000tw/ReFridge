//
//  RecipeViewController.swift
//  ReFridge
//
//  Created by Melody Lee on 2024/4/13.
//

import UIKit

class RecipeViewController: BaseViewController {
    
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
        showLoadingIndicator()
        Task {
            await firestoreManager.fetchRecipes { result in
                switch result {
                case .success(let recipes):
                    self.allRecipes = recipes
                    checkAllStatus(recipes: self.allRecipes) { dict in
                        self.ingredientsDict = dict
                        self.filterRecipes()
                        self.refreshControl.endRefresh()
                        self.removeLoadingIndicator()
                    }
                    
                case .failure(let error):
                    print("error: \(error)")
                    removeLoadingIndicator()
                    refreshControl.endRefresh()
                    presentInternetAlert()
                }
            }
        }
    }
    
    private func fetchLikedRecipeId() {
        Task {
            await firestoreManager.fetchLikedRecipeId { result in
                switch result {
                case .success(let ids):
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
            checkIngredientStatus(recipe: recipe) { ingredientStatus in
                ingredientsDict[ingredientStatus.recipeId] = ingredientStatus
                dispatchGroup.leave()
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            completion(ingredientsDict)
        }
    }
    
    private func checkIngredientStatus(recipe: Recipe, completion: @escaping (IngredientStatus) -> Void ) {
        var allTypes = [FoodType]()
        var lackTypes = [FoodType]()
        var checkTypes = [FoodType]()
        
        let arrayAccessQueue = DispatchQueue(label: "arrayAccessQueue")
        
        let dispatchGroup = DispatchGroup() // 建立小組任務
        for ingredient in recipe.ingredients {
            dispatchGroup.enter() // 小組任務開始
            let typeId = ingredient.typeId
            
            Task {
                await firestoreManager.queryFoodCard(by: typeId) { [weak self] result in
                    guard let self = self else {
                        dispatchGroup.leave()
                        return
                    }
                    arrayAccessQueue.sync {
                        switch result {
                        case .success(let foodCards):
                            if foodCards.count == 0 {
                                // 缺乏的食材，先用id找到type
                                let foodType = FoodTypeData.share.queryFoodType(typeId: typeId)
                                guard let foodType = foodType else {
                                    print("找不到 foodtype")
                                    return
                                }
                                lackTypes.append(foodType)
                                allTypes.append(foodType)
                            } else {
                                // 冰箱有的，用id找到type
                                let foodType = FoodTypeData.share.queryFoodType(typeId: typeId)
                                guard let foodType = foodType else {
                                    print("找不到 foodtype")
                                    return
                                }
                                checkTypes.append(foodType)
                                allTypes.append(foodType)
                            }
                        case .failure(let error):
                            print("error: \(error)")
                        }
                    }
                }
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
        cell.delegate = self
        
        let recipe = showRecipes[indexPath.row]
        cell.recipe = recipe
        cell.setupRecipeInfo()
        
        if let ingredientStatus = ingredientsDict[recipe.recipeId] {
            cell.ingredientStatus = ingredientStatus
            cell.setupRecipeInfo()
        }
        
        let isLiked = likedRecipeId.contains([recipe.recipeId])
        cell.toggleLikeBtn(isLiked: isLiked)
        
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

// MARK: - RecipeCellDelegate
extension RecipeViewController: RecipeCellDelegate {
    func didTappedLikedBtn(cell: RecipeCell) {
        
        guard let indexPath = tableView.indexPath(for: cell) else {
            print("cannot get indexPath of selected cell")
            return
        }
        let recipe = showRecipes[indexPath.row]
        
        // 確認 cell 現在的狀態
        let isLiked = !likedRecipeId.contains([recipe.recipeId])
        
        // 改變 cell 的狀態
        cell.likeBtn.clickBounceForSmallitem()
        cell.toggleLikeBtn(isLiked: isLiked)
        
        // 更新資料庫
        Task {
            switch isLiked {
            case true:
                await firestoreManager.addLikedRecipe(by: recipe.recipeId) { result in
                    switch result {
                    case .success:
                        self.fetchLikedRecipeId()
                    case .failure(let error):
                        print(error.localizedDescription)
                    }
                }
            case false:
                await firestoreManager.removeLikedRecipe(by: recipe.recipeId) { result in
                    switch result {
                    case .success:
                        self.fetchLikedRecipeId()
                    case .failure(let error):
                        print(error.localizedDescription)
                    }
                }
            }
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
