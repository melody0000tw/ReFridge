//
//  ViewController.swift
//  ReFridge
//
//  Created by Melody Lee on 2024/4/9.
//

import UIKit

class MyFridgeViewController: UIViewController {
    private let firestoreManager = FirestoreManager.shared
    
    var allCards = [FoodCard]()
    
    var showCards = [FoodCard]() {
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
        setupSearchBar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        fetchData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if sender == nil, let foodCardVC = segue.destination as? FoodCardViewController {
            foodCardVC.isAddingMode = true
            return
        }
        
        if let foodCard = sender as? FoodCard,
           let foodCardVC = segue.destination as? FoodCardViewController {
            print("foodcard: \(foodCard)")
            foodCardVC.foodCard = foodCard
            return
        }
        
        if let scanResult = sender as? ScanResult,
           let scanResultVC = segue.destination as? ScanResultViewController {
            scanResultVC.scanResult = scanResult
        }
    }
    
    // MARK: - Setups
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
    
    private func setupSearchBar() {
        let searchController = UISearchController()
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
    }
    
    // MARK: - Data
    private func fetchData() {
        Task {
            await firestoreManager.fetchFoodCard { result in
                switch result {
                case .success(let foodCards):
                    print("got food cards!")
                    self.allCards = foodCards
                    self.showCards = foodCards
                case .failure(let error):
                    print("error: \(error)")
                }
            }
        }
    }
    
    // MARK: - imagePicker
    private func presentImagePicker() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        self.present(picker, animated: true)
    }
}

// MARK: - UICollectionViewDataSource, UICollectionViewDelegate
extension MyFridgeViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        showCards.count + 2
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: FoodCardCell.self), for: indexPath) as? FoodCardCell
        else {
            return UICollectionViewCell()
        }
        
        switch indexPath.item {
        case 0:
            cell.iconImage.image = UIImage(systemName: "plus")
            cell.remainDayLabel.isHidden = true
            cell.nameLabel.text = "新增食物"
        case 1:
            cell.iconImage.image = UIImage(systemName: "doc.viewfinder")
            cell.remainDayLabel.isHidden = true
            cell.nameLabel.text = "掃描收據"
        default:
            let foodCard = showCards[indexPath.item - 2]
            cell.foodCard = foodCard
            cell.setupCell()
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch indexPath.item {
        case 0:
            performSegue(withIdentifier: "showFoodCardVC", sender: nil)
        case 1:
            presentImagePicker()
        default:
            let selectedFoodCard = showCards[indexPath.item - 2]
            performSegue(withIdentifier: "showFoodCardVC", sender: selectedFoodCard)
        }
        
    }
}

// MARK: - UIImagePickerControllerDelegate, UINavigationControllerDelegate
extension MyFridgeViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        // 把資料丟給 text scan manager 處理
        guard let image = info[.originalImage] as? UIImage else { return }
        let scanManager = TextScanManager.shared
        Task {
            scanManager.detectText(in: image, completion: { result in
                guard let scanResult = result else {
                    print("無法辨識圖片")
                    return
                }
                self.performSegue(withIdentifier: "showScanResultVC", sender: scanResult)
                
            })
        }
        picker.dismiss(animated: true)
    }
}

// MARK: - UISearchResultsUpdating, UISearchBarDelegate
extension MyFridgeViewController: UISearchResultsUpdating, UISearchBarDelegate {
    func updateSearchResults(for searchController: UISearchController) {
        if let searchText = searchController.searchBar.text,
           searchText.isEmpty != true {
            let filteredCards = allCards.filter({ card in
                card.name.localizedCaseInsensitiveContains(searchText)
            })
            showCards = filteredCards
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        showCards = allCards
    }
}

