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
        editBtn.addTarget(self, action: #selector(didTappedEditBtn), for: .touchUpInside)
    }
    
    @objc func didTappedEditBtn() {
        self.delegate?.didToggleTypeView()
    }
    
    func toggleTypeView(shouldOpen: Bool) {
        if shouldOpen {
            self.editBtn.setImage(UIImage(systemName: "chevron.up"), for: .normal)
        } else {
            self.editBtn.setImage(UIImage(systemName: "chevron.down"), for: .normal)
        }
        
        containerHeightConstraint.constant = shouldOpen ? 300 : 0
        self.typeContainerView.layer.opacity = shouldOpen ? 1 : 0
//        UIView.animate(withDuration: 0.1, delay: 0.2) {
//            self.typeContainerView.layer.opacity = shouldOpen ? 1 : 0
//        }
    }
}
