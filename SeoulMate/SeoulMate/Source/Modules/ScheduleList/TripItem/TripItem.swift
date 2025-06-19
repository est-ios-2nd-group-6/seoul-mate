//
//  TripItem.swift
//  SeoulMate
//
//  Created by 윤혜주 on 6/13/25.
//

import Foundation

/// 일정 목록에서 사용되는 항목을 나타내는 열거형입니다.
///
/// - `sectionTitle`: 일정 목록의 구역 제목(섹션 헤더)으로 사용됩니다.
/// - `trip`: 실제 `Tour` 모델 객체를 표시합니다.
enum TripItem {
    /// 섹션 제목을 나타내며, 연관 값으로 제목 문자열을 가집니다.
    case sectionTitle(String)

    /// 여행 투어 항목을 나타내며, 연관 값으로 `Tour` 객체를 가집니다.
    case trip(Tour)
}
