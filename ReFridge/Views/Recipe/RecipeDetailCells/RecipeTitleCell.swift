//
//  RecipeTitleCell.swift
//  ReFridge
//
//  Created by Melody Lee on 2024/4/13.
//

import UIKit

protocol RecipeTitleCellDelegate: AnyObject {
    func didTappedLikeBtn()
}

class RecipeTitleCell: UITableViewCell {
    static let reuseIdentifier = String(describing: RecipeTitleCell.self)
    weak var delegate: RecipeTitleCellDelegate?
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var caloriesLabel: UILabel!
    @IBOutlet weak var servingLabel: UILabel!
    @IBOutlet weak var cookingTimeLabel: UILabel!
    
    // TODO: 點選按鈕可改變 Liked 狀態
    @IBAction func didTappedLikeBtn(_ sender: Any) {
        delegate?.didTappedLikeBtn()
    }
    
    func toggleLikeBtn(isLiked: Bool) {
        switch isLiked {
        case true:
            likeButton.setImage(UIImage(systemName: "heart.fill"), for: .normal)
        case false:
            likeButton.setImage(UIImage(systemName: "heart"), for: .normal)
        }
    }

}
