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
    private lazy var backBtn = UIButton(type: .system)
    
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setupBackBtn()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.navigationBar.isHidden = false
    }
    
    // MARK: - Setups
    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        tableView.RF_registerHeaderWithNib(identifier: RecipeHeaderView.reuseIdentifier, bundle: nil)
        tableView.RF_registerCellWithNib(identifier: RecipeInfoCell.reuseIdentifier, bundle: nil)
        tableView.RF_registerCellWithNib(identifier: RecipeIngredientCell.reuseIdentifier, bundle: nil)
        tableView.RF_registerCellWithNib(identifier: RecipeHintLabelCell.reuseIdentifier, bundle: nil)
        tableView.RF_registerCellWithNib(identifier: RecipeStepCell.reuseIdentifier, bundle: nil)
        tableView.RF_registerCellWithNib(identifier: RecipeButtonCell.reuseIdentifier, bundle: nil)
        
        // gallery header
        
        let galleryView = RecipeGalleryView()
        guard let recipe = self.recipe else { return }
        galleryView.images = recipe.images
        
        let headerView = UIView()
        headerView.addSubview(galleryView)
        galleryView.snp.makeConstraints { make in
            make.edges.equalTo(headerView.snp.edges)
        }
        
        let cardView = UIView()
        cardView.backgroundColor = .white
        cardView.layer.cornerRadius = 24
        cardView.dropShadow(radius: 5)
        headerView.clipsToBounds = true
        headerView.addSubview(cardView)
        cardView.snp.makeConstraints { make in
            make.width.equalTo(headerView.snp.width)
            make.top.equalTo(headerView.snp.bottom).offset(-24)
            make.height.equalTo(60)
        }
        
        
        
