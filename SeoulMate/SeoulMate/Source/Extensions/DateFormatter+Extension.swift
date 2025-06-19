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

    static var monthDayWeekdayFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_kr")
        formatter.dateFormat = "M.d (E)"

        return formatter
    }
}
