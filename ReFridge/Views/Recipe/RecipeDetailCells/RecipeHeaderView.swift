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
    
    @IBAction func addToList(_ sender: UIButton) {
        sender.clickBounce()
        delegate?.didTappedAddToList()
    }
    
    func toggleAddToListBtn(isAllSet: Bool) {
        if isAllSet {
            addToListBtn.isEnabled = false
            addToListBtn.setTitle("食材已準備就緒", for: .disabled)
            addToListBtn.setTitleColor(.C2, for: .disabled)
            addToListBtn.layer.borderColor = UIColor.C2.cgColor
            
        } else {
            addToListBtn.isEnabled = true
            addToListBtn.setTitle("將缺少食材加入購物清單", for: .normal)
            addToListBtn.setTitleColor(.C5, for: .normal)
            addToListBtn.layer.borderColor = UIColor.C5.cgColor
        }
    }
}
