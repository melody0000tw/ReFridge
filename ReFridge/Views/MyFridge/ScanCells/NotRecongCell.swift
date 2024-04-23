//
//  NotRecognizableCell.swift
//  ReFridge
//
//  Created by Melody Lee on 2024/4/15.
//

import UIKit

protocol NotRecongCellDelegate: AnyObject {
    func addRecongCell(cell: UICollectionViewCell)
}

class NotRecongCell: UICollectionViewCell {
    var delegate: NotRecongCellDelegate?
    
    static let reuseIdentifier = String(describing: NotRecongCell.self)
    
    @IBAction func addAction(_ sender: Any) {
        print("addAction")
        delegate?.addRecongCell(cell: self)
    }
    @IBOutlet weak var scanTextLabel: UILabel!
    @IBOutlet weak var bgView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        bgView.layer.cornerRadius = 5
        bgView.backgroundColor = .white
        bgView.dropShadow()
    }
}
