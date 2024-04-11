//
//  FoodCategoryHeaderView.swift
//  ReFridge
//
//  Created by Melody Lee on 2024/4/11.
//

import UIKit
import SnapKit

class FoodCategoryHeaderView: UICollectionReusableView {
    
    let categories = FoodTypeData.share.data
    
    var onChangeCategory: ((Int) -> Void)?
    
    var buttons = [UIButton]()
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .lightGray
        setupButtons()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupButtons()
    }
    
    private func setupButtons() {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 8
        self.addSubview(stackView)
        
        stackView.snp.makeConstraints { make in
            make.edges.equalTo(self.snp.edges)
        }
        
        for category in categories {
            let button = UIButton(type: .system)
            button.setTitle(category.name, for: .normal)
            button.tintColor = .darkGray
            button.tag = category.id
            button.addTarget(self, action: #selector(onChangeCategory(sender: )), for: .touchUpInside)
            buttons.append(button)
            stackView.addArrangedSubview(button)
        }
    }
    
    @objc func onChangeCategory(sender: UIButton) {
        print("did tapped category id: \(sender.tag)")
        let id = sender.tag
        guard let onChangeCategory = onChangeCategory 
        else {
            print(" <onChangeCategory> closure did not setup")
            return
        }
        onChangeCategory(id)
    }
}
