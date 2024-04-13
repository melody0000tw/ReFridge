//
//  FoodTypeSelectionViewController.swift
//  ReFridge
//
//  Created by Melody Lee on 2024/4/12.
//

import UIKit
import SnapKit

class FoodTypeViewController: UIViewController {
    private let firestoreManager = FirestoreManager.shared
    
    let categories = CategoryData.share.data
    
    var allFoodTypes: [FoodType] = []
    var typesOfSelectedCategory: [FoodType] = [] {
        didSet {
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        }
    }
    
    var onSelectFoodType: ((FoodType) -> Void)?

    lazy var collectionView = UICollectionView(frame: CGRect(), collectionViewLayout: configureLayout())
    lazy var buttons = [UIButton]()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupButtons()
        setupCollectionView()
        fetchFoodTypes()
    }
    
    private func configureLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 100, height: 120)
        layout.minimumLineSpacing = 16
        layout.minimumInteritemSpacing = 8
        layout.sectionInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        layout.sectionHeadersPinToVisibleBounds = true
        return layout
    }
    
    private func setupButtons() {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 0
        view.addSubview(stackView)
        
        stackView.snp.makeConstraints { make in
            make.top.equalTo(view.snp.top)
            make.leading.equalTo(view.snp.leading)
            make.trailing.equalTo(view.snp.trailing)
            make.height.equalTo(40)
        }
        
        for category in categories {
            let button = UIButton(type: .system)
            button.setTitle(category.categoryName, for: .normal)
            button.tintColor = .darkGray
            button.tag = category.categoryId
            button.backgroundColor = .lightGray
            button.addTarget(self, action: #selector(onChangeCategory(sender: )), for: .touchUpInside)
            buttons.append(button)
            stackView.addArrangedSubview(button)
        }
    }
    
    private func setupCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.RF_registerCellWithNib(identifier: String(describing: FoodTypeCell.self), bundle: nil)
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(view.snp.top).offset(40)
            make.leading.equalTo(view.snp.leading)
            make.trailing.equalTo(view.snp.trailing)
            make.bottom.equalTo(view.snp.bottom)
        }
    }
    
    @objc func onChangeCategory(sender: UIButton) {
        print("did tapped category id: \(sender.tag)")
        let selectedCategoryId = sender.tag
        typesOfSelectedCategory = allFoodTypes.filter({ type in
            type.categoryId == selectedCategoryId
        })

    }
    
    private func fetchFoodTypes() {
        Task {
            await firestoreManager.fetchFoodType { result in
                switch result {
                case .success(let foodTypes):
                    allFoodTypes = foodTypes
                    typesOfSelectedCategory = allFoodTypes.filter({ type in
                        type.categoryId == 1
                    })
                    print("已取得所有 foodTypes")
                case .failure(let error):
                    print(error)
                }
            }
        }
    }
}

extension FoodTypeViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return typesOfSelectedCategory.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: FoodTypeCell.self), for: indexPath) as? FoodTypeCell else {
            return UICollectionViewCell()
        }
        let foodType = typesOfSelectedCategory[indexPath.row]
        cell.iconImage.image = UIImage(named: foodType.typeIcon)
        cell.titleLabel.text = foodType.typeName
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let foodType = typesOfSelectedCategory[indexPath.item]
        if let onSelectFoodType = onSelectFoodType {
            onSelectFoodType(foodType)
        }
    }
}
