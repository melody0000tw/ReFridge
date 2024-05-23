//
//  RecipeInfoCell.swift
//  ReFridge
//
//  Created by Melody Lee on 2024/4/23.
//

import UIKit

protocol RecipeInfoCellDelegate: AnyObject {
    func didTappedLikeBtn()
}

class RecipeInfoCell: UITableViewCell {

    static let reuseIdentifier = String(describing: RecipeInfoCell.self)
    weak var delegate: RecipeInfoCellDelegate?
    
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var caloriesLabel: UILabel!
    @IBOutlet weak var servingLabel: UILabel!
    @IBOutlet weak var cookingTimeLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    @IBAction func didTappedLikeBtn(_ sender: UIButton) {
        sender.clickBounceForSmallitem()
        delegate?.didTappedLikeBtn()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        bgView.layer.cornerRadius = 10
        bgView.backgroundColor = .clear
//        setupCell()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setupCell(recipe: Recipe) {
        titleLabel.text = recipe.title
        cookingTimeLabel.text = "\(String(recipe.cookingTime))分鐘"
        servingLabel.text = "\(String(recipe.servings))人份"
        caloriesLabel.text = "\(String(recipe.calories))大卡"
        descriptionLabel.text = recipe.description
        
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
