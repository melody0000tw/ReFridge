//
//  ChartViewController.swift
//  ReFridge
//
//  Created by Melody Lee on 2024/4/18.
//

import UIKit
import SnapKit
import Charts

class ChartViewController: UIViewController {
    private let firestoreManager = FirestoreManager.shared
    private var foodCards = [FoodCard]() {
        didSet {
            DispatchQueue.main.async {
                // pie chart
                self.pieChartView.configurePieCart(foodCards: self.foodCards)
                // bar chart
                self.barChartView.configurePieCart(foodCards: self.foodCards)
                self.setupChartViews()
            }
        }
    }
    
    lazy var imageView = UIImageView()
    lazy var nameLabel = UILabel()
    lazy var cherishLabel = UILabel()
    lazy var progressView = UIProgressView(progressViewStyle: .bar)
    lazy var buttons = [UIButton]()
    lazy var pieChartView = FridgePieChartView()
    lazy var barChartView = FridgeBarChartView()
    
    // MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupHeaderView()
        setupButtons()
        barChartView.isHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchData()
        fetchScores()
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
        
        progressView.setProgress(0.5, animated: false)
        progressView.trackTintColor = UIColor(hex: "EBD9B4")
        progressView.tintColor = UIColor(hex: "ED9455")
        progressView.layer.cornerRadius = 4
        progressView.clipsToBounds = true
        progressView.layer.sublayers![1].cornerRadius = 4
        progressView.subviews[1].clipsToBounds = true
        headerView.addSubview(progressView)
        progressView.snp.makeConstraints { make in
            make.top.equalTo(cherishLabel.snp.bottom).offset(8)
            make.leading.equalTo(imageView.snp.trailing).offset(16)
            make.trailing.equalTo(view.safeAreaLayoutGuide.snp.trailing).offset(-16)
            make.height.equalTo(8)
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
        
        for index in 0..<titles.count {
            let button = UIButton(type: .system)
            button.setTitle(titles[index], for: .normal)
            button.tintColor = .clear
            button.tag = index
            button.setTitleColor(.lightGray, for: .normal)
            button.setTitleColor(.darkGray, for: .selected)
            button.addTarget(self, action: #selector(changeChart(sender:)), for: .touchUpInside)
            buttons.append(button)
            stackView.addArrangedSubview(button)
        }
        
        buttons[0].isSelected = true
    }
    
    @objc func changeChart(sender: UIButton) {
        print("change chart")
        for button in buttons {
            button.isSelected = false
        }
        sender.isSelected = true
        
        pieChartView.isHidden = true
        barChartView.isHidden = true
        if sender.tag == 0 {
            pieChartView.isHidden = false
        } else {
            barChartView.isHidden = false
        }
    }
    
    // MARK: - Food Chart
    private func setupChartViews() {
        view.addSubview(pieChartView)
        pieChartView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(200)
            make.leading.equalTo(view.safeAreaLayoutGuide.snp.leading).offset(24)
            make.trailing.equalTo(view.safeAreaLayoutGuide.snp.trailing).offset(-24)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-24)
        }
        
        view.addSubview(barChartView)
        barChartView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(200)
            make.leading.equalTo(view.safeAreaLayoutGuide.snp.leading).offset(24)
            make.trailing.equalTo(view.safeAreaLayoutGuide.snp.trailing).offset(-24)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-24)
        }
    }
    
    private func configureBarChart(entries: [BarChartDataEntry]) {
        
    }
    
    // MARK: - Data
    private func fetchData() {
        Task {
            await firestoreManager.fetchFoodCard { result in
                switch result {
                case .success(let foodCards):
                    print("got food cards!")
                    self.foodCards = foodCards
                case .failure(let error):
                    print("error: \(error)")
                }
            }
        }
    }
    
    private func fetchScores() {
        Task {
            await firestoreManager.fetchScores { result in
                switch result {
                case .success(let score):
                    let total = score.consumed + score.thrown
                    let scoreDouble = (Double(score.consumed) / Double(total)).rounding(toDecimal: 2)
                    let scoreInt = Int(scoreDouble * 100)
                    print("consume: \(score.consumed), thrown: \(score.thrown)")
                    print("score: \(scoreInt)%")
                    DispatchQueue.main.async {
                        self.cherishLabel.text = "完食分數: \(scoreInt)%"
                        self.progressView.setProgress(Float(scoreDouble), animated: true)
                    }
                    
                case .failure(let error):
                    print("error: \(error)")
                }
                
            }
        }
    }
}
