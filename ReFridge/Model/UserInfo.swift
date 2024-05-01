//
//  UserInfo.swift
//  ReFridge
//
//  Created by Melody Lee on 2024/4/30.
//

import Foundation

struct UserInfo: Codable {
    var uid: String
    var name: String
    var email: String
    var avatar: String
    var accountStatus: Int
}

// account Status:
// 1 - active
// 0 - deleted
