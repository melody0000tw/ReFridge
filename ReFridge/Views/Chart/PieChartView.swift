//
//  PieChartView.swift
//  ReFridge
//
//  Created by Melody Lee on 2024/4/18.
//

import UIKit
import SnapKit
import Charts

class FridgePieChartView: PieChartView {
    
    var foodCards: [FoodCard]
    
    init(frame: CGRect, foodCards: [FoodCard]) {
            self.foodCards = foodCards
            super.init(frame: frame)
            let entries = createEntries(foodCards: self.foodCards)
            configurePieCart(entries: entries)
        }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
        
        
        data = chartData // 將 chartData 指派給 pieChartView
        data?.setValueFormatter(DefaultValueFormatter(formatter: percentFormatter)) // 要在這邊指派！不能再上上一行！
        legend.form = .circle // 設定圖例樣式
        usePercentValuesEnabled = true // 可顯示 % 數
        legend.horizontalAlignment = .center
       
    }

}
