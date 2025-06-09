//
//  Common.swift
//  SeoulMate
//
//  Created by JuHyeon Seong on 6/9/25.
//

import Foundation

struct Header: Codable {
    let resultCode, resultMsg: String
}

enum Cat1: String, Codable {
    case c01 = "C01"
}

enum Cat2: String, Codable {
    case c0112 = "C0112"
    case c0113 = "C0113"
    case c0114 = "C0114"
    case c0115 = "C0115"
    case c0117 = "C0117"
}

enum Cat3: String, Codable {
    case c01120001 = "C01120001"
    case c01130001 = "C01130001"
    case c01140001 = "C01140001"
    case c01150001 = "C01150001"
    case c01170001 = "C01170001"
}

enum CpyrhtDivCD: String, Codable {
    case empty = ""
    case type3 = "Type3"
}

