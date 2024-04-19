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
    
    private let categories = CategoryData.share.data
    private var allFoodTypes: [FoodType] = FoodTypeData.share.data
    private lazy var typesOfSelectedCategory: [FoodType] = allFoodTypes.filter({ type in
        type.categoryId == 1
    }) {
        didSet {
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        }
    }
    
    var onSelectFoodType: ((FoodType) -> Void)?
    
    var selectedCategoryId = 1
    lazy var selectedType: FoodType = allFoodTypes[0]
    
    var userFoodTypes = [FoodType]()

    lazy var collectionView = UICollectionView(frame: CGRect(), collectionViewLayout: configureLayout())
    lazy var buttons = [UIButton]()
    
    lazy var deleteTypeBtn = UIButton(type: .system)
    lazy var selectTypeBtn = UIButton(type: .system)

    override func viewDidLoad() {
        super.viewDidLoad()
        setupButtons()
        setupCollectionView()
        fetchUserFoodTypes()
        setupDeleteBtn()
        setupSelectionBtn()
//        fetchFoodTypes()
    }
    
    private func configureLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 60, height: 80)
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
            make.bottom.equalTo(view.snp.bottom).offset(-50)
        }
    }
    
    private func setupDeleteBtn() {
        deleteTypeBtn.setTitle("刪除選取類型", for: .normal)
        deleteTypeBtn.setImage(UIImage(systemName: "trash"), for: .normal)
        deleteTypeBtn.tintColor = .darkGray
        deleteTypeBtn.addTarget(self, action: #selector(deleteType), for: .touchUpInside)
        view.addSubview(deleteTypeBtn)
        deleteTypeBtn.snp.makeConstraints { make in
            make.leading.equalTo(view.snp.leading).offset(16)
            make.bottom.equalTo(view.snp.bottom).offset(-16)
        }
    }
    
    private func setupSelectionBtn() {
        selectTypeBtn.setTitle("選取此類型", for: .normal)
        selectTypeBtn.setImage(UIImage(systemName: "checkmark"), for: .normal)
        selectTypeBtn.tintColor = .darkGray
        selectTypeBtn.addTarget(self, action: #selector(selectType), for: .touchUpInside)
        view.addSubview( selectTypeBtn)
        selectTypeBtn.snp.makeConstraints { make in
            make.trailing.equalTo(view.snp.trailing).offset(-16)
            make.bottom.equalTo(view.snp.bottom).offset(-16)
        }
    }
    
    @objc func onChangeCategory(sender: UIButton) {
        print("did tapped category id: \(sender.tag)")
        selectedCategoryId = sender.tag
        typesOfSelectedCategory = allFoodTypes.filter({ type in
            type.categoryId == selectedCategoryId
        })

    }
    
    @objc func deleteType() {
        print("deleteType tapped")
    }
    
    @objc func selectType() {
        print("selectType: \(selectedType)")
        if let onSelectFoodType = onSelectFoodType {
            onSelectFoodType(selectedType)
        }
    }
    
    // 用不到
//    private func fetchFoodTypes() {
//        Task {
//            await firestoreManager.fetchFoodType { result in
//                switch result {
//                case .success(let foodTypes):
//                    allFoodTypes = foodTypes
//                    typesOfSelectedCategory = allFoodTypes.filter({ type in
//                        type.categoryId == 1
//                    })
//                    print("已取得所有 foodTypes")
//                case .failure(let error):
//                    print(error)
//                }
//            }
//        }
//    }
    
    private func fetchUserFoodTypes() {
        Task {
            await firestoreManager.fetchFoodType { result in
                switch result {
                case .success(let foodTypes):
                    userFoodTypes = foodTypes
                    allFoodTypes += foodTypes
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
        return typesOfSelectedCategory.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: FoodTypeCell.self), for: indexPath) as? FoodTypeCell else {
            return UICollectionViewCell()
        }
        
        if indexPath.row == typesOfSelectedCategory.count {
            // 顯示++
            cell.iconImage.image = UIImage(systemName: "plus")
            cell.titleLabel.text = "新增類型"
        } else {
            let foodType = typesOfSelectedCategory[indexPath.row]
            cell.iconImage.image = UIImage(named: foodType.typeIcon)
            cell.titleLabel.text = foodType.typeName
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.row == typesOfSelectedCategory.count {
            print("以點擊新增種類")
            let addTypeVC = AddFoodTypeViewController()
            addTypeVC.categoryId = selectedCategoryId
            addTypeVC.modalPresentationStyle = .automatic
            addTypeVC.userFoodTypeCount = userFoodTypes.count
            self.parent?.present(addTypeVC, animated: true)
        } else {
            let foodType = typesOfSelectedCategory[indexPath.item]
            selectedType = foodType
//            if let onSelectFoodType = onSelectFoodType {
//                onSelectFoodType(foodType)
//            }
        }
    }
}
