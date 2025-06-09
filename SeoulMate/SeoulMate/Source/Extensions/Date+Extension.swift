//
//  Date+Extension.swift
//  SeoulMate
//
//  Created by JuHyeon Seong on 6/9/25.
//

import Foundation

extension Date {
    public var summary: String {
        return DateFormatter.summaryWithDot.string(from: self)
    }
}
