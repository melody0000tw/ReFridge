//
//  RecipeIngredientCell.swift
//  ReFridge
//
//  Created by Melody Lee on 2024/4/22.
//

import UIKit

class RecipeIngredientCell: UITableViewCell {
    
    static let reuseIdentifier = String(describing: RecipeIngredientCell.self)
    
    var ingredient: Ingredient?
    var status: Bool?
    
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var statusView: UIImageView!
    @IBOutlet weak var ingredientLabel: UILabel!
    @IBOutlet weak var iconImage: UIImageView!
    @IBOutlet weak var iconBgView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
//        setupCell()
        // Initialization code
    }

//    private func setupCell() {
//        iconBgView.layer.cornerRadius = 25
//    }
    
    func setupData() {
        guard let ingredient = ingredient, let status = status else {
            print("cannot get ingredient or status")
            return
        }
        
        // find type
        guard let foodType = FoodTypeData.share.queryFoodType(typeId: ingredient.typeId) else {
            print("cannot find food type in the system")
            return
        }
        ingredientLabel.text = "\(foodType.typeName) x \(String(ingredient.qty))\(ingredient.mesureWord)"
        iconImage.image = UIImage(named: foodType.typeIcon)
        switch status {
        case true:
            statusView.image = UIImage(systemName: "checkmark.circle.fill")
            statusView.tintColor = .C2
        case false:
            statusView.image = UIImage(systemName: "bag.badge.plus")
            statusView.tintColor = .C5
        }
    }
    
    
}
