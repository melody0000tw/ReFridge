//
//  AddFoodTypeViewController.swift
//  ReFridge
//
//  Created by Melody Lee on 2024/4/19.
//

import UIKit

class AddFoodTypeViewController: UIViewController {
    private let firestoreManager = FirestoreManager.shared
    
    let datas = [
        ["spinach", "broccoli", "asparagus", "eggplant", "cabbage", "carrot", "green-pepper", "chili-pepper", "onion", "mashroom", "apple", "avocado", "cherry", "lemon", "pear", "banana"],
        ["egg", "meat", "sausage", "chicken", "fish", "shrimp", "milk", "cheese"],
        ["cookie", "cupcake", "cake", "donut", "croissant", "toast", "drink", "icecream", "popsicle", "popcorn"],
        ["other", "sandwich", "fries", "pizza", "hamburger", "taco", "noodles", "soup"]
    ]
    
    lazy var containerView = UIView()
    lazy var imageView = UIImageView()
    lazy var nameLabel = UILabel()
    lazy var nameTextField = UITextField()
    lazy var categoryLabel = UILabel()
    lazy var collectionView = UICollectionView(frame: CGRect(), collectionViewLayout: configureLayout())
    lazy var cancelBtn = UIButton(type: .system)
    lazy var createBtn = UIButton(type: .system)
    
    var selectedImage = "spinach" {
        didSet {
            DispatchQueue.main.async {
                self.imageView.image = UIImage(named: self.selectedImage)
            }
        }
    }
    
    var categoryId: Int? {
        didSet {
            DispatchQueue.main.async {
                guard let categoryId = self.categoryId,
                      let category = CategoryData.share.queryFoodCategory(categoryId: categoryId)
                else {
                    print("cannot get category")
                    return
                }
                self.categoryLabel.text = "類別: \(category.categoryName)"
            }
        }
    }
    
