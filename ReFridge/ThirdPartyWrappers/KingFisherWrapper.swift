//
//  KingFisherWrapper.swift
//  ReFridge
//
//  Created by Melody Lee on 2024/4/22.
//

import Foundation
import UIKit
import Kingfisher

extension UIImageView {

    func loadImage(_ urlString: String?, placeHolder: UIImage? = UIImage(named: "placeholder")) {
        guard let urlString = urlString else {
            self.image = placeHolder
            return
        }
        let url = URL(string: urlString)
        self.kf.setImage(with: url, placeholder: placeHolder)
    }
}
