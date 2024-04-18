//
//  ChartViewController.swift
//  ReFridge
//
//  Created by Melody Lee on 2024/4/18.
//

import UIKit
import SnapKit
import Charts

struct CategoryCardCount {
    var categoryId: Int
    var cardCounts: Int
}

class ChartViewController: UIViewController {
    private let firestoreManager = FirestoreManager.shared
    private var foodCards = [FoodCard]()
    
    lazy var imageView = UIImageView()
    lazy var nameLabel = UILabel()
    lazy var cherishLabel = UILabel()
    lazy var cherishFoodView = UIView()
    lazy var buttons = [UIButton]()
    lazy var fridgeChartView = PieChartView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupHeaderView()
        setupButtons()
        fetchData()
        setupFridgeChart()
    }
    
    // MARK: - setups
    private func setupHeaderView() {
        let colorView = UIView()
        view.addSubview(colorView)
        colorView.backgroundColor = UIColor(hex: "638889")
        colorView.snp.makeConstraints { make in
            make.leading.equalTo(view.safeAreaLayoutGuide.snp.leading)
            make.top.equalTo(view.snp.top)
            make.trailing.equalTo(view.safeAreaLayoutGuide.snp.trailing)
            make.height.equalTo(240)
        }
        
        let headerView = UIView()
        view.addSubview(headerView)
        headerView.backgroundColor = .clear
        headerView.snp.makeConstraints { make in
            make.leading.equalTo(colorView.snp.leading)
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.trailing.equalTo(colorView.snp.trailing)
            make.bottom.equalTo(colorView.snp.bottom)
        }
        
        imageView.image = UIImage(named: "placeholder")
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 40
        imageView.clipsToBounds = true
        headerView.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.centerY.equalTo(headerView.snp.centerY)
            make.leading.equalTo(headerView.snp.leading).offset(16)
            make.height.width.equalTo(80)
        }
        
        nameLabel.text = "Melody"
        nameLabel.font = UIFont(name: "PingFangTC-Semibold", size: 24)
        nameLabel.textAlignment = .left
        nameLabel.textColor = .white
        nameLabel.numberOfLines = 1
        nameLabel.sizeToFit()
        headerView.addSubview(nameLabel)
        nameLabel.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.top)
            make.leading.equalTo(imageView.snp.trailing).offset(16)
        }
        
        cherishLabel.text = "完食分數: 100%"
        cherishLabel.font = UIFont(name: "PingFangTC-Regular", size: 15)
        cherishLabel.textAlignment = .left
        cherishLabel.textColor = .white
        cherishLabel.numberOfLines = 1
        cherishLabel.sizeToFit()
        headerView.addSubview(cherishLabel)
        cherishLabel.snp.makeConstraints { make in
            make.top.equalTo(nameLabel.snp.bottom).offset(8)
            make.leading.equalTo(imageView.snp.trailing).offset(16)
        }
        
        cherishFoodView.backgroundColor = UIColor(hex: "EBD9B4")
        cherishFoodView.layer.cornerRadius = 5
        headerView.addSubview(cherishFoodView)
        
        cherishFoodView.snp.makeConstraints { make in
            make.top.equalTo(cherishLabel.snp.bottom).offset(8)
            make.leading.equalTo(imageView.snp.trailing).offset(16)
            make.trailing.equalTo(view.safeAreaLayoutGuide.snp.trailing).offset(-16)
//            make.bottom.equalTo(headerView.snp.bottom).offset(-24)
//            make.centerY.equalTo(cherishLabel.snp.centerY)
            make.height.equalTo(10)
            
        }
        
    }
    
    private func setupButtons() {
        let titles = ["食物類型", "保存期限"]
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 0
        view.addSubview(stackView)
        
        stackView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(140)
            make.leading.equalTo(view.safeAreaLayoutGuide.snp.leading)
            make.trailing.equalTo(view.safeAreaLayoutGuide.snp.trailing)
            make.height.equalTo(60)
        }
        
        for index in 0...(titles.count - 1) {
            let button = UIButton(type: .system)
            button.setTitle(titles[index], for: .normal)
            button.tintColor = .darkGray
            button.tag = index
//            button.backgroundColor = .lightGray
//            button.addTarget(self, action: nil, for: .touchUpInside)
            buttons.append(button)
            stackView.addArrangedSubview(button)
        }
    }
    
    // MARK: - Food Chart
    private func setupFridgeChart() {
        view.addSubview(fridgeChartView)
        fridgeChartView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(140)
            make.leading.equalTo(view.safeAreaLayoutGuide.snp.leading).offset(24)
            make.trailing.equalTo(view.safeAreaLayoutGuide.snp.trailing).offset(-24)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(24)
//            make.edges.equalTo(view.snp.edges)
        }
    }
    
    private func configurePieCart(entries: [PieChartDataEntry]) {
        // 第一組圓餅圖資料
        let dataSet = PieChartDataSet(entries: entries, label: "")
        dataSet.colors = [UIColor(hex: "EFBC9B"), UIColor(hex: "EBD9B4"), UIColor(hex: "9DBC98"), UIColor(hex: "638889"), UIColor(hex: "9CAFAA")] // 設定圓餅圖的顏色
        dataSet.valueFont = UIFont.systemFont(ofSize: 17.0) // 設定資料數值的字體大小
        dataSet.selectionShift = 5
        dataSet.sliceSpace = 3
        
        let chartData = PieChartData(dataSets: [dataSet])
        let percentFormatter = NumberFormatter()
        percentFormatter.numberStyle = .percent
        percentFormatter.maximumFractionDigits = 0
        percentFormatter.multiplier = 1
        percentFormatter.percentSymbol = "%"
        
        fridgeChartView.data = chartData // 將 chartData 指派給 pieChartView
        fridgeChartView.data?.setValueFormatter(DefaultValueFormatter(formatter: percentFormatter)) // 要在這邊指派！不能再上上一行！
        fridgeChartView.legend.form = .circle // 設定圖例樣式
        fridgeChartView.usePercentValuesEnabled = true // 可顯示 % 數
        fridgeChartView.legend.horizontalAlignment = .center
       
    }
    
    // MARK: - Data
    private func fetchData() {
        Task {
            await firestoreManager.fetchFoodCard { result in
                switch result {
                case .success(let foodCards):
                    print("got food cards!")
                    self.foodCards = foodCards
                    let entries = createEntries(foodCards: foodCards)
                    configurePieCart(entries: entries)
                case .failure(let error):
                    print("error: \(error)")
                }
            }
        }
    }
    
    private func createEntries(foodCards: [FoodCard]) -> [PieChartDataEntry] {
        
        var count1 = CategoryCardCount(categoryId: 1, cardCounts: 0)
        var count2 = CategoryCardCount(categoryId: 2, cardCounts: 0)
        var count3 = CategoryCardCount(categoryId: 3, cardCounts: 0)
        var count4 = CategoryCardCount(categoryId: 4, cardCounts: 0)
        var count5 = CategoryCardCount(categoryId: 5, cardCounts: 0)
        
        for foodCard in foodCards {
            switch foodCard.categoryId {
            case 1:
                count1.cardCounts += 1
            case 2:
                count2.cardCounts += 1
            case 3:
                count3.cardCounts += 1
            case 4:
                count4.cardCounts += 1
            case 5:
                count5.cardCounts += 1
            default:
                print("cannot tell the category Id")
            }
        }
        
        var counts = [count1, count2, count3, count4, count5]
        
        var entries = [PieChartDataEntry]()
        for count in counts {
            let value = Double(count.cardCounts)
            let label = CategoryData.share.queryFoodCategory(categoryId: count.categoryId)?.categoryName
            let entry = PieChartDataEntry(value: value, label: label, icon: nil)
            entries.append(entry)
        }
        
        return entries
    }
}
