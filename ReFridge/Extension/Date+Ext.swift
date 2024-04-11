//
//  Date+Ext.swift
//  ReFridge
//
//  Created by Melody Lee on 2024/4/12.
//

import Foundation

extension Date {
    func calculateRemainingDays() -> Int? {
        let calendar = Calendar.current
        let today = Date()
        let startOfToday = calendar.startOfDay(for: today)
        let startOfExpireDate = calendar.startOfDay(for: self)
        let components = calendar.dateComponents([.day], from: startOfToday, to: startOfExpireDate)
        return components.day
    }
}
