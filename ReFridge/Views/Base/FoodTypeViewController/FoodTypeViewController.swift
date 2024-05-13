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
            self.collectionView.reloadData()
            if mode == .editing && selectedCategoryId == selectedType.categoryId {
                let indexPath = IndexPath(item: selectedTypeIndex, section: 0)
                collectionView.selectItem(at: indexPath, animated: true, scrollPosition: .centeredVertically)
            }
        }
    }
    
    var mode = FoodCardMode.adding
    
    var onSelectFoodType: ((FoodType) -> Void)?
    
    private var selectedCategoryId = 1
    
    private lazy var selectedType: FoodType = allFoodTypes[0] {
        didSet {
            if let onSelectFoodType = onSelectFoodType {
                onSelectFoodType(selectedType)
            }
        }
    }
    
    var selectedTypeIndex: Int {
        let index = self.typesOfSelectedCategory.firstIndex { foodtype in
            foodtype.typeId == self.selectedType.typeId
        }
        return index ?? 0
    }
    
    private lazy var stackView = UIStackView()
    private lazy var collectionView = UICollectionView(frame: CGRect(), collectionViewLayout: configureLayout())
    private lazy var buttons = [UIButton]()
    private lazy var barView = UIView()
    
    private lazy var deleteTypeBtn = UIButton(type: .system)
    lazy var selectTypeBtn = UIButton(type: .system)

    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupButtons()
        setupCollectionView()
        setupDeleteBtn()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
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
            make.height.equalTo(view.snp.height).multipliedBy(0.15)
        }
        
        for category in categories {
            let button = UIButton(type: .system)
            button.setTitle(category.categoryName, for: .normal)
            button.setTitleColor(.gray, for: .normal)
            button.setTitleColor(.black, for: .selected)
            button.tag = category.categoryId
            button.tintColor = .clear
            button.backgroundColor = .clear
            button.addTarget(self, action: #selector(onChangeCategory(sender: )), for: .touchUpInside)
            button.clipsToBounds = true
            buttons.append(button)
            stackView.addArrangedSubview(button)
        }
        
        if let btn = buttons.first, btn.tag == 1 {
            btn.isSelected = true
        }
        
        // indicator bar
        barView.backgroundColor = .C2
        barView.layer.cornerRadius = 1.5
        view.addSubview(barView)
        let btnWidth = Int(view.bounds.size.width) / stackView.subviews.count
        barView.snp.makeConstraints { make in
            make.bottom.equalTo(stackView)
            make.height.equalTo(3)
            make.width.equalTo(Double(btnWidth) * 0.8)
            make.centerX.equalTo(btnWidth * (selectedCategoryId - 1) + (btnWidth / 2))
        }
    }
    
    private func animateBarView() {
        let btnWidth = Int(stackView.bounds.size.width) / stackView.subviews.count
        barView.snp.remakeConstraints { make in
            make.bottom.equalTo(stackView)
            make.height.equalTo(3)
            make.width.equalTo(Double(btnWidth) * 0.8)
            make.centerX.equalTo(btnWidth * (selectedCategoryId - 1) + (btnWidth / 2))
        }
        UIView.animate(withDuration: 0.2, animations: {
            self.view.layoutIfNeeded()
        })
        
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
        deleteTypeBtn.setTitle("刪除類型", for: .normal)
        deleteTypeBtn.setTitleColor(.darkGray, for: .normal)
        deleteTypeBtn.setTitleColor(.clear, for: .disabled)
        deleteTypeBtn.tintColor = .darkGray
        deleteTypeBtn.backgroundColor = .clear
        deleteTypeBtn.addTarget(self, action: #selector(deleteType), for: .touchUpInside)
        deleteTypeBtn.clipsToBounds = true
        view.addSubview(deleteTypeBtn)
        deleteTypeBtn.snp.makeConstraints { make in
            make.top.equalTo(collectionView.snp.bottom)
            make.height.equalTo(40)
            make.width.equalTo(80)
            make.trailing.equalTo(view.snp.trailing)
        }
    }
    
    // MARK: - Data
    func setupInitialFoodType(typeId: String) {
        let foodType = allFoodTypes.first(where: { type in
            type.typeId == typeId
        })
        guard let foodType = foodType else {
            print("cannot get initial food type")
            return
        }
        
        selectedCategoryId = foodType.categoryId
        selectedType = foodType
        for btn in buttons {
            btn.isSelected = false
            if btn.tag == selectedCategoryId {
                btn.isSelected = true
            }
        }
        animateBarView()
        filterTypes()
    }
    
    @objc func onChangeCategory(sender: UIButton) {
        for button in buttons {
            button.isSelected = false
        }
        sender.isSelected = true
        selectedCategoryId = sender.tag
        animateBarView()
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
        if selectedType.isDeletable {
            Task {
                let docRef = firestoreManager.foodTypesRef.document(selectedType.typeId)
                firestoreManager.deleteDatas(from: docRef) {result in
                    switch result {
                    case .success:
                        self.fetchUserFoodTypes()
                        return
                    case .failure(let error):
                        print(error.localizedDescription)
                    }
                    
                }
            }
        }
    }
    
    func fetchUserFoodTypes() {
        Task {
            let colRef = firestoreManager.foodTypesRef
            firestoreManager.fetchDatas(from: colRef) { [self] (result: Result<[FoodType], Error>) in
                switch result {
                case .success(let foodTypes):
                    userFoodTypes = foodTypes.sorted(by: { lhs, rhs in
                        if let lshTime = lhs.createTime, let rhsTime = rhs.createTime {
                            return lshTime < rhsTime
                        }
                        return lhs.typeName < rhs.typeName
                    })
                    allFoodTypes = defaultFoodTpyes + userFoodTypes
                    DispatchQueue.main.async {
                        self.filterTypes()
                    }
                    
                case .failure(let error):
                    print(error.localizedDescription)
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
            let addTypeVC = AddFoodTypeViewController()
            addTypeVC.categoryId = selectedCategoryId
            addTypeVC.modalPresentationStyle = .automatic
            addTypeVC.foodTypeVCdelegate = self
            self.parent?.present(addTypeVC, animated: true)
        } else {
            selectTypeBtn.isEnabled = true
            selectTypeBtn.backgroundColor = .C2
            let foodType = typesOfSelectedCategory[indexPath.item]
            selectedType = foodType
            toggleDeleteBtn()
        }
    }
}
