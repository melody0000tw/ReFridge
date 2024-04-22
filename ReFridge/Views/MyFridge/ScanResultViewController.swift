//
//  ScanResultViewController.swift
//  ReFridge
//
//  Created by Melody Lee on 2024/4/15.
//

import UIKit

class ScanResultViewController: UIViewController {
    let formatter = FormatterManager.share.formatter
    let firestoreManager = FirestoreManager.shared
    
    var scanResult: ScanResult?
    
    @IBOutlet weak var notRecongCollectionView: UICollectionView!
    @IBOutlet weak var recongCollectionView: UICollectionView!
    @IBAction func createCards(_ sender: Any) {
        saveData()
    }
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionViews()
    }
    
    // MARK: - Setup
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
    
    // MARK: - Data
    private func saveData() {
        print("save data")
        guard let scanResult = scanResult else {
            return
        }
        
        let dispatchGroup = DispatchGroup()
        for foodCard in scanResult.recongItems {
            dispatchGroup.enter()
            Task {
                await firestoreManager.saveFoodCard(foodCard) { result in
                    switch result {
                    case .success:
                        print("Document successfully written!")
                    case .failure(let error):
                        print("Error adding document: \(error)")
                    }
                }
                dispatchGroup.leave()
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            print("所有小卡都已新增完畢！")
            self.navigationController?.popViewController(animated: true)
        }
    }
    
}

// MARK: - UICollectionViewDataSource, UICollectionViewDelegate
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
            guard let cell = recongCollectionView.dequeueReusableCell(withReuseIdentifier: RecongCell.reuseIdentifier, for: indexPath) as? RecongCell
            else {
                return UICollectionViewCell()
            }
            cell.delegate = self
            let foodCard = scanResult.recongItems[indexPath.item]
//            let item = scanResult.recongItems[indexPath.item]
            cell.scanTextLabel.text = foodCard.name
            
            guard let foodType = FoodTypeData.share.queryFoodType(typeId: foodCard.typeId) else {
                return cell
            }
            cell.iconImage.image = UIImage(named: foodType.typeIcon)
            cell.typeLabel.text = foodType.typeName
            cell.qtyLabel.text = String(foodCard.qty)
            cell.expireDateLabel.text = formatter.string(from: foodCard.expireDate)
            return cell
        } else {
            guard let cell = notRecongCollectionView.dequeueReusableCell(withReuseIdentifier: NotRecongCell.reuseIdentifier, for: indexPath) as? NotRecongCell else {
                return UICollectionViewCell()
            }
            cell.delegate = self
            let item = scanResult.notRecongItems[indexPath.item]
            cell.scanTextLabel.text = item
            return cell
        }
    }
}

// MARK: - RecongCellDelegate
extension ScanResultViewController: RecongCellDelegate, NotRecongCellDelegate {
    func addRecongCell(cell: UICollectionViewCell) {
        guard var scanResult = scanResult,
              let indexPath = notRecongCollectionView.indexPath(for: cell)
        else {
            return
        }
        var text = scanResult.notRecongItems.remove(at: indexPath.item)
        let foodCard = FoodCard(
            cardId: UUID().uuidString,
            name: text,
            categoryId: 5,
            typeId: "501",
            iconName: "other",
            qty: 1, createDate: Date(),
            expireDate: Date().createExpiredDate(afterDays: 7) ?? Date(),
            isRoutineItem: false,
            barCode: "",
            storageType: 0,
            notes: "")
        scanResult.recongItems.insert(foodCard, at: 0)
        self.scanResult = scanResult
        notRecongCollectionView.reloadData()
        recongCollectionView.reloadData()
    }
    
    func deleteRecongCell(cell: UICollectionViewCell) {
        guard var scanResult = scanResult,
              let indexPath = recongCollectionView.indexPath(for: cell)
        else {
            return
        }
        scanResult.recongItems.remove(at: indexPath.item)
        self.scanResult = scanResult
        recongCollectionView.reloadData()
    }
    
    func editRecongCell(cell: UICollectionViewCell) {
        guard let scanResult = scanResult,
              let indexPath = recongCollectionView.indexPath(for: cell)
        else {
            return
        }
        
        let foodCard = scanResult.recongItems[indexPath.item]
        guard let foodCardVC =
                storyboard?.instantiateViewController(withIdentifier: "AddFoodCardViewController") as? AddFoodCardViewController else {
                    print("cannot find foodCardVC")
                    return
                }
        foodCardVC.mode = .editingBatch
        foodCardVC.foodCard = foodCard
        foodCardVC.onChangeFoodCard = { newFoodCard in
            guard var scanResult = self.scanResult else {
                return
            }
            if let index = scanResult.recongItems.firstIndex(where: { $0.cardId == newFoodCard.cardId }) {
                scanResult.recongItems[index] = newFoodCard
                self.scanResult = scanResult
                
                let indexPath = IndexPath(item: index, section: 0)
                self.recongCollectionView.reloadItems(at: [indexPath])
            }
        }
        self.navigationController?.pushViewController(foodCardVC, animated: true)

    }
}
