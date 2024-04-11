//
//  FoodCardCell.swift
//  ReFridge
//
//  Created by Melody Lee on 2024/4/11.
//

import UIKit

class FoodCardCell: UICollectionViewCell {
    var foodCard: FoodCard?
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var iconImage: UIImageView!
    @IBOutlet weak var remainDayLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func setupCell() {
        guard let foodCard = foodCard else { return }
        nameLabel.text = foodCard.name
    }
    
    override func prepareForReuse() {
        foodCard = nil
    }

}
