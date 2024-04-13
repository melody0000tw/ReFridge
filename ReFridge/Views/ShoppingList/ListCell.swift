//
//  ListCell.swift
//  ReFridge
//
//  Created by Melody Lee on 2024/4/14.
//

import UIKit

class ListCell: UITableViewCell {
    static let reuseIdentifier = String(describing: ListCell.self)
    
    @IBOutlet weak var squareView: UIView!
    @IBOutlet weak var itemLabel: UILabel!
    @IBOutlet weak var deleteButton: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
