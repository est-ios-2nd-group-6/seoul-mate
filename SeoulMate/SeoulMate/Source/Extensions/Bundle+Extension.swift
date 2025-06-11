//
//  Bundle+Extension.swift
//  SeoulMate
//
//  Created by JuHyeon Seong on 6/8/25.
//

import Foundation

extension Bundle {
    var tourApiKey: String? {
        return infoDictionary?["TourApiKey"] as? String
    }

    var naverMapApiKey: String? {
        return infoDictionary?["naverMapApiKey"] as? String
    }

    var googleRoutesApiKey: String? {
        return infoDictionary?["GoogleRoutesApiKey"] as? String
    }

    var tMapRoutesApiKey: String? {
        return infoDictionary?["TMapRoutesApiKey"] as? String
    }
}
