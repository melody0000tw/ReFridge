//
//  RecipeAddToListCell.swift
//  ReFridge
//
//  Created by Melody Lee on 2024/4/22.
//

import UIKit

class RecipeHintLabelCell: UITableViewCell {
    static let reuseIdentifier = String(describing: RecipeHintLabelCell.self)
    
    @IBOutlet weak var hintLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }
}
