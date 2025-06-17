//
//  String+Extension.swift
//  SeoulMate
//
//  Created by JuHyeon Seong on 6/16/25.
//

import Foundation
import UIKit

extension String {
    func loadNib(bundle: Bundle? = nil) -> UINib {
		return UINib(nibName: self, bundle: bundle)
    }
}
