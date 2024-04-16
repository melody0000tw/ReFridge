//
//  RecipeStepCell.swift
//  ReFridge
//
//  Created by Melody Lee on 2024/4/13.
//

import UIKit

class RecipeStepCell: UITableViewCell {
    static let reuseIdentifier = String(describing: RecipeStepCell.self)
    
    @IBOutlet weak var checkButton: UIButton!
    @IBOutlet weak var stepTextLabel: UILabel!
    @IBOutlet weak var numberLabel: UILabel!
    
    @IBAction func didTappedCheckBtn(_ sender: Any) {
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
