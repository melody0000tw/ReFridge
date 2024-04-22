//
//  RecipeStepCell.swift
//  ReFridge
//
//  Created by Melody Lee on 2024/4/13.
//

import UIKit

class RecipeStepCell: UITableViewCell {
    static let reuseIdentifier = String(describing: RecipeStepCell.self)
    
    @IBOutlet weak var numberBGView: UIView!
    @IBOutlet weak var checkButton: UIButton!
    @IBOutlet weak var stepTextLabel: UILabel!
    @IBOutlet weak var numberLabel: UILabel!
    
    @IBAction func didTappedCheckBtn(_ sender: Any) {
        toggleButton()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        setupCell()
    }

    private func setupCell() {
        numberBGView.layer.cornerRadius = 15
        checkButton.setImage(UIImage(systemName: "circle"), for: .normal)
        
        checkButton.setImage(UIImage(systemName: "circle.fill"), for: .selected)
    }
    
    func toggleButton() {
        checkButton.isSelected =  checkButton.isSelected ? false : true
        switch checkButton.isSelected {
        case true:
            stepTextLabel.alpha = 0.5
            numberBGView.alpha = 0.5
            checkButton.alpha = 0.5
        case false:
            stepTextLabel.alpha = 1
            numberBGView.alpha = 1
            checkButton.alpha = 1
        }
    }
    
    

}
