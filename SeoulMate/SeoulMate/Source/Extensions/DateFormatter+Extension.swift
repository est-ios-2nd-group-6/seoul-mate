//
//  DateFormatter+Extension.swift
//  SeoulMate
//
//  Created by JuHyeon Seong on 6/9/25.
//

import Foundation

extension DateFormatter {
    static var summaryWithDot: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM.dd"

        return formatter
    }
}