    var foodTypeVCdelegate: FoodTypeViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupCollectionView()
        setupButtons()
        view.backgroundColor = .systemBackground
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        collectionView.selectItem(at: IndexPath(item: 0, section: 0), animated: false, scrollPosition: .centeredVertically)
    }
    
    private func configureLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 60, height: 60)
        layout.minimumLineSpacing = 16
        layout.minimumInteritemSpacing = 8
        layout.sectionInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        layout.sectionHeadersPinToVisibleBounds = true
        return layout
    }
    
    private func setupViews() {
        containerView.backgroundColor = .C1
        containerView.layer.cornerRadius = 16
        view.addSubview(containerView)
        containerView.snp.makeConstraints { make in
            make.top.equalTo(view.snp.top).offset(40)
            make.leading.equalTo(view.snp.leading).offset(24)
            make.trailing.equalTo(view.snp.trailing).offset(-24)
        }
        
        imageView.image = UIImage(named: "spinach")
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        containerView.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.leading.equalTo(containerView.snp.leading).offset(16)
            make.centerY.equalTo(containerView.snp.centerY)
            make.height.width.equalTo(60)
        }
        
        nameLabel.text = "名稱"
        nameLabel.font = UIFont.systemFont(ofSize: 16)
        nameLabel.textAlignment = .left
        nameLabel.textColor = .darkGray
        nameLabel.numberOfLines = 1
        nameLabel.sizeToFit()
        containerView.addSubview(nameLabel)
        nameLabel.snp.makeConstraints { make in
            make.top.equalTo(containerView.snp.top).offset(24)
            make.leading.equalTo(imageView.snp.trailing).offset(16)
        }
        nameLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        
        nameTextField.placeholder = "請輸入種類名稱"
        nameTextField.borderStyle = .roundedRect
        nameTextField.setContentHuggingPriority(.defaultLow, for: .horizontal)
        containerView.addSubview(nameTextField)
        nameTextField.snp.makeConstraints { make in
            make.leading.equalTo(nameLabel.snp.trailing).offset(16)
            make.trailing.equalTo(containerView.snp.trailing).offset(-16)
            make.centerY.equalTo(nameLabel.snp.centerY)
        }
        
        categoryLabel.text = "類別: 蔬菜"
        categoryLabel.font = UIFont.systemFont(ofSize: 16)
        categoryLabel.textAlignment = .left
        categoryLabel.textColor = .darkGray
        categoryLabel.numberOfLines = 1
        categoryLabel.sizeToFit()
        containerView.addSubview(categoryLabel)
        categoryLabel.snp.makeConstraints { make in
            make.top.equalTo( nameTextField.snp.bottom).offset(16)
            make.leading.equalTo(imageView.snp.trailing).offset(16)
            make.bottom.equalTo(containerView.snp.bottom).offset(-24)
        }
    }
    
    private func setupCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.RF_registerCellWithNib(identifier: String(describing: TypeImageCell.self), bundle: nil)
        collectionView.register(TypeImageHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: TypeImageHeaderView.reuseIdentifier)
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(containerView.snp.bottom).offset(24)
            make.leading.equalTo(view.snp.leading).offset(24)
            make.trailing.equalTo(view.snp.trailing).offset(-24)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-80)
        }
    }
    
    private func setupButtons() {
        cancelBtn.setTitle("取消", for: .normal)
        cancelBtn.setImage(UIImage(systemName: "xmark"), for: .normal)
        cancelBtn.tintColor = .darkGray
        cancelBtn.addTarget(self, action: #selector(cancelAction), for: .touchUpInside)
        view.addSubview(cancelBtn)
        cancelBtn.snp.makeConstraints { make in
            make.top.equalTo(collectionView.snp.bottom).offset(16)
            make.leading.equalTo(view.snp.leading).offset(40)
            make.width.equalTo(80)
            make.height.equalTo(40)
        }
        
        createBtn.setTitle("建立", for: .normal)
        createBtn.setTitleColor(.darkGray, for: .normal)
        createBtn.setImage(UIImage(systemName: "plus"), for: .normal)
        createBtn.backgroundColor = .C1
        createBtn.tintColor = .darkGray
        createBtn.layer.cornerRadius = 8
        createBtn.addTarget(self, action: #selector(createType), for: .touchUpInside)
        view.addSubview(createBtn)
        createBtn.snp.makeConstraints { make in
            make.top.equalTo(collectionView.snp.bottom).offset(16)
            make.trailing.equalTo(view.snp.trailing).offset(-40)
            make.width.equalTo(80)
            make.height.equalTo(40)
            
        }
    }
    
    @objc func cancelAction() {
        self.presentingViewController?.dismiss(animated: true)
    }
    
    @objc func createType() {
        guard nameTextField.text != "", let typeName = nameTextField.text else {
            presentAlert(title: "未填寫完整", description: "類型名稱未填寫", image: UIImage(systemName: "xmark.circle"))
            return
        }
        
        guard let categoryId = categoryId else {
            print("cannot get user food type count")
            return
        }
        
        let foodType = FoodType(
            categoryId: categoryId,
            typeId: UUID().uuidString,
            typeName: typeName,
            typeIcon: selectedImage,
            isDeletable: true,
            createTime: Date())
        
        Task {
            let docRef = firestoreManager.foodTypesRef.document(foodType.typeId)
            firestoreManager.updateDatas(to: docRef, with: foodType) { [self] result in
                switch result {
                case .success:
                    foodTypeVCdelegate?.fetchUserFoodTypes()
                    DispatchQueue.main.async {
                        self.presentingViewController?.dismiss(animated: true)
                    }
                    
                case .failure(let error):
                    print("error: \(error)")
                }
            }
        }
    }
}

extension AddFoodTypeViewController: UICollectionViewDelegate, UICollectionViewDataSource,  UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return datas.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return datas[section].count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TypeImageCell.reuseIdentifier, for: indexPath) as? TypeImageCell else {
            return UICollectionViewCell()
        }
        let image = datas[indexPath.section][indexPath.row]
        cell.imageView.image = UIImage(named: image)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: 50)
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionHeader else {
                return UICollectionReusableView()
            }
        let headers = ["蔬菜水果", "蛋白質", "點心", "其他"]
        guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: TypeImageHeaderView.reuseIdentifier, for: indexPath) as? TypeImageHeaderView else {
            return UICollectionReusableView()
        }
        header.label.text = headers[indexPath.section]
        return header
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let image = datas[indexPath.section][indexPath.row]
        selectedImage = image
    }
}
