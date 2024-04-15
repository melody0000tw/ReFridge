//
//  RecognizableCell.swift
//  ReFridge
//
//  Created by Melody Lee on 2024/4/15.
//

import UIKit

class RecongCell: UICollectionViewCell {
    static let reuseIdentifier = String(describing: RecongCell.self)
    
    @IBAction func deleteAction(_ sender: Any) {
        print("deleteAction")
    }
    @IBAction func editAction(_ sender: Any) {
        print("editAction")
    }
    
    
    @IBOutlet weak var expireDateLabel: UILabel!
    @IBOutlet weak var qtyLabel: UILabel!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var iconImage: UIImageView!
    @IBOutlet weak var scanTextLabel: UILabel!
}
