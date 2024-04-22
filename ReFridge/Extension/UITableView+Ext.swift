//
//  UITableView+Ext.swift
//  ReFridge
//
//  Created by Melody Lee on 2024/4/20.
//

import UIKit

extension UITableView {
    
    func RF_registerCellWithNib(identifier: String, bundle: Bundle?) {
        let nib = UINib(nibName: identifier, bundle: bundle)
        register(nib, forCellReuseIdentifier: identifier)
    }
}
