//
//  UIColor+Ext.swift
//  ReFridge
//
//  Created by Melody Lee on 2024/4/18.
//

import Foundation
import UIKit

private enum RFColor: String {
    // swiftlint:disable identifier_name
    case C1 = "D6DAC8"
    case C2 = "627254"
    case C3 = "FBF3D5"
    case C4 = "EFBC9B"
    case T1 = "31363F"
    case T2 = "FEFBF6"
    case B1 = "FCF5ED"
    // swiftlint:enable identifier_name
}


extension UIColor {
    // swiftlint:disable identifier_name
    static let C1 = RFColor(.C1)
    static let C2 = RFColor(.C2)
    static let C3 = RFColor(.C3)
    static let C4 = RFColor(.C4)
    static let T1 = RFColor(.T1)
    static let T2 = RFColor(.T2)
    static let B1 = RFColor(.B1)
    // swiftlint:enable identifier_name
    
    private static func RFColor(_ color: RFColor, alpha: CGFloat = 1) -> UIColor {
        return UIColor.init(hex: color.rawValue, alpha: alpha)
    }
    
    convenience init(hex: String, alpha: CGFloat = 1.0) {
        var hexValue = hex.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).uppercased()

        if hexValue.hasPrefix("#") {
            hexValue.remove(at: hexValue.startIndex)
        }

        var rgbValue: UInt64 = 0
        Scanner(string: hexValue).scanHexInt64(&rgbValue)

        let red = CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0
        let green = CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0
        let blue = CGFloat(rgbValue & 0x0000FF) / 255.0

        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }
}
