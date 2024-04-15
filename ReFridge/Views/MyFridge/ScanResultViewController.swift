//
//  ScanResultViewController.swift
//  ReFridge
//
//  Created by Melody Lee on 2024/4/15.
//

import UIKit

class ScanResultViewController: UIViewController {
    
    var scanResult: ScanResult? {
        didSet {
            print("scan vc did get scanResult: \(String(describing: scanResult))")
        }
    }
    
    @IBOutlet weak var notRecongCollectionView: UICollectionView!
    @IBOutlet weak var recongCollectionView: UICollectionView!
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionViews()

    }
    
    private func setupCollectionViews() {
        recongCollectionView.dataSource = self
        recongCollectionView.delegate = self
        recongCollectionView.collectionViewLayout = configureRecogLayout()
        notRecongCollectionView.dataSource = self
        notRecongCollectionView.delegate = self
        notRecongCollectionView.collectionViewLayout = configureNotRecogLayout()
    }
    
    private func configureRecogLayout() -> UICollectionViewCompositionalLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(0.4))
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
        group.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 8, bottom: 0, trailing: 8)
        let section = NSCollectionLayoutSection(group: group)
        return UICollectionViewCompositionalLayout(section: section)
    }
    
    private func configureNotRecogLayout() -> UICollectionViewCompositionalLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalWidth(1))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.4), heightDimension: .fractionalHeight(1))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        group.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 0)
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .continuous
        return UICollectionViewCompositionalLayout(section: section)
    }
}

extension ScanResultViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let scanResult = scanResult else {
            return 0
        }
        if collectionView == recongCollectionView {
            return scanResult.recongItems.count
        } else {
            return scanResult.notRecongItems.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let scanResult = scanResult else {
            return UICollectionViewCell()
        }
        if collectionView == recongCollectionView {
            guard let cell = recongCollectionView.dequeueReusableCell(withReuseIdentifier: RecongCell.reuseIdentifier, for: indexPath) as? RecongCell else {
                return UICollectionViewCell()
            }
            let item = scanResult.recongItems[indexPath.item]
            cell.scanTextLabel.text = item.text
            return cell
        } else {
            guard let cell = notRecongCollectionView.dequeueReusableCell(withReuseIdentifier: NotRecongCell.reuseIdentifier, for: indexPath) as? NotRecongCell else {
                return UICollectionViewCell()
            }
            let item = scanResult.notRecongItems[indexPath.item]
            cell.scanTextLabel.text = item.text
            return cell
        }
    }
}
