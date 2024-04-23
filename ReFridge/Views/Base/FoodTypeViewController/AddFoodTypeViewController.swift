//
//  AddFoodTypeViewController.swift
//  ReFridge
//
//  Created by Melody Lee on 2024/4/19.
//

import UIKit

class AddFoodTypeViewController: UIViewController {
    private let firestoreManager = FirestoreManager.shared
    
    
    let images = ["carrot", "broccoli", "strawberry", "onion", "drink", "lemon", "other", "carrot", "broccoli", "strawberry", "onion", "drink", "lemon", "other", "carrot", "broccoli", "strawberry", "onion", "drink", "lemon", "other", "carrot", "broccoli", "strawberry", "onion", "drink", "lemon", "other", "carrot", "broccoli", "strawberry", "onion", "drink", "lemon", "other", "carrot", "broccoli", "strawberry", "onion", "drink", "lemon", "other"]
    
    lazy var containerView = UIView()
    lazy var imageView = UIImageView()
    lazy var nameLabel = UILabel()
    lazy var nameTextField = UITextField()
    lazy var categoryLabel = UILabel()
    lazy var collectionView = UICollectionView(frame: CGRect(), collectionViewLayout: configureLayout())
    lazy var cancelBtn = UIButton(type: .system)
    lazy var createBtn = UIButton(type: .system)
    
    var selectedImage = "carrot" {
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
    
//    var userFoodTypeCount: Int?
    var foodTypeVCdelegate: FoodTypeViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupCollectionView()
        setupButtons()
        view.backgroundColor = .systemBackground
        // Do any additional setup after loading the view.
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
        containerView.layer.cornerRadius = 5
        view.addSubview(containerView)
        containerView.snp.makeConstraints { make in
            make.top.equalTo(view.snp.top).offset(40)
            make.leading.equalTo(view.snp.leading).offset(24)
            make.trailing.equalTo(view.snp.trailing).offset(-24)
        }
        
        imageView.image = UIImage(named: "carrot")
        imageView.contentMode = .scaleAspectFill
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

            make.leading.equalTo(nameLabel.snp.trailing).offset(8)
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
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(containerView.snp.bottom).offset(24)
            make.leading.equalTo(view.snp.leading).offset(24)
            make.trailing.equalTo(view.snp.trailing).offset(-24)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-80)
//            make.height.equalTo(200)
        }
    }
    
    private func setupButtons() {
        cancelBtn.setTitle("取消", for: .normal)
        cancelBtn.setImage(UIImage(systemName: "xmark"), for: .normal)
        cancelBtn.tintColor = .darkGray
        cancelBtn.addTarget(self, action: #selector(cancelAction), for: .touchUpInside)
        view.addSubview(cancelBtn)
        cancelBtn.snp.makeConstraints { make in
            make.leading.equalTo(view.snp.leading).offset(40)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-40)
        }
        
        createBtn.setTitle("建立", for: .normal)
        createBtn.setImage(UIImage(systemName: "plus"), for: .normal)
        createBtn.tintColor = .darkGray
        createBtn.addTarget(self, action: #selector(createType), for: .touchUpInside)
        view.addSubview(createBtn)
        createBtn.snp.makeConstraints { make in
            make.trailing.equalTo(view.snp.trailing).offset(-40)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-40)
        }
    }
    
    @objc func cancelAction() {
        self.presentingViewController?.dismiss(animated: true)
    }
    
    @objc func createType() {
        guard nameTextField.text != "", let typeName = nameTextField.text else {
            print("名稱不能為空！")
            return
        }
        print("type name: \(typeName), image: \(selectedImage)")
        
        guard let categoryId = categoryId else {
            print("cannot get user food type count")
            return
        }
        
//        let typeId = 1001 + count
        let foodType = FoodType(
            categoryId: categoryId,
            typeId: UUID().uuidString,
            typeName: typeName,
            typeIcon: selectedImage,
            isDeletable: true,
            createTime: Date())
        
        Task {
            await firestoreManager.addUserFoodTypes(foodType: foodType) { result in
                switch result {
                case .success:
                    print("type新增成功！")
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

extension AddFoodTypeViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TypeImageCell.reuseIdentifier, for: indexPath) as? TypeImageCell else {
            return UICollectionViewCell()
        }
        
        let image = images[indexPath.item]
        cell.imageView.image = UIImage(named: image)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let image = images[indexPath.row]
        selectedImage = image
    }
}
