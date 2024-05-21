//
//  NetworkManager.swift
//  ReFridge
//
//  Created by Melody Lee on 2024/5/20.
//

import Foundation
import Network

class NetworkManager {
    static let shared = NetworkManager()
    
    private let monitor = NWPathMonitor()
    
//    var check
        
    private init() {
        startMonitoring()
    }
        
    private func startMonitoring() {
//        monitor.pathUpdateHandler = { path in
//            let isConnected = path.status == .satisfied
//        }
        let queue = DispatchQueue(label: "InternetMonitor")
        monitor.start(queue: queue)
    }
    
    func checkInternetConnetcion() -> Bool {
        let isConnected = monitor.currentPath.status == .satisfied
        print("checkInternetConnetcion: isConnected = \(isConnected)")
        return isConnected
    }
}
