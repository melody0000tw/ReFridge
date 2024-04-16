//
//  CollectionView+Ext.swift
//  ReFridge
//
//  Created by Melody Lee on 2024/4/11.
//

import UIKit

extension UICollectionView {
    
    func RF_registerCellWithNib(identifier: String, bundle: Bundle?) {
        let nib = UINib(nibName: identifier, bundle: bundle)
        register(nib, forCellWithReuseIdentifier: identifier)
    }
}
