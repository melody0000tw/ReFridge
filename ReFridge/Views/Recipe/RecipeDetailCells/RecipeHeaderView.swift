//
//  RecipeHeaderView.swift
//  ReFridge
//
//  Created by Melody Lee on 2024/4/23.
//

import UIKit

protocol RecipeHeaderViewDelegate: AnyObject {
    func didTappedAddToList()
}

class RecipeHeaderView: UITableViewHeaderFooterView {
    weak var delegate: RecipeHeaderViewDelegate?
    static let reuseIdentifier = String(describing: RecipeHeaderView.self)
    @IBOutlet weak var titleLabel: UILabel!

    @IBOutlet weak var addToListBtn: UIButton!
    @IBAction func addToList(_ sender: Any) {
        delegate?.didTappedAddToList()
    }
}
