//
//  ProfileHeaderView.swift
//  ReFridge
//
//  Created by Melody Lee on 2024/4/27.
//

import UIKit

protocol ProfileHeaderViewDelegate: AnyObject {
    func didTappedSettingBtn()
}

class ProfileHeaderView: UIView {
    weak var delegate: ProfileHeaderViewDelegate?
    
    lazy var colorView = UIView()
    lazy var containerView = UIView()
    lazy var imageView = UIImageView()
    lazy var nameLabel = UILabel()
    lazy var settingBtn = UIButton(type: .system)
    lazy var finishedImg = UIImageView(image: UIImage(systemName: "face.smiling"))
    lazy var finishedLabel = UILabel()
    lazy var thrownImg = UIImageView(image: UIImage(systemName: "trash"))
    lazy var thrownLabel = UILabel()
    
    lazy var progressView = UIProgressView(progressViewStyle: .bar)
    lazy var stackView = UIStackView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupHeaderView()
        setupScoreView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupHeaderView() {
        
        addSubview(colorView)
        colorView.backgroundColor = UIColor(hex: "638889")
        colorView.snp.makeConstraints { make in
            make.leading.equalTo(safeAreaLayoutGuide.snp.leading)
            make.top.equalTo(self.snp.top)
            make.trailing.equalTo(safeAreaLayoutGuide.snp.trailing)
            make.bottom.equalTo(safeAreaLayoutGuide.snp.top).offset(150)
        }
        
        addSubview(containerView)
        containerView.backgroundColor = .clear
        containerView.snp.makeConstraints { make in
            make.leading.equalTo(colorView.snp.leading)
            make.top.equalTo(safeAreaLayoutGuide.snp.top)
            make.trailing.equalTo(colorView.snp.trailing)
            make.bottom.equalTo(safeAreaLayoutGuide.snp.top).offset(150)
        }
        
        let imageContainerView = UIView()
        imageContainerView.backgroundColor = .white
        imageContainerView.layer.borderColor = UIColor.C1.cgColor
        imageContainerView.layer.borderWidth = 2
        imageContainerView.layer.cornerRadius = 40
        containerView.addSubview(imageContainerView)
        imageContainerView.snp.makeConstraints { make in
            make.centerY.equalTo(containerView.snp.centerY)
            make.leading.equalTo(containerView.snp.leading).offset(16)
            make.height.width.equalTo(80)
        }
        
        
        imageView.image = UIImage(named: "placeholder")
        imageView.backgroundColor = .clear
        imageView.contentMode = .scaleAspectFit
        imageContainerView.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.centerY.equalTo(imageContainerView.snp.centerY)
            make.centerX.equalTo(imageContainerView.snp.centerX)
            make.height.width.equalTo(60)
        }
        
        nameLabel.text = "Melody"
        nameLabel.font = UIFont(name: "PingFangTC-Semibold", size: 24)
        nameLabel.textAlignment = .left
        nameLabel.textColor = .white
        nameLabel.numberOfLines = 1
        nameLabel.sizeToFit()
        containerView.addSubview(nameLabel)
        nameLabel.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.top)
            make.leading.equalTo(imageView.snp.trailing).offset(16)
        }
        
        settingBtn.setImage(UIImage(systemName: "gearshape.fill"), for: .normal)
        settingBtn.tintColor = .white
        containerView.addSubview(settingBtn)
        settingBtn.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.top)
            make.trailing.equalTo(containerView.snp.trailing).offset(-16)
            make.leading.greaterThanOrEqualTo(nameLabel.snp.trailing).offset(8)
        }
        settingBtn.addTarget(self, action: #selector(didTappedSettingBtn), for: .touchUpInside)
    }
    
    @objc func didTappedSettingBtn() {
        delegate?.didTappedSettingBtn()
        print("did Tapped sign out")
    }
    
    private func setupScoreView() {
        let view = UIView()
        containerView.addSubview(view)
        view.snp.makeConstraints { make in
            make.top.equalTo(nameLabel.snp.bottom).offset(8)
            make.leading.equalTo(imageView.snp.trailing).offset(16)
            make.trailing.equalTo(containerView.snp.trailing).offset(-16)
            make.height.equalTo(24)
        }
        
        finishedImg.contentMode = .scaleAspectFill
        finishedImg.tintColor = .white
        view.addSubview(finishedImg)
        finishedImg.snp.makeConstraints { make in
            make.top.equalTo(view.snp.top)
            make.leading.equalTo(view.snp.leading)
            make.height.width.equalTo(24)
        }
        
        finishedLabel.text = "54"
        finishedLabel.font = UIFont(name: "PingFangTC-Regular", size: 14)
        finishedLabel.textAlignment = .left
        finishedLabel.textColor = .white
        finishedLabel.numberOfLines = 1
        finishedLabel.sizeToFit()
        view.addSubview(finishedLabel)
        finishedLabel.snp.makeConstraints { make in
            make.top.equalTo(view.snp.top)
            make.leading.equalTo(finishedImg.snp.trailing).offset(8)
            make.bottom.equalTo(view.snp.bottom)
        }
        
        thrownImg.contentMode = .scaleAspectFill
        thrownImg.tintColor = .white
        view.addSubview(thrownImg)
        thrownImg.snp.makeConstraints { make in
            make.top.equalTo(view.snp.top)
            make.trailing.equalTo(view.snp.trailing)
            make.height.width.equalTo(24)
        }
        
        thrownLabel.text = "35"
        thrownLabel.font = UIFont(name: "PingFangTC-Regular", size: 14)
        thrownLabel.textAlignment = .right
        thrownLabel.textColor = .white
        thrownLabel.numberOfLines = 1
        thrownLabel.sizeToFit()
        view.addSubview(thrownLabel)
        thrownLabel.snp.makeConstraints { make in
            make.top.equalTo(view.snp.top)
            make.trailing.equalTo( thrownImg.snp.leading).offset(-8)
            make.bottom.equalTo(view.snp.bottom)
            make.leading.greaterThanOrEqualTo(finishedLabel.snp.trailing).offset(-16)
        }

        progressView.setProgress(0.5, animated: false)
        progressView.trackTintColor = UIColor(hex: "EBD9B4")
        progressView.tintColor = UIColor(hex: "ED9455")
        progressView.layer.cornerRadius = 4
        progressView.clipsToBounds = true
        progressView.layer.sublayers![1].cornerRadius = 4
        progressView.subviews[1].clipsToBounds = true
        containerView.addSubview(progressView)
        progressView.snp.makeConstraints { make in
            make.top.equalTo(view.snp.bottom).offset(8)
            make.leading.equalTo(imageView.snp.trailing).offset(16)
            make.trailing.equalTo(containerView.snp.trailing).offset(-16)
            make.height.equalTo(8)
        }
    }
}
