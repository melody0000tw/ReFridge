//
//  RecipeViewController.swift
//  ReFridge
//
//  Created by Melody Lee on 2024/4/13.
//

import UIKit
import Combine

class RecipeViewController: BaseViewController {
    var viewModel = RecipeViewModel()
    private var cancellables = Set<AnyCancellable>()
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var filterBtn: UIBarButtonItem!
    
    lazy var emptyDataManager = EmptyDataManager(view: self.view, emptyMessage: "尚無相關食譜")
    private lazy var refreshControl = RefresherManager()
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setupSearchBar()
        setupFilterBtn()
        bindViewModel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.isHidden = true
        fetchDatas()
    }
    
    // MARK: - Setups
    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        refreshControl.addTarget(self, action: #selector(fetchDatas), for: .valueChanged)
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
                self.viewModel.recipeFilter = .all
            }),
            UIAction(title: "推薦清冰箱食譜", handler: { _ in
                self.viewModel.recipeFilter = .fit
            }),
            UIAction(title: "已收藏食譜", handler: { _ in
                self.viewModel.recipeFilter = .favorite
            }),
            UIAction(title: "已完成食譜", handler: { _ in
                self.viewModel.recipeFilter = .finished
            })
        ])
    }
    
    // MARK: - Coordinator
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let detailVC = segue.destination as? RecipeDetailViewController,
           let recipe = sender as? Recipe,
           let ingredientStatus = viewModel.ingredientsDict[recipe.recipeId] {
            let isLiked = viewModel.likedRecipeId.contains([recipe.recipeId])
            detailVC.viewModel = RecipeDetailViewModel(
                recipe: recipe,
                ingredientStatus: ingredientStatus,
                isLiked: isLiked)
        }
    }
    
    // MARK: - Data
    private func bindViewModel() {
        viewModel.$showRecipes
            .receive(on: RunLoop.main)
            .dropFirst()
            .sink { [weak self] showRecipes in
                self?.tableView.reloadData()
                self?.tableView.isHidden = false
                self?.emptyDataManager.toggleLabel(shouldShow: (showRecipes.isEmpty))
            }
            .store(in: &cancellables)
        viewModel.$isLoading
            .receive(on: RunLoop.main)
            .sink { [weak self] isLoading in
                if isLoading {
                    self?.showLoadingIndicator()
                } else {
                    self?.removeLoadingIndicator()
                    self?.refreshControl.endRefresh()
                }
            }
            .store(in: &cancellables)
        viewModel.$error
            .receive(on: RunLoop.main)
            .dropFirst()
            .sink { [weak self] _ in
                self?.presentInternetAlert()
            }
            .store(in: &cancellables)
    }
    
    @objc private func fetchDatas() {
        refreshControl.startRefresh()
        viewModel.fetchDatas()
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate
extension RecipeViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.showRecipes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: RecipeCell.self), for: indexPath) as? RecipeCell
        else {
            return UITableViewCell()
        }
        cell.delegate = self
        
        let recipe = viewModel.showRecipes[indexPath.row]
        let ingredientStatus = viewModel.ingredientsDict[recipe.recipeId]
        let isLiked = viewModel.likedRecipeId.contains([recipe.recipeId])
        
        cell.recipe = recipe
        cell.ingredientStatus = ingredientStatus
        cell.setupRecipeInfo()
        cell.toggleLikeBtn(isLiked: isLiked)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let recipe = viewModel.showRecipes[indexPath.row]
        performSegue(withIdentifier: "showRecipeDetailVC", sender: recipe)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.transform = CGAffineTransform(translationX: 0, y: cell.contentView.frame.height)
        
        UIView.animate(withDuration: 0.5, delay: 0.05 * Double(indexPath.row)) {
            cell.transform = CGAffineTransform(translationX: cell.contentView.frame.width, y: cell.contentView.frame.height)
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
        let recipe = viewModel.showRecipes[indexPath.row]
        
        // 確認 cell 現在的狀態
        let isLiked = !viewModel.likedRecipeId.contains([recipe.recipeId])
        
        // 改變 cell 的狀態
        cell.likeBtn.clickBounceForSmallitem()
        cell.toggleLikeBtn(isLiked: isLiked)
        
        // 更新資料庫
        viewModel.updateLikedStatus(isLiked: isLiked, recipe: recipe)
    }
}

// MARK: - UISearchResultsUpdating, UISearchBarDelegate
extension RecipeViewController: UISearchResultsUpdating, UISearchBarDelegate {
    func updateSearchResults(for searchController: UISearchController) {
        if let searchText = searchController.searchBar.text,
           searchText.isEmpty != true {
            viewModel.searchRecipe(with: searchText)
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        viewModel.filterRecipes()
    }
}
