//
//  ListCell.swift
//  ReFridge
//
//  Created by Melody Lee on 2024/4/14.
//

import UIKit

protocol ListCellDelegate: AnyObject {
    func delete(cell: UITableViewCell)
}

class ListCell: UITableViewCell {
    weak var delegate: ListCellDelegate?
    static let reuseIdentifier = String(describing: ListCell.self)
    
    @IBOutlet weak var squareView: UIView!
    @IBOutlet weak var itemLabel: UILabel!
    @IBOutlet weak var deleteButton: UIButton!
    
    
    @IBAction func didTappedDeleteBtn(_ sender: Any) {
        delegate?.delete(cell: self)
    }
    
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
