//
//  ChartViewController.swift
//  ReFridge
//
//  Created by Melody Lee on 2024/4/18.
//

import UIKit
import Combine
import SnapKit
import Charts
import FirebaseAuth
import AuthenticationServices

class ChartViewController: BaseViewController {
    var viewModel = ChartViewModel()
    private var cancellables: Set<AnyCancellable> = []
    private let accountManager = AccountManager.share
    
    private lazy var settingBtn = UIBarButtonItem()
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
        setupNavigationView()
        bindViewModel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.fetchDatas()
    }
    
    // MARK: - setups
    private func setupNavigationView() {
        settingBtn.image = UIImage(systemName: "gearshape.fill")
        settingBtn.tintColor = .white
        settingBtn.target = self
        settingBtn.action = #selector(presentSettingSheet)
        navigationItem.rightBarButtonItem = settingBtn
    }
    
    private func setupPofileView() {
        view.addSubview(headerView)
        headerView.snp.makeConstraints { make in
            make.leading.equalTo(view.safeAreaLayoutGuide.snp.leading)
            make.top.equalTo(view.snp.top)
            make.trailing.equalTo(view.safeAreaLayoutGuide.snp.trailing)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.top).offset(120)
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
    
    private func setupChartViews() {
        view.addSubview(chartsContainerView)
        chartsContainerView.snp.makeConstraints { make in
            make.top.equalTo(stackView.snp.bottom)
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
        chartsContainerView.addSubview(infoLabel)
        infoLabel.snp.makeConstraints { make in
            make.centerX.equalTo(chartsContainerView.snp.centerX)
            make.bottom.equalTo(chartsContainerView.snp.bottom).offset(-24)
        }
    }
    
    // MARK: - Coordinator
    @objc private func presentSettingSheet() {
        let controller = UIAlertController(title: "帳號設定", message: nil, preferredStyle: .actionSheet)
        let updateProfileAction = UIAlertAction(title: "編輯個人資料", style: .default) { _ in
            self.presentAvatarVC()
        }
        let signOutAction = UIAlertAction(title: "登出", style: .default) { _ in
            self.signoutFireBase()
        }
        let deleteAccountAction = UIAlertAction(title: "刪除帳號", style: .destructive) { _ in
            self.presentDeletionAlert()
        }
        let cancelAction = UIAlertAction(title: "取消", style: .cancel)
        
        controller.addAction(updateProfileAction)
        controller.addAction(signOutAction)
        controller.addAction(deleteAccountAction)
        controller.addAction(cancelAction)
        
        present(controller, animated: true)
    }
    
    private func presentAvatarVC() {
        let storyboard = UIStoryboard(name: "Login", bundle: nil)
        guard let avatarVC = storyboard.instantiateViewController(withIdentifier: "AvatarViewController") as? AvatarViewController else {
            return
        }
        avatarVC.mode = .edit
        avatarVC.userInfo = viewModel.userInfo
        avatarVC.modalPresentationStyle = .fullScreen
        present(avatarVC, animated: true)
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
    
    private func presentLoginPage() {
        DispatchQueue.main.async {
            let storyboard = UIStoryboard(name: "Login", bundle: nil)
            if let initialViewController = storyboard.instantiateInitialViewController() {
                initialViewController.modalPresentationStyle = .fullScreen
                self.present(initialViewController, animated: false)
            }
        }
    }
    
    // MARK: - Data
    private func bindViewModel() {
        viewModel.$foodCards
            .receive(on: RunLoop.main)
            .sink { [weak self] foodCards in
                self?.updateChartUI(with: foodCards)
            }
            .store(in: &cancellables)
        viewModel.$userInfo
            .receive(on: RunLoop.main)
            .sink { [weak self] userInfo in
                self?.updateUserInfo(with: userInfo)
            }
            .store(in: &cancellables)
        viewModel.$scores
            .receive(on: RunLoop.main)
            .sink { [weak self] scores in
                self?.updateScores(with: scores)
            }
            .store(in: &cancellables)
    }
    
    private func updateChartUI(with foodCards: [FoodCard]) {
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
    
    private func updateUserInfo(with userInfo: UserInfo) {
        self.headerView.nameLabel.text = "Hello, \(userInfo.name)!"
        self.headerView.imageView.image = UIImage(named: userInfo.avatar)
    }
    
    private func updateScores(with scores: Scores) {
        let total = scores.consumed + scores.thrown
        var scoreDouble = 0.0

        if total != 0 {
            scoreDouble = (Double(scores.consumed) / Double(total)).rounding(toDecimal: 2)
        }
        headerView.finishedLabel.text = String(scores.consumed)
        headerView.thrownLabel.text = String(scores.thrown)
        headerView.progressView.setProgress(Float(scoreDouble), animated: true)
    }

    // MARK: - Sign out & Deletion
    private func signoutFireBase() {
        accountManager.signoutFireBase { result in
            switch result {
            case .success:
                self.presentLoginPage()
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    private func performAccountDeletion() {
        let request = accountManager.createAppleIdRequest()
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
}

// MARK: - SignInWithApple
@available(iOS 13.0, *)
extension ChartViewController: ASAuthorizationControllerDelegate {
  func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
      viewModel.updateAccountStatus()
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
