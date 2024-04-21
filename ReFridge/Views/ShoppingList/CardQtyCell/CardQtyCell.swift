//
//  CardQtyCell.swift
//  ReFridge
//
//  Created by Melody Lee on 2024/4/21.
//

import UIKit

protocol CardQtyCellDelegate: AnyObject {
    func didChangeQty(qty: Int, mesureWord: String)
}

class CardQtyCell: UITableViewCell {
    weak var delegate: CardQtyCellDelegate?
    static let reuseIdentifier = String(describing: CardQtyCell.self)
    
    var qty = 1
    var mesureWord = "個"
    
    @IBOutlet weak var mesureWordTextField: UITextField!
    @IBOutlet weak var qtyTextField: UITextField!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var iconImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        qtyTextField.delegate = self
        mesureWordTextField.delegate = self
        qtyTextField.text = String(qty)
        mesureWordTextField.text = mesureWord
        
        // Initialization code
    }
    
}

extension CardQtyCell: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        if let mesureWord = mesureWordTextField.text, let qtyString = qtyTextField.text {
            self.qty = Int(qtyString) ?? 1
            self.mesureWord = mesureWord
            delegate?.didChangeQty(qty: qty, mesureWord: mesureWord)
        }
    }
}
