//
//  EmptyDataManager.swift
//  ReFridge
//
//  Created by Melody Lee on 2024/4/26.
//

import UIKit

class EmptyDataManager {
    lazy var label = UILabel()
    var view: UIView
    var emptyMessage: String
    
    init(view: UIView, emptyMessage: String) {
        self.view = view
        self.emptyMessage = emptyMessage
        setupLabel()
    }
    
    private func setupLabel() {
        label.text = emptyMessage
        label.font = UIFont(name: "PingFangTC-Regular", size: 16)
        label.textAlignment = .center
        label.textColor = .darkGray
        label.numberOfLines = 1
        label.sizeToFit()
        view.addSubview(label)
        label.snp.makeConstraints { make in
            make.centerY.equalTo(view.snp.centerY)
            make.centerX.equalTo(view.snp.centerX)
        }
        label.isHidden = true
    }
    
    func toggleLabel(shouldShow: Bool) {
        label.isHidden = !shouldShow
    }
}
