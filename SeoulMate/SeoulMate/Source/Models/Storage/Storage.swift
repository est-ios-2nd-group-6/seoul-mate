//
//  Storage.swift
//  SeoulMate
//
//  Created by 윤혜주 on 6/12/25.
//

import Foundation

/// `Storage`는 앱의 실행 여부를 UserDefaults에 저장하고 조회하는 유틸리티입니다.
struct Storage {
    /// UserDefaults에 저장되는 키들을 모아둔 내부 열거형
    private enum Keys {
        /// 앱이 처음 실행되었는지 여부를 저장하는 키
        static let isFirstTime = "isFirstTime"
    }

    /// 앱이 최초 실행인지 여부를 판단합니다.
    ///
    /// - Returns:
    ///   - `true`: UserDefaults에 해당 키가 없어, 처음 실행으로 판단하고 `true`를 저장한 뒤 반환합니다.
    ///   - `false`: 이미 키가 존재하여 첫 실행이 아니라고 판단합니다.
    static func isFirstLaunch() -> Bool {
        // 아직 저장된 값이 없으면, 첫 실행으로 처리
        let defaults = UserDefaults.standard
        if defaults.object(forKey: Keys.isFirstTime) == nil {
            defaults.set(true, forKey: Keys.isFirstTime)
            return true
        }
        // 저장된 값이 있으면, 재실행으로 간주
        return false
    }
}
