//
//  FormatterManager.swift
//  ReFridge
//
//  Created by Melody Lee on 2024/4/14.
//

import Foundation

class FormatterManager {
    static let share = FormatterManager()
    
    let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }()
}
