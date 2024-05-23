//
//  RecipeIngredientCell.swift
//  ReFridge
//
//  Created by Melody Lee on 2024/4/22.
//

import UIKit

protocol RecipeIngredientCellDelegate: AnyObject {
//    func addItemToList(cell: RecipeIngredientCell)
    func addItemToList(ingredient: Ingredient)
}

class RecipeIngredientCell: UITableViewCell {
    weak var delegate: RecipeIngredientCellDelegate?
    static let reuseIdentifier = String(describing: RecipeIngredientCell.self)
    
    var ingredient: Ingredient?
    var isChecked: Bool?
    
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var statusView: UIImageView!
    @IBOutlet weak var ingredientLabel: UILabel!
    @IBOutlet weak var iconImage: UIImageView!
    @IBOutlet weak var iconBgView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTappedAddToList))
        statusView.isUserInteractionEnabled = true
        statusView.addGestureRecognizer(tapGesture)
    }
    
    @objc func didTappedAddToList() {
        guard let ingredient = ingredient else { return }
        delegate?.addItemToList(ingredient: ingredient)
    }
    
    func setupCell(ingredient: Ingredient, foodType: FoodType, isChecked: Bool) {
        self.ingredient = ingredient
        self.isChecked = isChecked
        
        ingredientLabel.text = "\(foodType.typeName) x \(String(ingredient.qty))\(ingredient.mesureWord)"
        iconImage.image = UIImage(named: foodType.typeIcon)
        
        switch isChecked {
        case true:
            statusView.image = UIImage(systemName: "checkmark.circle.fill")
            statusView.tintColor = .C2
        case false:
            statusView.image = UIImage(systemName: "bag.badge.plus")
            statusView.tintColor = .C5
        }
    }
}
