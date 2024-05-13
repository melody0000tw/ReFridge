//
//  TypeImageHeaderView.swift
//  ReFridge
//
//  Created by Melody Lee on 2024/5/13.
//

import UIKit

class TypeImageHeaderView: UICollectionReusableView {
    static let reuseIdentifier = String(describing: TypeImageHeaderView.self)
    
    lazy var label = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .white
        setupLabel()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupLabel() {
        label.textAlignment = .center
        label.textColor = .darkGray
        label.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        addSubview(label)
        label.snp.makeConstraints { make in
            make.centerY.equalTo(self.snp.centerY)
            make.leading.equalTo(self.snp.leading).offset(8)
        }
    }
    
}
