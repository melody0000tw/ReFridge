//
//  NetworkCheckProtocol.swift
//  ReFridge
//
//  Created by Melody Lee on 2024/5/6.
//

import Foundation
import Network

class NetworkManager {
    static let shared = NetworkManager()
    
//    private let firestoreManager: FirestoreManager
    private let monitor = NWPathMonitor()
    
    var onChangeInternetConnection: ((Bool) -> Void)?
        
    private init() {
        startMonitoring()
    }
        
    private func startMonitoring() {
        monitor.pathUpdateHandler = { path in
            // Handle path update if needed
            print("internet path did update : \(path.status)")
            let isConnected = path.status == .satisfied
            if let onChangeInternetConnection = self.onChangeInternetConnection {
                onChangeInternetConnection(isConnected)
            }
            
            
            
        }
        let queue = DispatchQueue(label: "InternetMonitor")
        monitor.start(queue: queue)
    }
    
    func checkInternetConnetcion() -> Bool {
        let isConnected = monitor.currentPath.status == .satisfied
        return isConnected
    }
}
