//
//  RecipeAddToListCell.swift
//  ReFridge
//
//  Created by Melody Lee on 2024/4/22.
//

import UIKit

class RecipeAddToListCell: UITableViewCell {
    static let reuseIdentifier = String(describing: RecipeAddToListCell.self)
    
    var onClickAddToList: (() -> Void)?
    
    @IBOutlet weak var addToListBtn: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        setupBtn()
        // Initialization code
    }
    
    private func setupBtn() {
        addToListBtn.layer.borderColor = UIColor.C2.cgColor
        addToListBtn.layer.borderWidth = 1
        addToListBtn.layer.cornerRadius = 5
        addToListBtn.addTarget(self, action: #selector(addToListAction), for: .touchUpInside)
    }
    
    @objc func addToListAction() {
        if let onClickAddToList = onClickAddToList {
            onClickAddToList()
        }
        
    }
    
}
