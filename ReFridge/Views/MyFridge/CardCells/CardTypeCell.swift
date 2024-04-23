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
        editBtn.addTarget(self, action: #selector(toggleTypeView), for: .touchUpInside)
    }
    
    @objc func toggleTypeView() {
        typeViewIsOpen = typeViewIsOpen ? false : true
        containerHeightConstraint.constant = typeViewIsOpen ? 300 : 0
        UIView.animate(withDuration: 0.5) {
            self.layoutIfNeeded()
        }
        delegate?.didToggleTypeView()
        
    }
}
