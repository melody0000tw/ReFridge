//
//  Error.swift
//  ReFridge
//
//  Created by Melody Lee on 2024/5/11.
//

import Foundation

enum ErrorType: Error, Equatable {
    static func == (lhs: ErrorType, rhs: ErrorType) -> Bool {
        lhs.localizedDescription == rhs.localizedDescription
    }
    
    case incompletedInfo
    case firebaseError(Error)
}
