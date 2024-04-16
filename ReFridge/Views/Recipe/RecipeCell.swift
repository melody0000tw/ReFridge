//
//  RecipeCell.swift
//  ReFridge
//
//  Created by Melody Lee on 2024/4/13.
//

import UIKit

class RecipeCell: UITableViewCell {
    
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
    }
    
    func setupRecipeInfo() {
        guard let recipe = recipe else {
            return
        }
        titleLabel.text = recipe.title
        cookingTimeLabel.text = "\(String(recipe.cookingTime))分鐘"
        
        if let ingredientStatus = ingredientStatus {
            var stringAry = [String]()
            if ingredientStatus.lackTypes.count == 0 {
                ingredientIcon.image = UIImage(systemName: "checkmark.circle.fill")
                ingredientLabel.text = ""
                return
            } else {
                for type in ingredientStatus.lackTypes {
                    stringAry.append(type.typeName)
                }
                let join = stringAry.joined(separator: "、")
                ingredientIcon.image = UIImage(systemName: "bag.badge.plus")
                ingredientLabel.text = join
            }
        }
    }
}
