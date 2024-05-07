//
//  RecipeCell.swift
//  ReFridge
//
//  Created by Melody Lee on 2024/4/13.
//

import UIKit

protocol RecipeCellDelegate: AnyObject {
    func didTappedLikedBtn(cell: RecipeCell)
}

class RecipeCell: UITableViewCell {
    weak var delegate: RecipeCellDelegate?
    
    var recipe: Recipe?
    var ingredientStatus: IngredientStatus?
    
    @IBOutlet weak var likeBtn: UIButton!
    @IBOutlet weak var ingredientIcon: UIImageView!
    @IBOutlet weak var ingredientLabel: UILabel!
    @IBOutlet weak var cookingTimeLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var recipeImage: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        setupViews()
    }
    
    private func setupViews() {
        recipeImage.layer.cornerRadius = 16
        recipeImage.clipsToBounds = true
        recipeImage.contentMode = .scaleAspectFill
        likeBtn.addTarget(self, action: #selector(didTappedLikeBtn), for: .touchUpInside)
        
    }
    
    @objc func didTappedLikeBtn() {
        print("didTappedLikeBtn")
        delegate?.didTappedLikedBtn(cell: self)
    }
    
    func toggleLikeBtn(isLiked: Bool) {
        if isLiked {
            likeBtn.setImage(UIImage(systemName: "heart.fill"), for: .normal)
        } else {
            likeBtn.setImage(UIImage(systemName: "heart"), for: .normal)
        }
    }
    
    func setupRecipeInfo() {
        guard let recipe = recipe else {
            return
        }
        titleLabel.text = recipe.title
        cookingTimeLabel.text = "\(String(recipe.cookingTime))分鐘"
        recipeImage.loadImage(recipe.images.first)
        
        if let ingredientStatus = ingredientStatus {
            var stringAry = [String]()
            if ingredientStatus.lackTypes.count == 0 {
                ingredientIcon.image = UIImage(systemName: "checkmark.circle.fill")
                ingredientLabel.text = "食材已準備就緒"
                ingredientIcon.tintColor = .C2
                return
            } else {
                for type in ingredientStatus.lackTypes {
                    stringAry.append(type.typeName)
                }
                let join = stringAry.joined(separator: "、")
                ingredientIcon.image = UIImage(systemName: "bag.badge.plus")
                ingredientLabel.text = join
                ingredientIcon.tintColor = .C5
            }
        }
    }
    
    override func prepareForReuse() {
        ingredientIcon.image = nil
        ingredientLabel.text = nil
        recipe = nil
        ingredientStatus = nil
    }
}