//        tableView.tableHeaderView = galleryView
        tableView.tableHeaderView = headerView
        tableView.tableHeaderView?.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: 500)
    }
    
    private func setupBackBtn() {
        backBtn.setImage(UIImage(systemName: "chevron.backward.circle.fill"), for: .normal)
        backBtn.addTarget(self, action: #selector(backAction), for: .touchUpInside)
        backBtn.alpha = 0.8
        backBtn.contentVerticalAlignment = .fill
        backBtn.contentHorizontalAlignment = .fill
        backBtn.setPreferredSymbolConfiguration(UIImage.SymbolConfiguration(pointSize: 48), forImageIn: .normal)
        backBtn.tintColor = .C1
        view.addSubview(backBtn)
        backBtn.snp.makeConstraints { make in
            make.top.equalTo(view.snp.top).offset(40)
            make.leading.equalTo(view.snp.leading).offset(16)
            make.height.width.equalTo(48)
        }
        
    }
    
    @objc func backAction() {
        navigationController?.popViewController(animated: true)
    }
    
    private func addToList() {
        print("addToShoppingList")
        guard let ingredientStatus = ingredientStatus else {
            print("cannot get ingredient status")
            return
        }
        
        for type in ingredientStatus.lackTypes {
            
            guard let recipe = recipe else {
                print("cannot get recipe")
                return
            }
            let ingredient = recipe.ingredients.first { ingredient in
                ingredient.typeId == type.typeId
            }
            
            guard let ingredient = ingredient else {
                print("cannot get recipe ingredient")
                return
            }
            var item = ListItem()
            
            item.typeId = type.typeId
            item.categoryId = type.categoryId
            item.name = type.typeName
            item.iconName = type.typeIcon
            item.checkStatus = 0
            item.mesureWord = ingredient.mesureWord
            item.qty = ingredient.qty
            item.isRoutineItem = false
            
            Task {
                await firestoreManager.addListItem(item, completion: { result in
                    switch result {
                    case .success:
                        print("adding type: \(item.typeId) successed!")
                        presentAlert(title: "加入成功", description: "已將缺少食材加入購物清單", image: UIImage(systemName: "checkmark.circle"))
                    case .failure(let error):
                        print("error: \(error)")
                    }
                })
            }
        }
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate
extension RecipeDetailViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 1:
            if let recipe = recipe {
                return recipe.ingredients.count + 1
            }
            return 1
        case 2:
            if let recipe = recipe {
                return recipe.steps.count + 1
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
            guard let cell = tableView.dequeueReusableCell(withIdentifier: RecipeInfoCell.reuseIdentifier, for: indexPath) as? RecipeInfoCell else {
                return UITableViewCell()
            }
            
            cell.delegate = self
            cell.titleLabel.text = recipe.title
            cell.cookingTimeLabel.text = "\(String(recipe.cookingTime))分鐘"
            cell.servingLabel.text = "\(String(recipe.servings))人份"
            cell.caloriesLabel.text = "\(String(recipe.calories))大卡"
            cell.toggleLikeBtn(isLiked: isLiked)
            cell.descriptionLabel.text = recipe.description
            
            return cell
            
        case 1:
            if indexPath.row == recipe.ingredients.count {
                guard let cell = tableView.dequeueReusableCell(withIdentifier: RecipeHintLabelCell.reuseIdentifier, for: indexPath) as? RecipeHintLabelCell else {
                    return UITableViewCell()
                }
                return cell
            }
            
            guard let cell = tableView.dequeueReusableCell(withIdentifier: RecipeIngredientCell.reuseIdentifier, for: indexPath) as? RecipeIngredientCell else {
                return UITableViewCell()
            }
            
            let ingredient = recipe.ingredients[indexPath.row]
            cell.ingredient = ingredient
            
            if let ingredientStatus = ingredientStatus {
                let status = ingredientStatus.checkTypes.contains(where: { foodType in
                    ingredient.typeId == foodType.typeId
                })
                
                cell.status = status
            }
            cell.setupData()
            
            return cell
            
        default:
            if indexPath.row == recipe.steps.count {
                guard let cell = tableView.dequeueReusableCell(withIdentifier: RecipeButtonCell.reuseIdentifier, for: indexPath) as? RecipeButtonCell else {
                    return UITableViewCell()
                }
                cell.delegate = self
                return cell
            }
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
        let sections = ["所需食材", "料理步驟"]
        if section != 0 {
            guard let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: RecipeHeaderView.reuseIdentifier) as? RecipeHeaderView else {
                print("cannot get tableview section header")
                return nil
            }
            if section != 1 {
                header.addToListBtn.isHidden = true
            }
            header.delegate = self
            header.titleLabel.text = sections[section - 1]
            if let ingredientStatus = ingredientStatus {
                header.toggleAddToListBtn(isAllSet: ingredientStatus.lackTypes.isEmpty)
            }
            
            return header
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 0 ? 0 : 60
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 2 {
            guard let cell = tableView.cellForRow(at: indexPath) as? RecipeStepCell else {
                print("cannot get recipe step cell")
                return
            }
            
            cell.toggleButton()
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.alpha = 0
        UIView.animate(withDuration: 0.5, delay: 0.1 * Double(indexPath.row)) {
            cell.alpha = 1
        }
    }
}

extension RecipeDetailViewController: RecipeInfoCellDelegate, RecipeHeaderViewDelegate, RecipeButtonCellDelegate {
    func didTappedFinishBtn() {
        print("finished")
        Task {
            guard let recipe = recipe else { return }
            await firestoreManager.addFinishedRecipe(by: recipe.recipeId) { result in
                switch result {
                case .success:
                    print("成功加入完成食譜清單")
                    presentAlert(title: "加入成功", description: "已將食譜加入完成清單", image: UIImage(systemName: "checkmark.circle"))
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        }
    }
    
    func didTappedAddToList() {
        addToList()
    }
    
    func didTappedLikeBtn() {
        // 確認現在狀態
        isLiked = isLiked ? false : true
        guard let recipeInfoCell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? RecipeInfoCell else {
            print("cannot find the cell")
            return
        }
        recipeInfoCell.toggleLikeBtn(isLiked: isLiked)
        
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
