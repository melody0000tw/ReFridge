//
//  AvatarViewController.swift
//  ReFridge
//
//  Created by Melody Lee on 2024/5/2.
//

import UIKit


class AvatarViewController: UIViewController {
    
    private let accountManager = AccountManager.share
    private let firestoreManager = FirestoreManager.shared
    
    enum AvatarMode {
        case setup
        case edit
    }
    
    var mode: AvatarMode = .setup
    
    private let avatars = ["avatar-avocado", "avatar-cookie", "avatar-strawberry", "avatar-hamburger", "avatar-banana", "avatar-broccoli", "avatar-pepper", "avatar-toast", "avatar-egg"]

    private var selectedAvatar: String?
    
    var userInfo: UserInfo?
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBAction func doneButton(_ sender: Any) {
        doneAction()
    }
    
    @IBOutlet weak var nameTextField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectonView()
    }
    
    private func setupCollectonView() {
        collectionView.collectionViewLayout = configureLayout()
        collectionView.dataSource = self
        collectionView.delegate = self
//        collectionView.RF_registerCellWithNib(identifier: TypeImageCell.reuseIdentifier, bundle: nil)
        collectionView.RF_registerCellWithNib(identifier: AvatarCell.reusableIdentifier, bundle: nil)
    }
    
    private func configureLayout() -> UICollectionViewCompositionalLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.33), heightDimension: .fractionalHeight(1))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(0.3))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
//        section.contentInsets = NSDirectionalEdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16)
        return UICollectionViewCompositionalLayout(section: section)
    }
    
    private func doneAction() {
        // update userInfo
        
        if let name = nameTextField.text, nameTextField.text != "", let avatar = selectedAvatar {
            print("name\(name), avatar: \(avatar)")
            
            guard var userInfo = userInfo else {
                print("cannot get userInfo")
                return
            }
            
            userInfo.name = name
            userInfo.avatar = avatar
            
            Task {
                await firestoreManager.updateUserInfo(userInfo: userInfo) { result in
                    switch result {
                    case .success:
                        print("修改成功！")
                        // 判斷模式
                        DispatchQueue.main.async { [self] in
                            if mode == .edit {
                                presentingViewController?.dismiss(animated: true)
                            } else {
                                presentMyFridgeVC()
                            }
                        }
                    case .failure(let error):
                        print(error.localizedDescription)
                    }
                    
                }
            }
        }
    }
    
    private func presentMyFridgeVC() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let initialViewController = storyboard.instantiateInitialViewController() {
            initialViewController.modalPresentationStyle = .fullScreen
            present(initialViewController, animated: true)
        }
    }
    
}

// MARK: - UICollectionViewDataSource, UICollectionViewDelegate
extension AvatarViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        9
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AvatarCell.reusableIdentifier, for: indexPath) as? AvatarCell else {
            return UICollectionViewCell()
        }
        let avatar = avatars[indexPath.row]
        cell.imageView.image = UIImage(named: avatar)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedAvatar = avatars[indexPath.row]
    }
}
