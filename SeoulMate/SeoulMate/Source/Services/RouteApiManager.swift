//
//  RouteApiManager.swift
//  SeoulMate
//
//  Created by JuHyeon Seong on 6/11/25.
//

import Foundation

/// 경로 탐색 시 사용할 교통수단 옵션.
enum RouteOption: String, Hashable, CaseIterable {
    case drive = "DRIVE"
    case walk = "WALK"
    case transit = "TRANSIT"

    /// 각 교통수단에 따른 세부 검색 옵션 배열.
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

/// TMap 및 Google Routes API를 사용하여 경로 정보를 가져오는 싱글톤 클래스.
class RouteApiManager {
    static let shared = RouteApiManager()

    private init() { }

    /// 교통수단 타입에 맞는 API 기본 URL을 반환.
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

    /// TMap API를 사용하여 자동차 또는 도보 경로를 비동기적으로 계산.
    /// - Parameters:
    ///   - type: 교통수단 옵션 (`.drive` 또는 `.walk`).
    ///   - searchOption: 경로 검색 옵션 (추천, 최단 등).
    ///   - startPoint: 출발지 좌표.
    ///   - endPoint: 도착지 좌표.
    ///   - intermediates: 경유지 좌표 배열 (옵셔널).
    /// - Returns: TMap 경로 API 응답 DTO (`TMapRoutesApiResponseDto`). 실패 시 `nil`.
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

        // 경유지가 있는 경우, "경도,위도_경도,위도" 형식의 문자열로 변환하여 요청에 추가.
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

    /// Google Routes API를 사용하여 대중교통 경로를 비동기적으로 계산.
    /// - Parameters:
    ///   - startPoint: 출발지 좌표.
    ///   - endPoint: 도착지 좌표.
    /// - Returns: Google Routes API 응답 DTO (`GoogleRoutesApiResponseDto`). 실패 시 `nil`.
    public func calcRouteTransitByGoogle(startPoint: Location, endPoint: Location) async -> GoogleRoutesApiResponseDto? {
        guard let url = URL(string: "https://routes.googleapis.com/directions/v2:computeRoutes") else {
            fatalError("URL Initialization is Failed")
        }

        guard let googleApiKey = Bundle.main.googleApiKey else {
            fatalError("Google Api Key is missing")
        }

        let origin = Destination(latitude: startPoint.latitude, longitude: startPoint.longitude)
        let destination = Destination(latitude: endPoint.latitude, longitude: endPoint.longitude)

        let routeReqDto = GoogleRoutesApiRequestDto(
            origin: origin,
            destination: destination,
            intermediates: nil,
            computeAlternativeRoutes: false,
            polylineQuality: "HIGH_QUALITY"
        )

        do {
            var request = URLRequest(url: url)

            request.httpMethod = "POST"
            request.httpBody = try JSONEncoder().encode(routeReqDto)

            request.addValue("application/json; charset=UTF-8", forHTTPHeaderField: "Content-Type")
            request.addValue("*/*", forHTTPHeaderField: "Aceept")
            request.addValue("gzip, deflate, br", forHTTPHeaderField: "Aceept-Encoding")
            request.addValue("keep-alive", forHTTPHeaderField: "Connection")

            request.addValue(googleApiKey, forHTTPHeaderField: "X-Goog-Api-Key")
            // FieldMask를 사용하여 필요한 데이터만 선택적으로 요청.
            request.addValue("routes.distanceMeters,routes.duration,routes.legs.startLocation,routes.legs.endLocation,routes.legs.steps", forHTTPHeaderField: "X-Goog-FieldMask")
            request.addValue(Bundle.main.bundleIdentifier ?? "", forHTTPHeaderField: "X-Ios-Bundle-Identifier")

            let session = URLSession(configuration: .ephemeral)

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
