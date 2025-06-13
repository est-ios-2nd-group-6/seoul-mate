//
//  UIImageView+Load.swift
//  SeoulMate
//
//  Created by 윤혜주 on 6/13/25.
//

import Foundation
import UIKit

extension UIImageView {
    func load(from url: URL) {
        DispatchQueue.global().async {
            if let data = try? Data(contentsOf: url),
               let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    self.image = image
                }
            }
        }
    }
}
