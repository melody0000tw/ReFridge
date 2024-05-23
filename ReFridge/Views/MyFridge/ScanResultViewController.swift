//
//  ScanResultViewController.swift
//  ReFridge
//
//  Created by Melody Lee on 2024/4/15.
//

import UIKit

class ScanResultViewController: UIViewController {
    var viewModel = ScanResultViewModel(scanResult: ScanResult(recongItems: [], notRecongItems: []))
    
    let formatter = FormatterManager.share.formatter
    
    let saveBtn = UIBarButtonItem()
    let closeBtn = UIBarButtonItem()
    
    @IBOutlet weak var notRecongViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var recongView: UIView!
    
    @IBOutlet weak var notRecongLabel: UILabel!
    @IBOutlet weak var notRecongView: UIView!
    @IBOutlet weak var notRecongCollectionView: UICollectionView!
    @IBOutlet weak var recongCollectionView: UICollectionView!
    @IBAction func createCards(_ sender: Any) {
        saveData()
    }
    
    lazy var recongEmptyDataManager = EmptyDataManager(view: recongView, emptyMessage: "未偵測到食物相關單詞")
    lazy var notRecongEmptyDataManager = EmptyDataManager(view: notRecongView, emptyMessage: "未偵測到其他單詞")
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionViews()
        setupNavigationView()
        setupViews()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true
        toggleEmptyLabels()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tabBarController?.tabBar.isHidden = false
    }
    
    // MARK: - Setup
    private func setupNavigationView() {
        saveBtn.tintColor = .C2
        saveBtn.image = UIImage(systemName: "checkmark")
        saveBtn.target = self
        saveBtn.action = #selector(saveData)
        navigationItem.rightBarButtonItem = saveBtn
        closeBtn.tintColor = .C2
        closeBtn.image = UIImage(systemName: "xmark")
        closeBtn.target = self
        closeBtn.action = #selector(closePage)
        navigationItem.backBarButtonItem?.isHidden = true
        navigationItem.leftBarButtonItem = closeBtn
    }
    
    private func setupViews() {
        notRecongView.layer.cornerRadius = 24
        notRecongView.dropShadow(scale: true, radius: 5)
        
        let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(toggleNotRecongView(_:)))
        swipeUp.direction = .up
        swipeUp.numberOfTouchesRequired = 1
        
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(toggleNotRecongView(_:)))
        swipeDown.direction = .down
        swipeDown.numberOfTouchesRequired = 1
        
        notRecongView.addGestureRecognizer(swipeUp)
        notRecongView.addGestureRecognizer(swipeDown)
        notRecongViewTopConstraint.constant = -120
        notRecongLabel.text = "上滑顯示更多單詞"
    }
    
    @objc func toggleNotRecongView(_ sender: UISwipeGestureRecognizer) {
        if sender.direction == .up {
            notRecongViewTopConstraint.constant = -280
            notRecongLabel.text = "下滑隱藏更多單詞"
            UIView.animate(withDuration: 0.3) {
                self.view.layoutIfNeeded()
            }
        } else if sender.direction == .down {
            notRecongViewTopConstraint.constant = -120
            notRecongLabel.text = "上滑顯示更多單詞"
            UIView.animate(withDuration: 0.3) {
                self.view.layoutIfNeeded()
            }
        }
    }
    
    private func setupCollectionViews() {
        recongCollectionView.dataSource = self
        recongCollectionView.delegate = self
        recongCollectionView.RF_registerCellWithNib(identifier: RecongCell.reuseIdentifier, bundle: nil)
        recongCollectionView.collectionViewLayout = configureRecogLayout()
        
        notRecongCollectionView.dataSource = self
        notRecongCollectionView.delegate = self
        notRecongCollectionView.RF_registerCellWithNib(identifier: NotRecongCell.reuseIdentifier, bundle: nil)
        notRecongCollectionView.collectionViewLayout = configureNotRecogLayout()
    }
    
    private func configureRecogLayout() -> UICollectionViewCompositionalLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(160))
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
        group.contentInsets = NSDirectionalEdgeInsets.zero
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 80, trailing: 0)
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
    
    private func toggleEmptyLabels() {
        let result = viewModel.scanResult
        recongEmptyDataManager.toggleLabel(shouldShow: (result.recongItems.count == 0))
        notRecongEmptyDataManager.toggleLabel(shouldShow: (result.notRecongItems.count == 0))
    }
    
    // MARK: - Coordinator
    func presentAddFoodCardVC(foodCard: FoodCard) {
        guard let addFoodCardVC =
                storyboard?.instantiateViewController(withIdentifier: "AddFoodCardViewController") as? AddFoodCardViewController else {
                    print("cannot find foodCardVC")
                    return
                }
        addFoodCardVC.mode = .editingBatch
        addFoodCardVC.viewModel = AddFoodCardViewModel(foodCard: foodCard)
        addFoodCardVC.onChangeFoodCard = { newCard in
            self.viewModel.updateRecogCard(newCard: newCard) {
                self.recongCollectionView.reloadData()
                self.toggleEmptyLabels()
            }
        }
        self.navigationController?.pushViewController(addFoodCardVC, animated: true)
    }
    
    // MARK: - Data
    @objc func saveData() {
        viewModel.saveFoodCards { result in
            DispatchQueue.main.async {
                switch result {
                case .success():
                    print("Documents successfully written!")
                    self.navigationController?.popViewController(animated: true)
                case .failure(let error):
                    print("error: \(error)")
                    self.navigationController?.popViewController(animated: true)
                }
            }
        }
    }
    
    @objc func closePage() {
        self.navigationController?.popViewController(animated: true)
    }
    
}

// MARK: - UICollectionViewDataSource, UICollectionViewDelegate
extension ScanResultViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let scanResult = viewModel.scanResult
        if collectionView == recongCollectionView {
            return scanResult.recongItems.count
        } else {
            return scanResult.notRecongItems.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let scanResult = viewModel.scanResult
        if collectionView == recongCollectionView {
            guard let cell = recongCollectionView.dequeueReusableCell(withReuseIdentifier: RecongCell.reuseIdentifier, for: indexPath) as? RecongCell
            else {
                return UICollectionViewCell()
            }
            cell.delegate = self
            let foodCard = scanResult.recongItems[indexPath.item]
            cell.scanTextLabel.text = foodCard.name
            cell.iconImage.image = UIImage(named: foodCard.iconName)
            cell.typeLabel.text = CategoryData.share.queryFoodCategory(categoryId: foodCard.categoryId)?.categoryName
            cell.qtyLabel.text = "\(String(foodCard.qty))\(foodCard.mesureWord)"
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
        guard let index = notRecongCollectionView.indexPath(for: cell)?.row else {
            print("cannot find index path of cell")
            return
        }
        
        viewModel.addRecogCard(withNotRecogAt: index) { [self] in
            notRecongCollectionView.reloadData()
            recongCollectionView.reloadData()
            toggleEmptyLabels()
        }
    }
    
    func deleteRecongCell(cell: UICollectionViewCell) {
        guard let index = recongCollectionView.indexPath(for: cell)?.row else {
            print("cannot find index path of cell")
            return
        }
        viewModel.deleteRecogCard(at: index) { [self] in
            recongCollectionView.reloadData()
            toggleEmptyLabels()
        }
    }
    
    func editRecongCell(cell: UICollectionViewCell) {
        guard let index = recongCollectionView.indexPath(for: cell)?.row else {
            print("cannot find index path of cell")
            return
        }
        let foodCard = viewModel.scanResult.recongItems[index]
        presentAddFoodCardVC(foodCard: foodCard)
    }
}
