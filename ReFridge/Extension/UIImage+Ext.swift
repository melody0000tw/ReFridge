//
//  UIImage+Ext.swift
//  ReFridge
//
//  Created by Melody Lee on 2024/4/11.
//

import UIKit

enum ImageAsset: String {
    // vegetable
    case broccoli
    case carrot
    case lettuce
    case onion
    case pumpkin
    
    // fruits
    case cherry
    case apple
    case avocado
    case lemon
    case strawberry
}

extension UIImage {
    static func asset(_ asset: ImageAsset) -> UIImage? {
        return UIImage(named: asset.rawValue)
    }
}
