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
        iconImage.image = UIImage(named: foodCard.iconName)
        remainDayLabel.text = getRemainingDayText(expireDate: Date(timeIntervalSince1970: foodCard.expireDate))
    }
    
    private func getRemainingDayText(expireDate: Date) -> String {
        guard let remainingDays = expireDate.calculateRemainingDays() else {
            return "無法判斷"
        }
        if remainingDays > 0 {
            return "還剩\(String(describing: remainingDays))天"
        } else if remainingDays == 0 {
            return "今天到期"
        } else {
            return "過期\(String(describing: abs(remainingDays)))天"
        }
    }
    
    override func prepareForReuse() {
        foodCard = nil
    }

}
