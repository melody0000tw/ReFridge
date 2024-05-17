//
//  RecipeDetailViewController.swift
//  ReFridge
//
//  Created by Melody Lee on 2024/4/13.
//

import UIKit
import SnapKit

class RecipeDetailViewController: BaseViewController {
    var viewModel = RecipeDetailViewModel()
    
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
        guard let recipe = viewModel.recipe else { return }
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
}

// MARK: - UITableViewDataSource
extension RecipeDetailViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let recipe = viewModel.recipe else {
            return 1
        }
        
        if section == 1 {
            return recipe.ingredients.count + 1
        } else if section == 2 {
            return recipe.steps.count + 1
        } else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let recipe = viewModel.recipe,
              let ingredientStatus = viewModel.ingredientStatus
        else {
            return UITableViewCell()
        }
        
        switch indexPath.section {
        case 0:
            return mappingCellWith(recipe: recipe, isLiked: viewModel.isLiked)
        case 1:
            if indexPath.row == recipe.ingredients.count {
                return mappingCellWith(hint: "僅以食材類型做比對，請自行確認冰箱中食材數量")
            } else {
                let ingredient = recipe.ingredients[indexPath.row]
                let isChecked =  ingredientStatus.checkTypes.contains(where: { foodType in
                    ingredient.typeId == foodType.typeId
                })
                guard let foodType = FoodTypeData.share.queryFoodType(typeId: ingredient.typeId) else {
                    return UITableViewCell()
                }
                
                return mappingCellWith(ingredient: ingredient, foodType: foodType, isChecked: isChecked)
            }
            
        default:
            if indexPath.row == recipe.steps.count {
                return mappingBtnCell()
            } else {
                return mappingCellWith(stepNumber: Int(indexPath.row + 1), stepText: recipe.steps[indexPath.row])
            }
        }
    }
    
    // MARK: - LayoutCells
    private func mappingCellWith(recipe: Recipe, isLiked: Bool) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: RecipeInfoCell.reuseIdentifier) as? RecipeInfoCell else {
            return UITableViewCell()
        }
        
        cell.delegate = self
        cell.setupCell(recipe: recipe)
        cell.toggleLikeBtn(isLiked: isLiked)
        
        return cell
    }
    
    private func mappingCellWith(hint: String) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: RecipeHintLabelCell.reuseIdentifier) as? RecipeHintLabelCell else {
            return UITableViewCell()
        }
        cell.hintLabel.text = hint
        return cell
    }
    
    private func mappingCellWith(ingredient: Ingredient, foodType: FoodType, isChecked: Bool) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: RecipeIngredientCell.reuseIdentifier) as? RecipeIngredientCell else {
            return UITableViewCell()
        }
        cell.delegate = self
        cell.setupCell(ingredient: ingredient, foodType: foodType, isChecked: isChecked)
        
        return cell
    }
    
    private func mappingBtnCell() -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: RecipeButtonCell.reuseIdentifier) as? RecipeButtonCell else {
            return UITableViewCell()
        }
        cell.delegate = self
        return cell
    }
    
    private func mappingCellWith(stepNumber: Int, stepText: String) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: RecipeStepCell.reuseIdentifier) as? RecipeStepCell else {
            return UITableViewCell()
        }
        
        cell.numberLabel.text = String(stepNumber)
        cell.stepTextLabel.text = stepText
        return cell
    }
}
    
// MARK: - UITableViewDelegate
extension RecipeDetailViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let sections = ["所需食材", "料理步驟"]
        switch section {
        case 1:
            guard let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: RecipeHeaderView.reuseIdentifier) as? RecipeHeaderView else {
                print("cannot get tableview section header")
                return nil
            }
            header.delegate = self
            header.titleLabel.text = sections[section - 1]
            if let ingredientStatus = viewModel.ingredientStatus {
                header.toggleAddToListBtn(isAllSet: ingredientStatus.lackTypes.isEmpty)
            }
            return header
        case 2:
            guard let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: RecipeHeaderView.reuseIdentifier) as? RecipeHeaderView else {
                print("cannot get tableview section header")
                return nil
            }
            header.addToListBtn.isHidden = true
            header.titleLabel.text = sections[section - 1]
            return header
        default:
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch section {
        case 1,2 : return 60
        default: return 0
        }
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

// MARK: - Cell Delegates
extension RecipeDetailViewController: RecipeInfoCellDelegate, RecipeHeaderViewDelegate, RecipeButtonCellDelegate, RecipeIngredientCellDelegate {
    
    // MARK: - RecipeIngredientCellDelegate
    func addItemToList(ingredient: Ingredient) {
        viewModel.addToList(ingredient: ingredient) { [self] result in
            switch result {
            case .success(let type):
                presentAlert(title: "加入成功", description: "已將\(type.typeName)成功加入購物清單", image: UIImage(systemName: "checkmark.circle"))
            case .failure(let error):
                print("error: \(error)")
                presentInternetAlert()
            }
        }
    }

    // MARK: - RecipeButtonCellDelegate
    func didTappedFinishBtn() {
        viewModel.addToFinishList { [self] result in
            switch result {
            case .success:
                DispatchQueue.main.async {
                    self.presentAlert(title: "加入成功", description: "已將食譜加入完成清單", image: UIImage(systemName: "checkmark.circle"))
                    self.navigationController?.popViewController(animated: true)
            }
            case .failure(let error):
                print("error: \(error)")
                presentInternetAlert()
            }
        }
    }
     
    // MARK: - RecipeHeaderViewDelegate
    func didTappedAddAllLackIngredientToList() {
        viewModel.addAllLackIngredientsToList { [self] result in
            switch result {
            case .success:
                DispatchQueue.main.async {
                    self.presentAlert(title: "加入成功", description: "已將缺少食材加入購物清單", image: UIImage(systemName: "checkmark.circle"))
            }
            case .failure(let error):
                print("error: \(error)")
                presentInternetAlert()
            }
        }
    }
    
    // MARK: - RecipeInfoCellDelegate
    func didTappedLikeBtn() {
        // 確認現在狀態
        viewModel.isLiked = !viewModel.isLiked
        let isLiked = viewModel.isLiked
        guard let recipeInfoCell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? RecipeInfoCell else {
            print("cannot find the cell")
            return
        }
        recipeInfoCell.toggleLikeBtn(isLiked: isLiked)
        viewModel.updateLikedStatus(isLiked: isLiked)
    }
}
