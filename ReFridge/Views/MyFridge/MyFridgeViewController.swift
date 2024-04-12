//
//  ViewController.swift
//  ReFridge
//
//  Created by Melody Lee on 2024/4/9.
//

import UIKit

class MyFridgeViewController: UIViewController {
    private let firestoreManager = FirestoreManager.shared
    var foodCards = [FoodCard]() {
        didSet {
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        }
    }
    @IBOutlet weak var collectionView: UICollectionView!
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        print("123")
        setupCollectionView()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        Task {
            await fetchData()
        }
    }
    
    // MARK: - Private function
    private func setupCollectionView() {
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.RF_registerCellWithNib(identifier: String(describing: FoodCardCell.self), bundle: nil)
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 100, height: 100)
        layout.minimumLineSpacing = 16
        layout.minimumInteritemSpacing = 8
        layout.sectionInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        collectionView.collectionViewLayout = layout
    }
    
    private func fetchData() async {
        await firestoreManager.fetchFoodCard { result in
            switch result {
            case .success(let foodCards):
                print("got food cards! \(foodCards)")
                self.foodCards = foodCards
            case .failure(let error):
                print("error: \(error)")
            }
        }
    }
    
    private func arrangeByRemainingDay() {
        
    }
    
}

extension MyFridgeViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        foodCards.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: FoodCardCell.self), for: indexPath) as? FoodCardCell
        else {
            return UICollectionViewCell()
        }
        let foodCard = foodCards[indexPath.item]
        cell.foodCard = foodCard
        cell.setupCell()
        
        return cell
    }
    
}
