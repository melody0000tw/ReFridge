//
//  RecipeButtonCell.swift
//  ReFridge
//
//  Created by Melody Lee on 2024/4/26.
//

import UIKit

protocol RecipeButtonCellDelegate: AnyObject {
    func didTappedFinishBtn()
}

class RecipeButtonCell: UITableViewCell {
    weak var delegate: RecipeButtonCellDelegate?
    static let reuseIdentifier = String(describing: RecipeButtonCell.self)
    
    @IBAction func didTappedFinished(_ sender: UIButton) {
        print("did tapped finished")
        sender.clickBounce()
        delegate?.didTappedFinishBtn()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }
}
