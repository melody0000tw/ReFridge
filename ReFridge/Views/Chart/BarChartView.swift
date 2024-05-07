//
//  BarChartView.swift
//  ReFridge
//
//  Created by Melody Lee on 2024/4/18.
//

import Foundation
import UIKit
import SnapKit
import Charts

class FridgeBarChartView: BarChartView {
    
    private func createEntries(foodCards: [FoodCard]) -> [BarChartDataEntry] {
  
        var count1 = RemainingDayCount(remainingDay: .expired, cardCounts: 0)
        var count2 = RemainingDayCount(remainingDay: .lessThanSevenDays, cardCounts: 0)
        var count3 = RemainingDayCount(remainingDay: .lessThanOneMonths, cardCounts: 0)
        var count4 = RemainingDayCount(remainingDay: .lessThanThreeMonths, cardCounts: 0)
        var count5 = RemainingDayCount(remainingDay: .moreThanThreeMonths, cardCounts: 0)
        
        for foodCard in foodCards {
            guard let remainingDay = foodCard.expireDate.calculateRemainingDays() else {
                return [BarChartDataEntry]()
            }
            
            if remainingDay <= 0 {
                count1.cardCounts += 1
            } else if remainingDay <= 7 {
                count2.cardCounts += 1
            } else if remainingDay <= 30 {
                count3.cardCounts += 1
            } else if remainingDay <= 90 {
                count4.cardCounts += 1
            } else {
                count5.cardCounts += 1
            }
        }
        
        let counts = [count1, count2, count3, count4, count5]
        var entries = [BarChartDataEntry]()
        for index in 0..<counts.count {
            let item = counts[index]
            entries.append(BarChartDataEntry(x: Double(index), y: Double(item.cardCounts)))
        }
        return entries
    }
    
    func configureBarCart(foodCards: [FoodCard]) {
        let entries = createEntries(foodCards: foodCards)
        
        let dataSet = BarChartDataSet(entries: entries, label: "食物數量")
        dataSet.colors = [UIColor(hex: "EFBC9B"), UIColor(hex: "EBD9B4"), UIColor(hex: "9DBC98"), UIColor(hex: "638889"), UIColor(hex: "9CAFAA")]
        dataSet.valueFont = UIFont.systemFont(ofSize: 13)
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        
        data = BarChartData(dataSet: dataSet)
        data?.setValueFormatter(DefaultValueFormatter(formatter: formatter))
        
        let xValue = ["剩0天", "剩7天", "剩30天", "剩90天"]
        xAxis.valueFormatter = IndexAxisValueFormatter(values: xValue)
        xAxis.granularity = 1
        xAxis.drawGridLinesEnabled = false
        xAxis.drawAxisLineEnabled = true
        xAxis.centerAxisLabelsEnabled = true
        xAxis.labelPosition = .bottom
        xAxis.labelFont = UIFont.systemFont(ofSize: 12)
        
        leftAxis.drawGridLinesEnabled = false
        leftAxis.enabled = false
        rightAxis.drawGridLinesEnabled = false
        rightAxis.enabled = false
        
        scaleXEnabled = false
        scaleYEnabled = true
        doubleTapToZoomEnabled = false
        
        legend.enabled = false
        
    }

}
