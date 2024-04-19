//
//  FoodTypeCell.swift
//  ReFridge
//
//  Created by Melody Lee on 2024/4/11.
//

import UIKit

class FoodTypeCell: UICollectionViewCell {

    @IBOutlet weak var iconImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    
    
    override var isSelected: Bool {
        didSet {
            if isSelected {
                contentView.layer.borderColor = UIColor.darkGray.cgColor
                contentView.layer.borderWidth = 1
            } else {
                contentView.layer.borderColor = UIColor.darkGray.cgColor
                contentView.layer.borderWidth = 0
            }
        }
    }
    

}
