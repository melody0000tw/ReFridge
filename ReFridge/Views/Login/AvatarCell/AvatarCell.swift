//
//  AvatarCell.swift
//  ReFridge
//
//  Created by Melody Lee on 2024/5/2.
//

import UIKit

class AvatarCell: UICollectionViewCell {
    static let reusableIdentifier = String(describing: AvatarCell.self)

    @IBOutlet weak var hightlightView: UIView!
    
    @IBOutlet weak var imageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        imageView.contentMode = .scaleAspectFit
        hightlightView.isHidden = true
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
