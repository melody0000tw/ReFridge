//
//  NoInternetViewController.swift
//  ReFridge
//
//  Created by Melody Lee on 2024/5/7.
//

import UIKit

class NoInternetViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    private func setupView() {
        view.backgroundColor = .C7
        
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "wifi.exclamationmark.circle.fill")
        imageView.tintColor = .C2
        view.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.height.width.equalTo(200)
            make.centerX.equalTo(view.snp.centerX)
            make.bottom.equalTo(view.snp.centerY).offset(-24)
        }
        
        let label = UILabel()
        label.text = "網路連線異常"
        label.font = UIFont(name: "PingFangTC-Medium", size: 28)
        label.textAlignment = .center
        label.textColor = .darkGray
        label.numberOfLines = 1
        label.sizeToFit()
        view.addSubview(label)
        label.snp.makeConstraints { make in
            make.centerX.equalTo(view.snp.centerX)
            make.top.equalTo(view.snp.centerY).offset(24)
        }
    }
}
