//
//  NotRecognizableCell.swift
//  ReFridge
//
//  Created by Melody Lee on 2024/4/15.
//

import UIKit

class NotRecongCell: UICollectionViewCell {
    static let reuseIdentifier = String(describing: NotRecongCell.self)
    
    @IBAction func addAction(_ sender: Any) {
        print("addAction")
    }
    @IBOutlet weak var scanTextLabel: UILabel!
}
