//
//  FoodCardCell.swift
//  ReFridge
//
//  Created by Melody Lee on 2024/4/11.
//

import UIKit

class FoodCardCell: UICollectionViewCell {
    var foodCard: FoodCard?
    
    @IBOutlet weak var remainDayBgView: UIView!
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var iconImage: UIImageView!
    @IBOutlet weak var remainDayLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = .tertiarySystemBackground
        // Initialization code
    }
    
    func setupDefaultCell() {
        remainDayBgView.backgroundColor = .clear
        iconImage.tintColor = .T1
        bgView.backgroundColor = .clear
        bgView.layer.cornerRadius = 16
        bgView.layer.borderColor = UIColor.C1.cgColor
        bgView.layer.borderWidth = 1
    }
    
    func setupCell() {
        guard let foodCard = foodCard else { return }
        nameLabel.text = foodCard.name
        iconImage.image = UIImage(named: foodCard.iconName)
        iconImage.tintColor = .T1
        remainDayLabel.text = getRemainingDayText(expireDate: foodCard.expireDate)
        bgView.layer.cornerRadius = 16
        bgView.layer.borderWidth = 0
        remainDayBgView.layer.cornerRadius = 10
        remainDayBgView.backgroundColor = .white
        guard let category = CategoryData.share.queryFoodCategory(categoryId: foodCard.categoryId) else {
            return
        }
        bgView.backgroundColor = UIColor(hex: category.categoryColor)
        
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
        remainDayLabel.isHidden = false
    }

}
