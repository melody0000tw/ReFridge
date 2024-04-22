//
//  RecipeGalleryView.swift
//  ReFridge
//
//  Created by Melody Lee on 2024/4/22.
//

import UIKit

class RecipeGalleryView: UIView {
    private lazy var collectionView = UICollectionView(frame: CGRect(), collectionViewLayout: configureLayout())
    private lazy var pageControl = UIPageControl()
    
    private var images = ["123", "123", "123", "123", "123"] {
        didSet {
            collectionView.reloadData()
            pageControl.numberOfPages = images.count
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupCollectionView()
        setupPageControl()
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.itemSize = CGSize(width: bounds.size.width, height: bounds.size.height)
            layout.invalidateLayout() // 轉換手機方向時強制重新 layout
        }
    }
    
    // MARK: - Setups
    private func configureLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = UIScreen.main.bounds.size
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.sectionInset = UIEdgeInsets.zero
        layout.scrollDirection = .horizontal
        return layout
    }
    
    private func setupCollectionView() {
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(GalleryCell.self, forCellWithReuseIdentifier: GalleryCell.reuseIdentifier)
        collectionView.isPagingEnabled = true
        collectionView.showsHorizontalScrollIndicator = false
        addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.edges.equalTo(self.snp.edges)
        }
    }
    
    private func setupPageControl() {
        pageControl.numberOfPages = images.count
        pageControl.pageIndicatorTintColor = .darkGray
        pageControl.currentPageIndicatorTintColor = .white
        addSubview(pageControl)
        pageControl.snp.makeConstraints { make in
            make.bottom.equalTo(self.snp.bottom).offset(-16)
            make.leading.equalTo(self.snp.leading).offset(16)
        }
    }
    
    
    
}

extension RecipeGalleryView: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: GalleryCell.reuseIdentifier, for: indexPath) as? GalleryCell else {
            print("cannot dequeue gallery cell")
            return UICollectionViewCell()
        }
        
        cell.imageView.image = UIImage(named: "placeholder")
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return bounds.size
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        pageControl.currentPage = indexPath.row
    }
    
}
