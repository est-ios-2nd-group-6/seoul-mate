//
//  Storage.swift
//  SeoulMate
//
//  Created by 윤혜주 on 6/12/25.
//

import Foundation

struct Storage {
    private enum Keys {
        static let isFirstTime = "isFirstTime"
    }
    static func isFirstLaunch() -> Bool {
        let defaults = UserDefaults.standard
        if defaults.object(forKey: Keys.isFirstTime) == nil {
            defaults.set(true, forKey: Keys.isFirstTime)
            return true
        }
        return false
    }
}
