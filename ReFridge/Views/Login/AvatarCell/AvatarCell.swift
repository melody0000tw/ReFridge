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
        imageView.alpha = 0.3
        hightlightView.isHidden = true
    }
    
    override var isSelected: Bool {
        didSet {
            if isSelected {
                UIView.animate(withDuration: 0.2) {
                    self.imageView.alpha = 1
                    self.imageView.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
                }
            } else {
                UIView.animate(withDuration: 0.2) {
                    self.imageView.alpha = 0.3
                    self.imageView.transform = .identity
                }
            }
            
        }
    }

}
