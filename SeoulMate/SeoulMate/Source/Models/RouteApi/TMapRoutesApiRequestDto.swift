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
    var searchOption: Int = 0
}
