//
//  TypeImageCell.swift
//  ReFridge
//
//  Created by Melody Lee on 2024/4/19.
//

import UIKit

class TypeImageCell: UICollectionViewCell {
    static let reuseIdentifier = String(describing: TypeImageCell.self)
    
    @IBOutlet weak var hightlightView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        hightlightView.layer.borderColor = UIColor.darkGray.cgColor
        hightlightView.layer.borderWidth = 1
        hightlightView.layer.cornerRadius = 5
        hightlightView.isHidden = true
        // Initialization code
    }
    
    
    override var isSelected: Bool {
        didSet {
            if isSelected {
                hightlightView.isHidden = false
            } else {
                hightlightView.isHidden = true
            }
            
        }
    }

}
