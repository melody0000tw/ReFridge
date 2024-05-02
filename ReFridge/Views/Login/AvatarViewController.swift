//
//  AvatarViewController.swift
//  ReFridge
//
//  Created by Melody Lee on 2024/5/2.
//

import UIKit

class AvatarViewController: UIViewController {
    
    private let avatars = ["avatar-avocado", "avatar-cookie", "avatar-strawberry", "avatar-hamburger", "avatar-banana", "avatar-broccoli", "avatar-pepper", "avatar-toast", "avatar-egg"]

    private var selectedAvatar: String?
    
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
        collectionView.RF_registerCellWithNib(identifier: TypeImageCell.reuseIdentifier, bundle: nil)
    }
    
    private func configureLayout() -> UICollectionViewCompositionalLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.3), heightDimension: .fractionalHeight(1))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(0.3))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16)
        return UICollectionViewCompositionalLayout(section: section)
    }
    
    private func doneAction() {
        if let name = nameTextField.text, nameTextField.text != "", let avatar = selectedAvatar {
            print("name\(name), avatar: \(avatar)")
            presentMyFridgeVC()
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
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TypeImageCell.reuseIdentifier, for: indexPath) as? TypeImageCell else {
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
