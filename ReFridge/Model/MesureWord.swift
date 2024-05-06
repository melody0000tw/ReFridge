//
//  MesureWord.swift
//  ReFridge
//
//  Created by Melody Lee on 2024/4/21.
//

import Foundation

struct MesureWordData {
    static let shared = MesureWordData()
    
    let data = ["個", "顆", "根", "塊", "串", "朵", "把", "盒", "袋", "包", "罐", "克", "台斤", "公斤"]
    
    private init() {}
}
