//
//  ViewController.swift
//  ReFridge
//
//  Created by Melody Lee on 2024/4/9.
//

import UIKit
import VisionKit
import Vision
import Lottie

class MyFridgeViewController: BaseViewController {
    private let viewModel = MyFridgeViewModel()
    var cards = [FoodCard]() {
        didSet {
            DispatchQueue.main.async { [self] in
                collectionView.isHidden = false
                collectionView.reloadData()
                emptyDataManager.toggleLabel(shouldShow: (self.cards.count == 0))
            }
        }
    }
    
    var cardFilter = CardFilter(categoryId: nil, sortBy: .remainingDay) {
        didSet {
            cards = viewModel.filterFoodCards(by: cardFilter)
        }
    }
    
    @IBOutlet weak var filterBarButton: UIBarButtonItem!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    lazy var emptyDataManager = EmptyDataManager(view: self.view, emptyMessage: "尚無相關資料")
    private lazy var refreshControl = RefresherManager()
    
    private lazy var isScaning = false
    
    @IBAction func searchByBarCode(_ sender: Any) {
        let documentCameraViewController = VNDocumentCameraViewController()
        documentCameraViewController.delegate = self
        present(documentCameraViewController, animated: true)
    }
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        setupSearchBar()
        setupFilterBtn()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if isScaning {
            return
        }
        collectionView.isHidden = true
        fetchData()
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
        
        refreshControl.addTarget(self, action: #selector(fetchData), for: .valueChanged)
        collectionView.refreshControl = refreshControl
        collectionView.refreshControl?.tintColor = .clear
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
    
    // MARK: - Coordinator
    private func presentScanResult(scanResult: ScanResult) {
        DispatchQueue.main.async { [self] in
            guard let scanVC = storyboard?.instantiateViewController(withIdentifier: "ScanResultViewController") as? ScanResultViewController else {
                    print("cannot get scanresult vc")
                    return
            }
            scanVC.scanResult = scanResult
            navigationController?.pushViewController(scanVC, animated: true)
        }
    }
    
    private func presentAddToCardVC(mode: FoodCardMode, selectedFoodCard: FoodCard? = nil) {
        guard let addFoodCardVC =
                storyboard?.instantiateViewController(withIdentifier: "AddFoodCardViewController") as? AddFoodCardViewController else {
                    print("cannot find foodCardVC")
                    return
                }
        addFoodCardVC.mode = mode
        if mode == .editing, let foodCard = selectedFoodCard {
//            addFoodCardVC.foodCard = foodCard
            addFoodCardVC.viewModel.foodCard = foodCard
        }
        self.navigationController?.pushViewController(addFoodCardVC, animated: true)
    }
    
    private func presentScannerActionSheet() {
        let controller = UIAlertController(title: "請選取影像來源", message: nil, preferredStyle: .actionSheet)
        let cameraAction = UIAlertAction(title: "開啟相機拍攝", style: .default) { _ in
            self.presentImagePicker(sourceType: .camera)
        }
        let photoLibraryAction = UIAlertAction(title: "選擇相簿圖片", style: .default) { _ in
            self.presentImagePicker(sourceType: .photoLibrary)
        }
        let cancelAction = UIAlertAction(title: "取消", style: .cancel)
        
        controller.addAction(cameraAction)
        controller.addAction(photoLibraryAction)
        controller.addAction(cancelAction)
        present(controller, animated: true)
    }
    
    // MARK: - Data
    @objc private func fetchData() {
        refreshControl.startRefresh()
        showLoadingIndicator()
        
        viewModel.fetchFoodCards(filter: cardFilter) { [self] result in
            switch result {
            case .success(let foodCards):
                cards = foodCards
                removeLoadingIndicator()
                refreshControl.endRefresh()
            case .failure(let error):
                removeLoadingIndicator()
                refreshControl.endRefresh()
                presentInternetAlert()
                print("error: \(error)")
            }
        }
    }
    
    private func searchFoodCard(by barCode: String) {
        guard let searchBar = navigationItem.searchController?.searchBar else {
            print("can not get search bar")
            return
        }
        searchBar.text = barCode
        searchBar.becomeFirstResponder()
        searchBar.delegate?.searchBar?(searchBar, textDidChange: barCode)
        if let searchController = navigationItem.searchController {
            updateSearchResults(for: searchController)
        }
    }
    
    // MARK: - imagePicker
    private func presentImagePicker(sourceType: UIImagePickerController.SourceType) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = sourceType
        self.present(picker, animated: true)
    }
}

// MARK: - UICollectionViewDataSource, UICollectionViewDelegate
extension MyFridgeViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        cards.count + 2
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
            cell.setupDefaultCell()
        case 1:
            cell.iconImage.image = UIImage(systemName: "doc.viewfinder")
            cell.remainDayLabel.isHidden = true
            cell.nameLabel.text = "掃描收據"
            cell.setupDefaultCell()
        default:
            let foodCard = cards[indexPath.item - 2]
            cell.foodCard = foodCard
            cell.setupCell()
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)
        cell?.clickBounce()
        
        switch indexPath.item {
        case 0:
            presentAddToCardVC(mode: .adding)
        case 1:
            presentScannerActionSheet()
        default:
            let selectedFoodCard = cards[indexPath.item - 2]
            presentAddToCardVC(mode: .editing, selectedFoodCard: selectedFoodCard)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        cell.transform = CGAffineTransform(scaleX: 0, y: 0)
        
        UIView.animate(withDuration: 0.5, delay: 0.05 * Double(indexPath.row)) {
            cell.transform = CGAffineTransform(scaleX: 1, y: 1)
        }
    }
}

// MARK: - UIImagePickerControllerDelegate, UINavigationControllerDelegate
extension MyFridgeViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        isScaning = true
        showLoadingIndicator()
        guard let image = info[.originalImage] as? UIImage else { return }
        let scanManager = TextScanManager.shared
        Task {
            scanManager.detectText(in: image, completion: { result in
                guard let scanResult = result else {
                    self.presentAlert(title: "無法辨識", description: "無法辨識圖片中的文字", image: UIImage(systemName: "xmark.circle"))
                    self.removeLoadingIndicator()
                    self.isScaning = false
                    return
                }
                self.presentScanResult(scanResult: scanResult)
                self.removeLoadingIndicator()
                self.isScaning = false
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
            cards = viewModel.searchFoodCards(with: searchText)
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        cards = viewModel.filterFoodCards(by: cardFilter)
    }
}

// MARK: - BarCode
extension MyFridgeViewController: VNDocumentCameraViewControllerDelegate {
    func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFinishWith scan: VNDocumentCameraScan) {
        isScaning = true
        let image = scan.imageOfPage(at: scan.pageCount - 1)
        dismiss(animated: true, completion: {
            self.processImage(image: image)
        })
    }
    
    func processImage(image: UIImage) {
        guard let cgImage = image.cgImage else {
            print("Failed to get cgimage from input image")
            isScaning = false
            return
        }
        let handler = VNImageRequestHandler(cgImage: cgImage)
        let request = VNDetectBarcodesRequest { request, _ in
            if let observation = request.results?.first as? VNBarcodeObservation,
               observation.symbology == .ean13 {
                guard let barcode = observation.payloadStringValue else {
                    return
                }
                self.searchFoodCard(by: barcode)
            }
        }
        do {
            try handler.perform([request])
        } catch {
            print(error)
        }
        self.isScaning = false
    }
}
