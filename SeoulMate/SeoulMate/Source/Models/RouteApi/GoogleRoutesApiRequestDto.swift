//
//  RoutesApiRequestDto.swift
//  SeoulMate
//
//  Created by JuHyeon Seong on 6/11/25.
//

import Foundation

/// Google Routes Api 요청 JSON 객체
struct GoogleRoutesApiRequestDto: Encodable {
    let origin: Destination
    let destination: Destination
    let intermediates: [Destination]?
    
    let travelMode: String = "TRANSIT"
    var computeAlternativeRoutes: Bool = false
    let languageCode = "ko-KR"
    let units = "METRIC"
    let polylineEncoding = "GEO_JSON_LINESTRING"
    var polylineQuality: String = "OVERVIEW"
}

struct Destination: Codable {
    struct Location: Codable {
        let latLng: LatLng
    }

    let location: Location

    init(latitude: Double, longitude: Double) {
        let latLng = LatLng(latitude: latitude, longitude: longitude)
        self.location = Location(latLng: latLng)
    }
}

struct LatLng: Codable {
    let latitude, longitude: Double
}
