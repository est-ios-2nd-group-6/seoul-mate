//
//  RouteApiManager.swift
//  SeoulMate
//
//  Created by JuHyeon Seong on 6/11/25.
//

import Foundation

enum travelMode {
    case walk
    case transit
    case drive
}

class RouteApiManager {
    static let shared = RouteApiManager()

    private init() {

    }

    //    public func calcRoute(mode: travelMode, startPoint: Location, endPoint: Location, intermediates: [Location]? = nil) async {
    //        switch mode {
    //        case .walk:
    //			calcRouteByWalk(startPoint: startPoint, endPoint: endPoint, intermediates: intermediates)
    //        case .transit:
    //            await calcRouteByTransit(startPoint: startPoint, endPoint: endPoint)
    //        case .drive:
    //            print("drive")
    //        }
    //    }

    public func calcRouteByDrive(startPoint: Location, endPoint: Location, intermediates: [Location]? = nil) async -> TMapRoutesApiResponseDto? {
        guard let url = URL(string: "https://apis.openapi.sk.com/tmap/routes?version=1&format=json") else {
            fatalError("URL Initialization is Failed")
        }

        guard let tMapRoutesApiKey = Bundle.main.tMapRoutesApiKey else {
            fatalError("T Map Routes Api Key is missing")
        }

        var routeReqDto = TMapRoutesApiRequestDto(
            startX: startPoint.longitude,
            startY: startPoint.latitude,
            startName: "test",
            endX: endPoint.longitude,
            endY: endPoint.latitude,
            endName: "test"
        )

        if let intermediates {
            let passList = intermediates.reduce("") {
                $0.appending("\($1.latitude)_\($1.longitude)")
            }

            routeReqDto.passList = passList
        }

        do {
            var request = URLRequest(url: url)

            request.httpMethod = "POST"
            request.httpBody = try JSONEncoder().encode(routeReqDto)

            request.addValue(tMapRoutesApiKey, forHTTPHeaderField: "appKey")
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")

            let session = URLSession.shared

            let (data, _) = try await session.data(for: request)

            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601

            let response = try decoder.decode(TMapRoutesApiResponseDto.self, from: data)

            return response
        } catch {
            print(error)
        }

        return nil
    }

    public func calcRouteByTransit(startPoint: Location, endPoint: Location) async -> GoogleRoutesApiResponseDto? {
        guard let url = URL(string: "https://routes.googleapis.com/directions/v2:computeRoutes") else {
            fatalError("URL Initialization is Failed")
        }

        guard let googleRoutesApiKey = Bundle.main.googleRoutesApiKey else {
            fatalError("Google Routes Api Key is missing")
        }

        let origin = Destination(latitude: startPoint.latitude, longitude: startPoint.longitude)
        let destination = Destination(latitude: endPoint.latitude, longitude: endPoint.longitude)

        let routeReqDto = GoogleRoutesApiRequestDto(
            origin: origin,
            destination: destination,
            intermediates: nil
        )

        do {
            var request = URLRequest(url: url)

            request.httpMethod = "POST"
            request.httpBody = try JSONEncoder().encode(routeReqDto)

            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue(googleRoutesApiKey, forHTTPHeaderField: "X-Goog-Api-Key")
            request.addValue("*", forHTTPHeaderField: "X-Goog-FieldMask")
            request.addValue(Bundle.main.bundleIdentifier ?? "", forHTTPHeaderField: "X-Ios-Bundle-Identifier")

            let session = URLSession.shared

            let (data, _) = try await session.data(for: request)

            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601

            let response = try decoder.decode(GoogleRoutesApiResponseDto.self, from: data)

            return response
        } catch {
            print(error)
        }

        return nil
    }

    public func calcRouteByWalk(startPoint: Location, endPoint: Location, intermediates: [Location]? = nil) async -> TMapRoutesApiResponseDto? {
        guard let url = URL(string: "https://apis.openapi.sk.com/tmap/routes/pedestrian?version=1&format=json") else {
            fatalError("URL Initialization is Failed")
        }

        guard let tMapRoutesApiKey = Bundle.main.tMapRoutesApiKey else {
            fatalError("T Map Routes Api Key is missing")
        }

        var routeReqDto = TMapRoutesApiRequestDto(
            startX: startPoint.longitude,
            startY: startPoint.latitude,
            startName: "test",
            endX: endPoint.longitude,
            endY: endPoint.latitude,
            endName: "test"
        )

        if let intermediates {
            let passList = intermediates.reduce("") {
                $0.appending("\($1.latitude)_\($1.longitude)")
            }

            routeReqDto.passList = passList
        }

        do {
            var request = URLRequest(url: url)

            request.httpMethod = "POST"
            request.httpBody = try JSONEncoder().encode(routeReqDto)

            request.addValue(tMapRoutesApiKey, forHTTPHeaderField: "appKey")
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")

            let session = URLSession.shared

            let (data, _) = try await session.data(for: request)

            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601

            let response = try decoder.decode(TMapRoutesApiResponseDto.self, from: data)

            return response
        } catch {
            print(error)
        }

        return nil

    }
}
