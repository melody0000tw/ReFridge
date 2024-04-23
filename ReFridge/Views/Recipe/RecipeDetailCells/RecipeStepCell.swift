//
//  RecipeStepCell.swift
//  ReFridge
//
//  Created by Melody Lee on 2024/4/13.
//

import UIKit

class RecipeStepCell: UITableViewCell {
    var isDone = false
    
    static let reuseIdentifier = String(describing: RecipeStepCell.self)
    
    @IBOutlet weak var numberBGView: UIView!
    @IBOutlet weak var checkmarkView: UIImageView!
    @IBOutlet weak var stepTextLabel: UILabel!
    @IBOutlet weak var numberLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        setupCell()
    }

    private func setupCell() {
        numberBGView.layer.cornerRadius = 15
        checkmarkView.alpha = 0
    }
    
    func toggleButton() {
        isDone =  isDone ? false : true
        switch isDone {
        case true:
            stepTextLabel.alpha = 0.5
            numberBGView.alpha = 0.5
            checkmarkView.alpha = 0.5
        case false:
            stepTextLabel.alpha = 1
            numberBGView.alpha = 1
            checkmarkView.alpha = 0
        }
    }
}
