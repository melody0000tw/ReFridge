//
//  UIViewController+Ext.swift
//  ReFridge
//
//  Created by Melody Lee on 2024/5/5.
//

import UIKit

private var loadingView: UIView?

extension UIViewController {
    
    func showLoadingIndicator() {
        DispatchQueue.main.async { [self] in
            loadingView = UIView(frame: self.view.bounds)
            guard let loadingView = loadingView else {
                print("cannot get loading view")
                return
            }
            
            loadingView.backgroundColor = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.5)
            let indicator = UIActivityIndicatorView(style: .large)
            indicator.startAnimating()
            loadingView.addSubview(indicator)
            indicator.snp.makeConstraints { make in
                make.center.equalTo(loadingView.snp.center)
            }
            self.view.addSubview(loadingView)
        }
    }
    
    func removeLoadingIndicator() {
        DispatchQueue.main.async {
            loadingView?.removeFromSuperview()
            loadingView = nil
        }
    }
}
