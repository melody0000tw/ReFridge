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
    
    private var userFoodTypes = [FoodType]()
    private var defaultFoodTpyes = FoodTypeData.share.data
    private var allFoodTypes: [FoodType] = FoodTypeData.share.data
    private lazy var typesOfSelectedCategory: [FoodType] = allFoodTypes.filter({ type in
        type.categoryId == selectedCategoryId
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
    
    lazy var stackView = UIStackView()
    lazy var collectionView = UICollectionView(frame: CGRect(), collectionViewLayout: configureLayout())
    lazy var buttons = [UIButton]()
    
    lazy var deleteTypeBtn = UIButton(type: .system)

    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupButtons()
        setupCollectionView()
        setupDeleteBtn()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print(" viewWillAppear")
        fetchUserFoodTypes()
        toggleDeleteBtn()
    }
    
    // MARK: - Setups
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
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 0
        view.addSubview(stackView)
        
        stackView.snp.makeConstraints { make in
            make.top.equalTo(view.snp.top)
            make.leading.equalTo(view.snp.leading)
            make.trailing.equalTo(view.snp.trailing)
//            make.height.equalTo(40)
            make.height.equalTo(view.snp.height).multipliedBy(0.15)
        }
        
        for category in categories {
            let button = UIButton(type: .system)
            button.setTitle(category.categoryName, for: .normal)
            button.tintColor = .T1
            button.tag = category.categoryId
            button.backgroundColor = .C1
            button.addTarget(self, action: #selector(onChangeCategory(sender: )), for: .touchUpInside)
            button.clipsToBounds = true
            buttons.append(button)
            stackView.addArrangedSubview(button)
        }
    }
    
    private func setupCollectionView() {
        collectionView.backgroundColor = .clear
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.RF_registerCellWithNib(identifier: String(describing: FoodTypeCell.self), bundle: nil)
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(stackView.snp.bottom)
            make.leading.equalTo(view.snp.leading)
            make.trailing.equalTo(view.snp.trailing)
            make.bottom.equalTo(view.snp.bottom).offset(-40)
        }
    }
    
    private func setupDeleteBtn() {
        deleteTypeBtn.setTitle(" 刪除類型", for: .normal)
        deleteTypeBtn.setTitleColor(.darkGray, for: .normal)
        deleteTypeBtn.setTitleColor(.clear, for: .disabled)
        deleteTypeBtn.tintColor = .darkGray
        deleteTypeBtn.backgroundColor = .clear
        deleteTypeBtn.addTarget(self, action: #selector(deleteType), for: .touchUpInside)
        deleteTypeBtn.clipsToBounds = true
        view.addSubview(deleteTypeBtn)
        deleteTypeBtn.snp.makeConstraints { make in
            make.top.equalTo(collectionView.snp.bottom)
            make.height.equalTo(view.snp.height).multipliedBy(0.15)
            make.trailing.equalTo(view.snp.trailing).offset(-16)
        }
    }
    
    // MARK: - Data
    @objc func onChangeCategory(sender: UIButton) {
        print("did tapped category id: \(sender.tag)")
        selectedCategoryId = sender.tag
        filterTypes()
    }
    
    private func filterTypes() {
        typesOfSelectedCategory = allFoodTypes.filter({ type in
            type.categoryId == selectedCategoryId
        })
    }
    
    private func toggleDeleteBtn() {
        deleteTypeBtn.isEnabled = false
        if selectedType.isDeletable {
            deleteTypeBtn.isEnabled = true
        }
    }
    
    @objc func deleteType() {
        print("deleteType tapped")
        if selectedType.isDeletable {
            Task {
                await firestoreManager.deleteUserFoodTypes(typeId: selectedType.typeId) { result in
                    switch result {
                    case .success(let foodTypes):
                        self.fetchUserFoodTypes()
                        print("已刪除foodTypes")
                    case .failure(let error):
                        print(error)
                    }
                }
            }
        }
    }
    
    func fetchUserFoodTypes() {
        Task {
            await firestoreManager.fetchFoodType { result in
                switch result {
                case .success(let foodTypes):
                    
                    userFoodTypes = foodTypes.sorted(by: { lhs, rhs in
                        if let lshTime = lhs.createTime, let rhsTime = rhs.createTime {
                            return lshTime < rhsTime
                        }
                        return lhs.typeName < rhs.typeName
                    })
                    allFoodTypes = defaultFoodTpyes + userFoodTypes
                    filterTypes()
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
            addTypeVC.foodTypeVCdelegate = self
            self.parent?.present(addTypeVC, animated: true)
        } else {
            let foodType = typesOfSelectedCategory[indexPath.item]
            selectedType = foodType
            toggleDeleteBtn()
            if let onSelectFoodType = onSelectFoodType {
                onSelectFoodType(foodType)
            }
        }
    }
}
