//
//  TMapRoutesApiPedestrianResponseDto.swift
//  SeoulMate
//
//  Created by JuHyeon Seong on 6/10/25.
//

import Foundation

struct TMapRoutesApiResponseDto: Codable {
    let usedFavoriteRouteVertices: String?
    let type: String
    let features: [Feature]
}

struct Feature: Codable {
    let type: FeatureType
    let geometry: Geometry
    let properties: Properties
}

struct Geometry: Codable {
    let type: GeometryType
    let coordinates: [Coordinate]
}

enum Coordinate: Codable {
    case double(Double)
    case doubleArray([Double])

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let x = try? container.decode([Double].self) {
            self = .doubleArray(x)
            return
        }
        if let x = try? container.decode(Double.self) {
            self = .double(x)
            return
        }
        throw DecodingError.typeMismatch(Coordinate.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for Coordinate"))
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .double(let x):
            try container.encode(x)
        case .doubleArray(let x):
            try container.encode(x)
        }
    }
}

enum GeometryType: String, Codable {
    case lineString = "LineString"
    case point = "Point"
}

struct Properties: Codable {
    let totalDistance, totalTime: Int?
    let index: Int
    let pointIndex: Int?
    let name, description: String
    let direction, nearPoiName, nearPoiX, nearPoiY: String?
    let intersectionName: String?
//    let facilityType, facilityName: String?
    let turnType: Int?
    let pointType: PointType?
    let lineIndex, distance, time, roadType: Int?
    let categoryRoadType: Int?

    let totalFare, taxiFare: Int?
    let nextRoadName: String?
}

enum PointType: String, Codable {
    case ep = "EP"
    case gp = "GP"
    case sp = "SP"
    case e = "E"
    case n = "N"
    case s = "S"
}

enum FeatureType: String, Codable {
    case feature = "Feature"
}
