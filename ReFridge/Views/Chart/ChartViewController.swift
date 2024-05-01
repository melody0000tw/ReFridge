//
//  ChartViewController.swift
//  ReFridge
//
//  Created by Melody Lee on 2024/4/18.
//

import UIKit
import SnapKit
import Charts
import FirebaseAuth
import AuthenticationServices

class ChartViewController: UIViewController {
    private let firestoreManager = FirestoreManager.shared
    private let accountManager = AccountManager.share
    
    private var userInfo: UserInfo?
    
    private var foodCards = [FoodCard]() {
        didSet {
            DispatchQueue.main.async { [self] in
                
                self.emptyDataManager.toggleLabel(shouldShow: (foodCards.count == 0))
                if foodCards.isEmpty {
                    chartsContainerView.isHidden = true
                } else {
                    // pie chart
                    chartsContainerView.isHidden = false
                    pieChartView.configurePieCart(foodCards: foodCards)
                    // bar chart
                    barChartView.configureBarCart(foodCards: foodCards)
                }
            }
        }
    }
    
    private lazy var headerView = ProfileHeaderView(frame: CGRect())
    private lazy var stackView = UIStackView()
    private lazy var buttons = [UIButton]()
    private lazy var barView = UIView()
    private lazy var chartsContainerView = UIView()
    private lazy var pieChartView = FridgePieChartView()
    private lazy var barChartView = FridgeBarChartView()
    private lazy var infoLabel = UILabel()
    
