//
//  FoodTypeCell.swift
//  ReFridge
//
//  Created by Melody Lee on 2024/4/11.
//

import UIKit

class FoodTypeCell: UICollectionViewCell {

    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var iconImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        bgView.backgroundColor = .clear
        bgView.layer.cornerRadius = 25
    }
    
    override var isSelected: Bool {
        didSet {
            if isSelected {
                bgView.backgroundColor = .C1
            } else {
                bgView.backgroundColor = .clear
            }
        }
    }
}
