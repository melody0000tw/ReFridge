//
//  RefresherManager.swift
//  ReFridge
//
//  Created by Melody Lee on 2024/4/27.
//

import UIKit
import Lottie

class RefresherManager: UIRefreshControl {
    var animationView = LottieAnimationView(name: "flying-carrot")
    
    override init() {
        super.init()
        setupLottieAnimation()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLottieAnimation()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupLottieAnimation() {
        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = .loop
        animationView.animationSpeed = 0.5
        animationView.alpha = 0
        self.addSubview(animationView)
        animationView.snp.makeConstraints { make in
            make.centerX.equalTo(self.snp.centerX)
            make.centerY.equalTo(self.snp.centerY)
            make.height.width.equalTo(120)
        }
    }
    
    func startRefresh() {
        UIView.animate(withDuration: 0.5) {
            self.animationView.alpha = 1
            self.animationView.play()
        }
    }
    
    func endRefresh() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [self] in
            UIView.animate(withDuration: 0.5) {
                self.animationView.alpha = 0
                self.animationView.stop()
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                self.endRefreshing()
            }
            
        }
    }
}
