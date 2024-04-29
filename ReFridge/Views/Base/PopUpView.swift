//
//  PopUpView.swift
//  ReFridge
//
//  Created by Melody Lee on 2024/4/28.
//

import UIKit
import SwiftEntryKit

class PopUpView: UIView {
    
    let imageView = UIImageView()
    let label = UILabel()
    let message: EKNotificationMessage
    
    init(message: EKNotificationMessage) {
        self.message = message
        super.init()
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupView() {
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .C2
        label.text = "123"
        label.font = UIFont(name: "PingFangTC-Regular", size: 16)
        label.textAlignment = .left
        label.textColor = .darkGray
        label.numberOfLines = 0
        label.sizeToFit()
        addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.height.width.equalTo(40)
            make.centerY.equalTo(self.snp.centerY)
            make.leading.equalTo(self.snp.leading).offset(16)
        }
        
        addSubview(label)
        label.snp.makeConstraints { make in
            make.centerY.equalTo(self.snp.centerY)
            make.leading.equalTo(imageView.snp.trailing).offset(16)
            make.trailing.greaterThanOrEqualTo(self.snp.trailing).offset(-16)
        }
    }
    
}
