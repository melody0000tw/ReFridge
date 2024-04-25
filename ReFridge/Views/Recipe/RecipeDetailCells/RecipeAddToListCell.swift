//
//  RecipeAddToListCell.swift
//  ReFridge
//
//  Created by Melody Lee on 2024/4/22.
//

import UIKit

class RecipeAddToListCell: UITableViewCell {
    static let reuseIdentifier = String(describing: RecipeAddToListCell.self)
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }
}
