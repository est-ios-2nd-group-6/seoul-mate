//
//  SettingSection.swift
//  SeoulMate
//
//  Created by 윤혜주 on 6/16/25.
//

import Foundation

enum SettingSection: Int, CaseIterable {
    case interest
    case location

    var title: String {
        switch self {
        case .interest: return "관심사 설정"
        case .location: return "위치 권한 설정"
        }
    }

    var actions: [ActionType] {
        switch self {
        case .interest: return [.interestSetting]
        case .location: return [.locationPermission]
        }
    }

    enum ActionType {
        case interestSetting
        case locationPermission

        var displayText: String {
            switch self {
            case .interestSetting: return "관심사 다시 선택하기"
            case .locationPermission: return "위치 권한 재설정"
            }
        }

        var segueIdentifier: String? {
            switch self {
            case .interestSetting: return "showTagSetting"
            case .locationPermission: return nil
            }
        }
    }
}
