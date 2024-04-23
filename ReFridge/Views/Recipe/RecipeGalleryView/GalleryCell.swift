//
//  GalleryCell.swift
//  ReFridge
//
//  Created by Melody Lee on 2024/4/22.
//

import UIKit

class GalleryCell: UICollectionViewCell {
    static let reuseIdentifier = String(describing: GalleryCell.self)
    
    let imageView = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        contentView.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.edges.equalTo(contentView.snp.edges)
            imageView.contentMode = .scaleAspectFill
            imageView.clipsToBounds = true
        }
    }
}