    lazy var emptyDataManager = EmptyDataManager(view: view, emptyMessage: "尚無相關資料")
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupPofileView()
        setupButtons()
        setupChartViews()
        barChartView.isHidden = true
        fetchUserInfo()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchData()
        fetchScores()
    }
    
    // MARK: - setups
    private func setupPofileView() {
        headerView.delegate = self
        view.addSubview(headerView)
        headerView.snp.makeConstraints { make in
            make.leading.equalTo(view.safeAreaLayoutGuide.snp.leading)
            make.top.equalTo(view.snp.top)
            make.trailing.equalTo(view.safeAreaLayoutGuide.snp.trailing)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.top).offset(150)
        }
    }
    
    private func setupButtons() {
        let titles = ["食物類型", "保存期限"]
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 0
        view.addSubview(stackView)
        
        stackView.snp.makeConstraints { make in
            make.top.equalTo(headerView.snp.bottom)
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
        
        barView.backgroundColor = .C2
        barView.layer.cornerRadius = 1.5
        view.addSubview(barView)
        let btnWidth = Int(view.bounds.size.width) / stackView.subviews.count
        barView.snp.makeConstraints { make in
            make.bottom.equalTo(stackView)
            make.height.equalTo(3)
            make.width.equalTo(Double(btnWidth) * 0.6)
            make.centerX.equalTo((btnWidth / 2))
        }
    }
    
    private func animateBarView(tag: Int) {
        let btnWidth = Int(stackView.bounds.size.width) / stackView.subviews.count
        barView.snp.remakeConstraints { make in
            make.bottom.equalTo(stackView)
            make.height.equalTo(3)
            make.width.equalTo(Double(btnWidth) * 0.6)
            make.centerX.equalTo(btnWidth * tag + (btnWidth / 2))
        }
        UIView.animate(withDuration: 0.2, animations: {
            self.view.layoutIfNeeded()
        })
        
    }
    
    @objc func changeChart(sender: UIButton) {
        print("change chart")
        for button in buttons {
            button.isSelected = false
        }
        sender.isSelected = true
        animateBarView(tag: sender.tag)
        
        pieChartView.isHidden = true
        barChartView.isHidden = true
        if sender.tag == 0 {
            infoLabel.text = "冰箱中食物種類百分比例"
            pieChartView.isHidden = false
            pieChartView.clickBounce()
        } else {
            infoLabel.text = "剩餘效期區間內的食物數量"
            barChartView.isHidden = false
            barChartView.clickBounce()
        }
        
    }
    
    // MARK: - Food Chart
    private func setupChartViews() {
        view.addSubview(chartsContainerView)
        chartsContainerView.snp.makeConstraints { make in
            make.top.equalTo(stackView.snp.bottom)
//            make.top.equalTo(colorView.snp.bottom).offset(60)
            make.leading.equalTo(view.safeAreaLayoutGuide.snp.leading)
            make.trailing.equalTo(view.safeAreaLayoutGuide.snp.trailing)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
        }
        
        chartsContainerView.addSubview(pieChartView)
        pieChartView.snp.makeConstraints { make in
            make.top.equalTo(chartsContainerView.snp.top).offset(24)
            make.leading.equalTo(chartsContainerView.snp.leading).offset(24)
            make.trailing.equalTo(chartsContainerView.snp.trailing).offset(-24)
            make.bottom.equalTo(chartsContainerView.snp.bottom).offset(-60)
        }
        
        chartsContainerView.addSubview(barChartView)
        barChartView.snp.makeConstraints { make in
            make.top.equalTo(chartsContainerView.snp.top)
            make.leading.equalTo(chartsContainerView.snp.leading).offset(24)
            make.trailing.equalTo(chartsContainerView.snp.trailing).offset(-24)
            make.bottom.equalTo(chartsContainerView.snp.bottom).offset(-60)
        }
        
        infoLabel.text = "冰箱中食物種類百分比例"
        infoLabel.font = UIFont(name: "PingFangTC-Regular", size: 14)
        infoLabel.textAlignment = .center
        infoLabel.textColor = .darkGray
//        nameLabel.sizeToFit()
        chartsContainerView.addSubview(infoLabel)
        infoLabel.snp.makeConstraints { make in
            make.centerX.equalTo(chartsContainerView.snp.centerX)
            make.bottom.equalTo(chartsContainerView.snp.bottom).offset(-24)
        }
    }
    
    // MARK: - Account Settings
    private func presentSettingSheet() {
        let controller = UIAlertController(title: "帳號設定", message: nil, preferredStyle: .actionSheet)
        let signOutAction = UIAlertAction(title: "登出", style: .default) { action in
            self.signoutFireBase()
        }
        let deleteAccountAction = UIAlertAction(title: "刪除帳號", style: .destructive) { action in
            print("我要刪除帳號！！！")
            self.presentDeletionAlert()
        }
        let cancelAction = UIAlertAction(title: "取消", style: .cancel)
        
        controller.addAction(signOutAction)
        controller.addAction(deleteAccountAction)
        controller.addAction(cancelAction)
        
        present(controller, animated: true)
    }
    
    private func presentDeletionAlert() {
        let controller = UIAlertController(title: "確認刪除帳戶？", message: "刪除帳戶後將無法再存取所有儲存的資料", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "確認刪除", style: .destructive) { _ in
            self.performAccountDeletion()
        }
        controller.addAction(okAction)
        let cancelAction = UIAlertAction(title: "取消", style: .cancel)
        controller.addAction(cancelAction)
        present(controller, animated: true)
    }
    
    private func performAccountDeletion() {
        let request = accountManager.createAppleIdRequest()
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
    
    private func presentLoginPage() {
        DispatchQueue.main.async {
            let storyboard = UIStoryboard(name: "Login", bundle: nil)
            if let initialViewController = storyboard.instantiateInitialViewController() {
                initialViewController.modalPresentationStyle = .fullScreen
                self.present(initialViewController, animated: true)
            }
        }
    }
    
    // MARK: - Data
    private func fetchUserInfo() {
        Task {
            await firestoreManager.fetchUserInfo { result in
                switch result {
                case .success(let userInfo):
                    self.userInfo = userInfo
                    DispatchQueue.main.async {
                        self.headerView.nameLabel.text = "Hello, \(userInfo.name)!"
                    }
                case .failure(let error):
                    print("error: \(error)")
                }
            }
        }
    }
    
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
                    var scoreDouble = 0.0
                    
                    if total != 0 {
                        scoreDouble = (Double(score.consumed) / Double(total)).rounding(toDecimal: 2)
                    }
                    print("consume: \(score.consumed), thrown: \(score.thrown)")
                    DispatchQueue.main.async { [self] in
                        headerView.finishedLabel.text = String(score.consumed)
                        headerView.thrownLabel.text = String(score.thrown)
                        headerView.progressView.setProgress(Float(scoreDouble), animated: true)
                    }
                case .failure(let error):
                    print("error: \(error)")
                }
                
            }
        }
    }
    
    private func signoutFireBase() {
        accountManager.signoutFireBase { result in
            switch result {
            case .success:
                print("didSignOut")
                self.presentLoginPage()
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    private func updateUserInfo() {
        guard let userInfo = userInfo else {
            print("cannot get userInfo")
            return
        }
        Task {
            await firestoreManager.updateUserInfo(userInfo: userInfo) { result in
                switch result {
                case .success:
                    print("userInfo is updated: \(userInfo)")
                case .failure(let error):
                    print(error.localizedDescription)
                }
                
            }
        }
    }
}



// MARK: -
extension ChartViewController: ProfileHeaderViewDelegate {
    func didTappedSettingBtn() {
        presentSettingSheet()
    }
}

// MARK: - SignInWithApple
@available(iOS 13.0, *)
extension ChartViewController: ASAuthorizationControllerDelegate {

  func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
      userInfo?.accountStatus = 0
      updateUserInfo()
      presentLoginPage()
      
      accountManager.deleteAppleSignInAccount(controller: controller, didCompleteWithAuthorization: authorization) { result in
          switch result {
          case .success:
              print("已成功刪除帳戶")
          case .failure(let error):
              print(error.localizedDescription)
          }
      }
  }

  func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
    print("Sign in with Apple errored: \(error)")
  }

}

extension ChartViewController: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
}
