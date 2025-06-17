//
//  UIViewController+Extension.swift
//  SeoulMate
//
//  Created by JuHyeon Seong on 6/18/25.
//

import Foundation
import UIKit

extension UIViewController {
    func showInAppNotification(
        message: String,
        duration: TimeInterval = 3.0,
        backgroundColor: UIColor = .main,
        iconName: String? = "checkmark.fill",
        completion: (() -> Void)? = nil
    ) {
        let notificationView = InAppNotificationView()

        notificationView.show(
            message: message,
            in: self,
            duration: duration,
            backgroundColor: backgroundColor,
            iconName: iconName,
            completion: completion
        )
    }
}
