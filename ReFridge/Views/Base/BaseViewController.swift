//
//  BaseViewController.swift
//  ReFridge
//
//  Created by Melody Lee on 2024/5/6.
//

import UIKit

class BaseViewController: UIViewController {
    private let networkManager = NetworkManager.shared
    
    private lazy var loadingView = UIView(frame: view.bounds)
    private lazy var indicator = UIActivityIndicatorView(style: .large)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLoadingView()
    }
    
    func presentNoInternetVC() {
        let noInternetVC = NoInternetViewController()
        noInternetVC.modalPresentationStyle = .fullScreen
        self.present(noInternetVC, animated: false)
    }
    
    func setupLoadingView() {
        loadingView.backgroundColor = UIColor(white: 1, alpha: 0.5)
        loadingView.addSubview(indicator)
        indicator.snp.makeConstraints { make in
            make.center.equalTo(loadingView.snp.center)
        }
        loadingView.isHidden = true
        self.view.addSubview(loadingView)
    }
    
    func showLoadingIndicator() {
        DispatchQueue.main.async { [self] in
            indicator.startAnimating()
            loadingView.isHidden = false
        }
    }
    
    func removeLoadingIndicator() {
        DispatchQueue.main.async { [self] in
            indicator.stopAnimating()
            loadingView.isHidden = true
        }
    }
    
    func presentInternetAlert() {
        DispatchQueue.main.async {
            self.presentAlert(title: "網路連線異常", description: "請檢查網路連線後重新測試", image: UIImage(systemName: "xmark.circle"))
        }
    }
}
