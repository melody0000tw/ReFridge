//
//  RecipeIngredientCell.swift
//  ReFridge
//
//  Created by Melody Lee on 2024/4/13.
//

import UIKit

class RecipeIngredientCell: UITableViewCell {

    @IBOutlet weak var allIngredientsLabel: UILabel!
    
    @IBOutlet weak var checkIngredientsLabel: UILabel!
    
    @IBOutlet weak var lackIngredientsLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    @IBAction func addToShoppingList(_ sender: Any) {
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
