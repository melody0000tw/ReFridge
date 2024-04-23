//
//  UIView+Ext.swift
//  ReFridge
//
//  Created by Melody Lee on 2024/4/23.
//

import UIKit

extension UIView {
    func dropShadow(scale: Bool = true, radius: CGFloat = 2) {
        layer.masksToBounds = false
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.5
        layer.shadowOffset = CGSize(width: 1, height: 1)
        layer.shadowRadius = radius
    }
}
