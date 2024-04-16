//
//  Double+Ext.swift
//  ReFridge
//
//  Created by Melody Lee on 2024/4/16.
//

import Foundation

extension Double {
    // 四捨五入進位至小數點第 <decimal> 位
    func rounding(toDecimal decimal: Int) -> Double {
        let numberOfDigits = pow(10.0, Double(decimal))
        return (self * numberOfDigits).rounded(.toNearestOrAwayFromZero) / numberOfDigits
    }
}
