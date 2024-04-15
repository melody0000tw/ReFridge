//
//  RecognizableCell.swift
//  ReFridge
//
//  Created by Melody Lee on 2024/4/15.
//

import UIKit

protocol RecongCellDelegate: AnyObject {
    func deleteRecongCell(cell: UICollectionViewCell)
    func editRecongCell(cell: UICollectionViewCell)
}


class RecongCell: UICollectionViewCell {
    var delegate: RecongCellDelegate?
    static let reuseIdentifier = String(describing: RecongCell.self)
    
    @IBAction func deleteAction(_ sender: Any) {
        print("deleteAction")
        delegate?.deleteRecongCell(cell: self)
    }
    @IBAction func editAction(_ sender: Any) {
        print("editAction")
        delegate?.editRecongCell(cell: self)
    }
    
    @IBOutlet weak var expireDateLabel: UILabel!
    @IBOutlet weak var qtyLabel: UILabel!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var iconImage: UIImageView!
    @IBOutlet weak var scanTextLabel: UILabel!
    
    
    
}
