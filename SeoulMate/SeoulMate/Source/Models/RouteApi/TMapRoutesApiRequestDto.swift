//
//  RoutesPedestrianRequestDto.swift
//  SeoulMate
//
//  Created by JuHyeon Seong on 6/11/25.
//

import Foundation

struct TMapRoutesApiRequestDto: Codable {
    let startX, startY: Double
    let startName: String
    let endX, endY: Double
    let endName: String
    var passList: String? = nil
    var searchOption: SearchOption = .recommand
}

enum SearchOption: Int, Codable, CaseIterable {
    case recommand = 0
    case preferBoulevard = 4
    case avoidStair = 30

    case fastest = 2
	case shortest = 10

    var title: String {
        switch self {
        case .recommand:
            return "추천경로"
        case .preferBoulevard:
            return "큰길우선"
        case .avoidStair:
            return "계단회피"
        case .fastest:
            return "최소시간"
        case .shortest:
            return "최단거리"
        }
    }
}
