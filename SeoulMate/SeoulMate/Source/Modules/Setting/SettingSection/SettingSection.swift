//
//  SettingSection.swift
//  SeoulMate
//
//  Created by 윤혜주 on 6/16/25.
//

import Foundation

/// `SettingSection`은 설정 화면의 섹션 구분을 정의하는 열거형입니다.
/// 각 섹션은 제목과 해당 섹션에 표시될 액션 목록을 제공합니다.
enum SettingSection: Int, CaseIterable {
    /// 관심사 설정 섹션
    case interest
    /// 위치 권한 설정 섹션
    case location

    /// 섹션 헤더에 표시될 제목
    var title: String {
        switch self {
        case .interest: return "관심사 설정"
        case .location: return "위치 권한 설정"
        }
    }

    /// 섹션에 포함된 액션 타입들의 배열
    var actions: [ActionType] {
        switch self {
        case .interest: return [.interestSetting]
        case .location: return [.locationPermission]
        }
    }

    /// 섹션별 액션 타입을 정의하는 내부 열거형
    enum ActionType {
        case interestSetting
        case locationPermission

        var displayText: String {
            switch self {
            case .interestSetting: return "관심사 다시 선택하기"
            case .locationPermission: return "위치 권한 재설정"
            }
        }

        /// 해당 액션이 트리거할 세그웨이 식별자 (없으면 nil)
        var segueIdentifier: String? {
            switch self {
            case .interestSetting: return "showTagSetting"
            case .locationPermission: return nil
            }
        }
    }
}
