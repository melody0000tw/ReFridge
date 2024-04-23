//
//  RecipeHeaderView.swift
//  ReFridge
//
//  Created by Melody Lee on 2024/4/23.
//

import UIKit

class RecipeHeaderView: UITableViewHeaderFooterView {
    static let reuseIdentifier = String(describing: RecipeHeaderView.self)
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var bgView: UIView!
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        bgView.layer.cornerRadius = 20
    }
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
