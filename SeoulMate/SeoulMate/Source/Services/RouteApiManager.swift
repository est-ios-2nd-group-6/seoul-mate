//
//  RouteApiManager.swift
//  SeoulMate
//
//  Created by JuHyeon Seong on 6/11/25.
//

import Foundation

enum RouteOption:String, Hashable, CaseIterable {
    case drive = "DRIVE"
    case walk = "WALK"
    case transit = "TRANSIT"

    var searchOptions: [SearchOption]? {
        switch self {
        case .drive:
            return [.recommand, .fastest, .shortest]
        case .walk:
            return [.recommand, .preferBoulevard, .avoidStair]
        case .transit:
            return nil
        }
    }
}

class RouteApiManager {
    static let shared = RouteApiManager()

    private init() { }

    private func getApiUrl(type: RouteOption) -> URL? {
        var baseUrl: String

        switch type {
        case .drive:
            baseUrl = "https://apis.openapi.sk.com/tmap/routes?version=1&format=json"
        case .transit:
            baseUrl = "https://routes.googleapis.com/directions/v2:computeRoutes"
        case .walk:
            baseUrl = "https://apis.openapi.sk.com/tmap/routes/pedestrian?version=1&format=json"
        }

        return URL(string: baseUrl)
    }

    public func calcRouteByTMap(type: RouteOption, searchOption: SearchOption? = nil, startPoint: Location, endPoint: Location, intermediates: [Location]? = nil) async -> TMapRoutesApiResponseDto? {
        guard let url = getApiUrl(type: type) else {
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
            endName: "test",
            trafficInfo: "Y",
        )

        if let intermediates {
            let passList = intermediates.map { "\($0.longitude),\($0.latitude)" }.joined(separator: "_")

            routeReqDto.passList = passList
        }

        if let searchOption {
            routeReqDto.searchOption = searchOption
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

    public func calcRouteTransitByGoogle(startPoint: Location, endPoint: Location) async -> GoogleRoutesApiResponseDto? {
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
            intermediates: nil,
            computeAlternativeRoutes: false
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
}
