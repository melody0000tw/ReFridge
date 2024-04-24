//
//  CardTypeCell.swift
//  ReFridge
//
//  Created by Melody Lee on 2024/4/20.
//

import UIKit

protocol CardTypeCellDelegate: AnyObject {
    func didToggleTypeView()
}

class CardTypeCell: UITableViewCell {
    weak var delegate: CardTypeCellDelegate?
    
    static let reuseIdentifier = String(describing: CardTypeCell.self)
    
    var mode: FoodCardMode?
    var typeViewIsOpen = true
    
    
    @IBOutlet weak var containerHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var typeContainerView: UIView!
    @IBOutlet weak var editBtn: UIButton!
    @IBOutlet weak var nameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setups()
    }
    
    private func setups() {
        selectionStyle = .none
        bgView.backgroundColor = .C1
        typeContainerView.backgroundColor = .clear
        editBtn.setImage(UIImage(systemName: "chevron.up"), for: .normal)
        editBtn.addTarget(self, action: #selector(toggleTypeView), for: .touchUpInside)
    }
    
    @objc func toggleTypeView() {
        typeViewIsOpen = typeViewIsOpen ? false : true
        if self.typeViewIsOpen {
            self.editBtn.setImage(UIImage(systemName: "chevron.up"), for: .normal)
        } else {
            self.editBtn.setImage(UIImage(systemName: "chevron.down"), for: .normal)
        }
        
        containerHeightConstraint.constant = typeViewIsOpen ? 300 : 0
        UIView.animate(withDuration: 0.5, delay: 0.2) {
            self.typeContainerView.layer.opacity = self.typeViewIsOpen ? 1 : 0
            self.delegate?.didToggleTypeView()
        }
    }
}
