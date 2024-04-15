//
//  ScanResult.swift
//  ReFridge
//
//  Created by Melody Lee on 2024/4/15.
//

import Foundation


struct ScanResult {
    var recongItems: [ScanTextItem]
    var notRecongItems: [ScanTextItem]
}

struct ScanTextItem {
    var text: String
    var foodCard: FoodCard?
}
