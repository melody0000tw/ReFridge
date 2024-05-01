//
//  SwiftEntryKitWrapper.swift
//  ReFridge
//
//  Created by Melody Lee on 2024/4/28.
//

import Foundation
import UIKit
import SwiftEntryKit

extension UIViewController {
    
    func presentAlert(title: String, description: String, image: UIImage?) {
        DispatchQueue.main.async {
            var attributes = EKAttributes.topFloat
            attributes.entryBackground = .color(color: .white)
            attributes.popBehavior = .animated(animation: .init(translate: .init(duration: 0.3), scale: .init(from: 1, to: 0.7, duration: 0.7)))
            attributes.shadow = .active(with: .init(color: .black, opacity: 0.5, radius: 5, offset: .zero))
            attributes.statusBar = .dark
            attributes.scroll = .enabled(swipeable: true, pullbackAnimation: .jolt)
            attributes.positionConstraints.maxSize = .init(width: .constant(value: UIScreen.main.bounds.width), height: .intrinsic)
            
            let title = EKProperty.LabelContent(text: title, style: .init(font: UIFont.systemFont(ofSize: 18, weight: .medium), color: .init(.C2)))
            let description = EKProperty.LabelContent(text: description, style: .init(font: UIFont.systemFont(ofSize: 16, weight: .regular), color: .init(.darkGray)))
            let image = EKProperty.ImageContent(image: image!, size: CGSize(width: 48, height: 48), tint: .init(UIColor.C1))
            let simpleMessage = EKSimpleMessage(image: image, title: title, description: description)
            let notificationMessage = EKNotificationMessage(simpleMessage: simpleMessage)
            let contentView = EKNotificationMessageView(with: notificationMessage)
            
            SwiftEntryKit.display(entry: contentView, using: attributes)
        }
    }
}
