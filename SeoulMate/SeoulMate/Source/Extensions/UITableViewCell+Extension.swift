//
//  UITableViewCell+Extension.swift
//  SeoulMate
//
//  Created by JuHyeon Seong on 6/17/25.
//

import Foundation
import UIKit

extension UITableViewCell {
    static var nib: UINib {
        return String(describing: self).loadNib()
    }

    static var identifier: String {
        return String(describing: self)
    }
}
