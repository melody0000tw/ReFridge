//
//  Error.swift
//  ReFridge
//
//  Created by Melody Lee on 2024/5/11.
//

import Foundation

enum RFError: Error, Equatable {
    static func == (lhs: RFError, rhs: RFError) -> Bool {
        lhs.localizedDescription == rhs.localizedDescription
    }
    
    case incompletedInfo
    case noInternet
    case firebaseError(Error)
}
