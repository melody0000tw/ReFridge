//
//  ViewController.swift
//  ReFridge
//
//  Created by Melody Lee on 2024/4/9.
//

import UIKit
import VisionKit
import Vision

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
    
    var cardFilter = CardFilter(categoryId: nil, sortBy: .remainingDay) {
        didSet {
            filterFoodCards()
        }
    }
    
    @IBOutlet weak var filterBarButton: UIBarButtonItem!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBAction func searchByBarCode(_ sender: Any) {
        print("search by bar code")
        let documentCameraViewController = VNDocumentCameraViewController()
        documentCameraViewController.delegate = self
        present(documentCameraViewController, animated: true)
    }
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        print("123")
        setupCollectionView()
        setupSearchBar()
        setupFilterBtn()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        fetchData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
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
    
    private func setupFilterBtn() {
        filterBarButton.primaryAction = nil
        let filterMenu = UIMenu(title: "食物類型", options: .singleSelection, children: [
            UIAction(title: "全部", handler: { _ in
                self.cardFilter.categoryId = nil
            }),
            UIAction(title: "蔬菜", handler: { _ in
                self.cardFilter.categoryId = 1
            }),
            UIAction(title: "水果", handler: { _ in
                self.cardFilter.categoryId = 2
            }),
            UIAction(title: "蛋白質", handler: { _ in
                self.cardFilter.categoryId = 3
            }),
            UIAction(title: "穀物", handler: { _ in
                self.cardFilter.categoryId = 4
            }),
            UIAction(title: "其他", handler: { _ in
                self.cardFilter.categoryId = 5
            })
        ])
        
        let arrangeMenu = UIMenu(title: "排序方式", options: .singleSelection, children: [
            UIAction(title: "依照剩餘天數", handler: { _ in
                self.cardFilter.sortBy = .remainingDay
            }),
            UIAction(title: "依照加入日期", handler: { _ in
                self.cardFilter.sortBy = .createDay
            }),
            UIAction(title: "依照種類", handler: { _ in
                self.cardFilter.sortBy = .category
            })
        ])
        
        filterBarButton.menu = UIMenu(children: [ filterMenu, arrangeMenu ])
    }
    
    private func searchBarCode() {
        
    }
    
    // MARK: - Data
    private func fetchData() {
        Task {
            await firestoreManager.fetchFoodCard { result in
                switch result {
                case .success(let foodCards):
                    print("got food cards!")
                    self.allCards = foodCards
                    filterFoodCards()
                case .failure(let error):
                    print("error: \(error)")
                }
            }
        }
    }
    
    private func filterFoodCards() {
        // filter
        var filteredCards = [FoodCard]()
        if let categoryId = cardFilter.categoryId {
            filteredCards = allCards.filter { card in
                card.categoryId == categoryId
            }
        } else {
            filteredCards = allCards
        }
        
        // sort
        let sortBy = cardFilter.sortBy
        switch sortBy {
        case .remainingDay:
            filteredCards.sort { lhs, rhs in
                lhs.expireDate.calculateRemainingDays() ?? 0 <= rhs.expireDate.calculateRemainingDays() ?? 0
            }
        case .createDay:
            filteredCards.sort { lhs, rhs in
                lhs.createDate >= rhs.createDate
            }
        case .category:
            filteredCards.sort { lhs, rhs in
                lhs.categoryId <= rhs.categoryId
            }
        }
        
        showCards = filteredCards
    }
    
    private func searchFoodCard(barCode: String) {
        let filteredFoodCards = allCards.filter { foodCard in
            foodCard.barCode == barCode
        }
        showCards = filteredFoodCards
        
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
            guard let foodCardVC =
                    storyboard?.instantiateViewController(withIdentifier: "AddFoodCardViewController") as? AddFoodCardViewController else {
                        print("cannot find foodCardVC")
                        return
                    }
            foodCardVC.mode = .adding
            self.navigationController?.pushViewController(foodCardVC, animated: true)
        case 1:
            presentImagePicker()
        default:
            let selectedFoodCard = showCards[indexPath.item - 2]
            guard let foodCardVC =
                    storyboard?.instantiateViewController(withIdentifier: "AddFoodCardViewController") as? AddFoodCardViewController else {
                        print("cannot find foodCardVC")
                        return
                    }
            foodCardVC.mode = .editing
            foodCardVC.foodCard = selectedFoodCard
            self.navigationController?.pushViewController(foodCardVC, animated: true)
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

// MARK: - BarCode
extension MyFridgeViewController: VNDocumentCameraViewControllerDelegate {
    func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFinishWith scan: VNDocumentCameraScan) {
            let image = scan.imageOfPage(at: scan.pageCount - 1)
            dismiss(animated: true, completion: {
                self.processImage(image: image)
        })
    }
    
    func processImage(image: UIImage) {
            guard let cgImage = image.cgImage else {
                print("Failed to get cgimage from input image")
                return
            }
            let handler = VNImageRequestHandler(cgImage: cgImage)
            let request = VNDetectBarcodesRequest { request, error in
                if let observation = request.results?.first as? VNBarcodeObservation,
                   observation.symbology == .ean13 {
                    guard let barcode = observation.payloadStringValue else {
                        return
                    }
                    self.searchFoodCard(barCode: barcode)
                }
            }
            do {
                try handler.perform([request])
            } catch {
                print(error)
            }
    }
}
