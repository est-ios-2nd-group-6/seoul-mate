// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let welcome = try? JSONDecoder().decode(Welcome.self, from: jsonData)

import Foundation

struct RoutesApiResponseDto: Codable {
    struct Location: Codable {
        let latLng: High
    }

    let routes: [Route]
    let geocodingResults: GeocodingResults
}

struct GeocodingResults: Codable {
}

struct Route: Codable {
    let legs: [Leg]
    let distanceMeters: Int
    let duration, staticDuration: String
    let polyline: Polyline
    let viewport: Viewport
    let travelAdvisory: TravelAdvisory
    let localizedValues: LegLocalizedValues
    let routeLabels: [String]
}

struct Leg: Codable {
    let distanceMeters: Int
    let duration, staticDuration: String
    let polyline: Polyline
    let startLocation, endLocation: RoutesApiResponseDto.Location
    let steps: [Step]
    let localizedValues: LegLocalizedValues
    let stepsOverview: StepsOverview
}



struct High: Codable {
    let latitude, longitude: Double
}

struct LegLocalizedValues: Codable {
    let distance, duration, staticDuration: Distance
    let transitFare: GeocodingResults?
}

struct Distance: Codable {
    let text: String
}

struct Polyline: Codable {
    let geoJSONLinestring: GeoJSONLinestring

    enum CodingKeys: String, CodingKey {
        case geoJSONLinestring = "geoJsonLinestring"
    }
}

struct GeoJSONLinestring: Codable {
    let type: String
    let coordinates: [[Double]]
}

struct Step: Codable {
    let distanceMeters: Int?
    let staticDuration: String
    let polyline: Polyline
    let startLocation, endLocation: RoutesApiResponseDto.Location
    let navigationInstruction: NavigationInstruction
    let localizedValues: StepLocalizedValues
    let travelMode: String
    let transitDetails: TransitDetails?
}

struct StepLocalizedValues: Codable {
    let distance, staticDuration: Distance
}

struct NavigationInstruction: Codable {
    let instructions: String?
}

struct TransitDetails: Codable {
    let stopDetails: StopDetails
    let localizedValues: TransitDetailsLocalizedValues
    let headsign: String
    let headway: String?
    let transitLine: TransitLine
    let stopCount: Int
}

struct TransitDetailsLocalizedValues: Codable {
    let arrivalTime, departureTime: Time
}

struct Time: Codable {
    let time: Distance
    let timeZone: String
}

struct StopDetails: Codable {
    let arrivalStop: Stop
    let arrivalTime: Date
    let departureStop: Stop
    let departureTime: Date
}

struct Stop: Codable {
    let name: String
    let location: RoutesApiResponseDto.Location
}

struct TransitLine: Codable {
    let agencies: [Agency]
    let name, color, nameShort, textColor: String
    let vehicle: Vehicle
}

struct Agency: Codable {
    let name: String
    let uri: String
}

struct Vehicle: Codable {
    let name: Distance
    let type, iconURI: String

    enum CodingKeys: String, CodingKey {
        case name, type
        case iconURI = "iconUri"
    }
}

struct StepsOverview: Codable {
    let multiModalSegments: [MultiModalSegment]
}

struct MultiModalSegment: Codable {
    let stepStartIndex, stepEndIndex: Int
    let navigationInstruction: NavigationInstruction?
    let travelMode: String
}

struct TravelAdvisory: Codable {
    let transitFare: GeocodingResults
}

struct Viewport: Codable {
    let low, high: High
}
