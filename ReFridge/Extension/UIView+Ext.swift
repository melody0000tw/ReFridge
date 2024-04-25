//
//  UIView+Ext.swift
//  ReFridge
//
//  Created by Melody Lee on 2024/4/23.
//

import UIKit

@IBDesignable
extension UIView {
    
    // Border Color
    @IBInspectable var RFBorderColor: UIColor? {
        get {
            guard let borderColor = layer.borderColor else {
                return nil
            }
            return UIColor(cgColor: borderColor)
        }
        set {
            layer.borderColor = newValue?.cgColor
        }
    }

    // Border width
    @IBInspectable var RFBorderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }

    // Corner radius
    @IBInspectable var RFCornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
        }
    }
    
    func dropShadow(scale: Bool = true, radius: CGFloat = 2) {
        layer.masksToBounds = false
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.5
        layer.shadowOffset = CGSize(width: 1, height: 1)
        layer.shadowRadius = radius
    }
}
