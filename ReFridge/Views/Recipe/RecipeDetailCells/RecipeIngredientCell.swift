//
//  RecipeIngredientCell.swift
//  ReFridge
//
//  Created by Melody Lee on 2024/4/13.
//

import UIKit

class RecipeIngredientCell: UITableViewCell {
    static let reuseIdentifier = String(describing: RecipeIngredientCell.self)
    
    var ingredientStatus: IngredientStatus?
    
    @IBOutlet weak var allIngredientsLabel: UILabel!
    @IBOutlet weak var checkIngredientsLabel: UILabel!
    @IBOutlet weak var lackIngredientsLabel: UILabel!

    @IBAction func addToShoppingList(_ sender: Any) {
    }
    
    func setupCell() {
        guard let ingredientStatus = ingredientStatus else { return }
        // MARK: - all
        var allString = String()
        for type in ingredientStatus.allTypes {
            allString.append(type.typeName)
            allString.append(" ")
        }
        allIngredientsLabel.text = allString
        
        // MARK: - check
        var checktring = String()
        for type in ingredientStatus.checkTypes {
            checktring.append(type.typeName)
            checktring.append(" ")
        }
        checkIngredientsLabel.text = checktring
        
        // MARK: - lack
        var lacktring = String()
        for type in ingredientStatus.lackTypes {
            lacktring.append(type.typeName)
            lacktring.append(" ")
        }
        lackIngredientsLabel.text = lacktring
    }
    
}
