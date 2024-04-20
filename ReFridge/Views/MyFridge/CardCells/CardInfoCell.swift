//
//  CardInfoCell.swift
//  ReFridge
//
//  Created by Melody Lee on 2024/4/20.
//

import UIKit

class CardInfoCell: UITableViewCell {
    static let reuseIdentifier = String(describing: CardInfoCell.self)
    
    @IBOutlet weak var qtyView: UIView!
    @IBOutlet weak var nodeTextView: UITextView!
    @IBOutlet weak var storageSegment: UISegmentedControl!
    @IBOutlet weak var barcodeBtn: UIButton!
    @IBOutlet weak var dateBtn: UIButton!
    @IBOutlet weak var barcodeTextField: UITextField!
    @IBOutlet weak var expireDateTextField: UITextField!
    @IBOutlet weak var iconImage: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
