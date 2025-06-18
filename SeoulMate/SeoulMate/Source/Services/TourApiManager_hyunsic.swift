//
//  TourApiManager_hyunsic.swift
//  SeoulMate
//
//  Created by DEV on 6/11/25.
//

import Foundation

struct SearchResult {
    var id: String
    var title: String
    var rating: Double
    var category: [String]?
    var profileImage: String?
    var photos: [TourApiGoogleResponse.Photo]?
    var primaryTypeDisplayName: TourApiGoogleResponse.PrimaryTypeDisplayName?
    var address: String?
    var location: TourApiGoogleResponse.Location
    struct DisplayName: Codable {
        var text: String
        var languageCode: String
    }
    struct PrimaryTypeDisplayName: Codable {
        var text: String
        var lagnuageCode: String
    }
}

struct PlaceInfo {
    var id: String
    var title: String
    var rating: Double?
    var address: String
    var profileImage: URL?
    var photosName: String?
    var width: Int?
    var height: Int?
    var longitude: Double?
    var latitude: Double?
    var types: [String]?
}

struct CurrentLocation {
    var longitude: Double
    var latitude: Double
}

class TourApiManager_hs {

    static let shared = TourApiManager_hs()
    var searchByTitleResultList = [SearchResult]()
    var placeInfo: PlaceInfo?
    var nearybyPlaceList: [TourNearybyAPIGoogleResponse.Place] = [TourNearybyAPIGoogleResponse.Place]()

    private init() {}

    func fetchGooglePlaceAPIByKeyword(keyword: String) async {
        var baseUrl: String
        var queryItems: [URLQueryItem]

        baseUrl = "https://places.googleapis.com/v1/places:searchText"
        queryItems = [
            URLQueryItem(name: "textQuery", value: keyword),
            URLQueryItem(name: "languageCode", value: "ko"),
        ]
        guard var url = URL(string: baseUrl) else {
            print("invalida URL")
            return
        }
        url.append(queryItems: queryItems)

        var request = URLRequest(url: url)
        guard let googleApiKey = Bundle.main.googleApiKey else { return }

        request.httpMethod = "POST"
        request.setValue(googleApiKey, forHTTPHeaderField: "X-Goog-Api-Key")
        request.setValue(
            "places.id,places.displayName,places.types,places.photos,places.primaryTypeDisplayName,places.rating,places.location",
            forHTTPHeaderField: "X-Goog-FieldMask"
        )
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            let (data, urlResponse) = try await URLSession.shared.data(for: request)
            guard let httpResponse = urlResponse as? HTTPURLResponse else {
                return
            }

            guard 200...299 ~= httpResponse.statusCode else {
                return
            }
            let decoder = JSONDecoder()

            let formatter = DateFormatter()
            formatter.dateFormat = "yyyyMMddHHmmss"
            decoder.dateDecodingStrategy = .formatted(formatter)
            let json = try decoder.decode(TourApiGoogleResponse.self, from: data)
            searchByTitleResultList.removeAll()
            for (_, value) in json.places.enumerated() {
                let result = SearchResult(
                    id: value.id,
                    title: value.displayName.text,
                    rating: value.rating ?? 0,
                    category: value.types,
                    profileImage: value.photos.first?.name,
                    photos: value.photos,
                    primaryTypeDisplayName: value.primaryTypeDisplayName,
                    location: value.location
                )
                searchByTitleResultList.append(result)
            }
        } catch {
            print("Fetcing is Failed!!", error, separator: "\n")
        }
    }

    func fetchGooglePlaceAPIByName(name: String) async {
        var baseUrl: String
        var queryItems: [URLQueryItem]

        baseUrl = "https://places.googleapis.com/v1/places/\(name)"
        queryItems = [
            URLQueryItem(name: "languageCode", value: "ko")
        ]
        guard var url = URL(string: baseUrl) else {
            print("invalida URL")
            return
        }
        url.append(queryItems: queryItems)

        var request = URLRequest(url: url)
        guard let googleApiKey = Bundle.main.googleApiKey else { return }

        request.setValue(googleApiKey, forHTTPHeaderField: "X-Goog-Api-Key")
        request.setValue("id,formattedAddress,rating,displayName,photos,location", forHTTPHeaderField: "X-Goog-FieldMask")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            let (data, urlResponse) = try await URLSession.shared.data(for: request)
            guard let httpResponse = urlResponse as? HTTPURLResponse else {
                return
            }

            guard 200...299 ~= httpResponse.statusCode else {
                return
            }
            let decoder = JSONDecoder()
            let json = try decoder.decode(TourAPIGoogleResponseShort.self, from: data)
            placeInfo = PlaceInfo(
                id: json.id,
                title: json.displayName.text,
                rating: json.rating,
                address: json.formattedAddress,
                longitude: json.location.longitude,
                latitude: json.location.latitude,
            )
            guard
                let url = URL(
                    string:
                        "https://places.googleapis.com/v1/\(json.photos.first!.name)/media?maxHeightPx=2000&maxWidthPx=3000&key=\(googleApiKey)"
                )
            else { return }
            placeInfo?.profileImage = url
        } catch {
            print("Fetcing is Failed!!", error, separator: "\n")
        }
    }

    func fetchPOIDetailNearbyPlace(latitude: Double, longitude: Double) async {
        var baseUrl: String
        var queryItems: [URLQueryItem]

        baseUrl = "https://places.googleapis.com/v1/places:searchNearby"
        queryItems = [
            URLQueryItem(name: "languageCode", value: "ko")
        ]
        guard var url = URL(string: baseUrl) else {
            print("invalida URL")
            return
        }
        url.append(queryItems: queryItems)
        var request = URLRequest(url: url)
        guard let googleApiKey = Bundle.main.googleApiKey else { return }
        request.httpMethod = "POST"
        let requestBody = TourNearybyAPIGoogleRequest(latitude: latitude, longitude: longitude)
        request.setValue(googleApiKey, forHTTPHeaderField: "X-Goog-Api-Key")
        request.setValue(
            "places.id,places.formattedAddress,places.rating,places.displayName,places.primaryTypeDisplayName,places.location,places.photos,places.types",
            forHTTPHeaderField: "X-Goog-FieldMask"
        )
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        do {
            let encoder = JSONEncoder()
            encoder.keyEncodingStrategy = .convertToSnakeCase
            let bodyData = try encoder.encode(requestBody)
            request.httpBody = bodyData
            let (data, response) = try await URLSession.shared.data(for: request)
            let decoder = JSONDecoder()
            let json = try decoder.decode(TourNearybyAPIGoogleResponse.self, from: data)
            self.nearybyPlaceList = json.places
        } catch {
            print("Fetcing is Failed!!", error, separator: "\n")
        }
    }

    private func getCommonHeaderKorPublic(numOfRows: Int = 10, pageNo: Int = 1) -> [URLQueryItem] {
        guard let tourApiKey = Bundle.main.tourApiKey else {
            print("API KEY를 찾을 수 없습니다.")
            return []
        }
        return [
            URLQueryItem(name: "numOfRows", value: String(numOfRows)),
            URLQueryItem(name: "pageNo", value: String(pageNo)),
            URLQueryItem(name: "MobileOS", value: "iOS"),
            URLQueryItem(name: "MobileApp", value: "seoulMate"),
            URLQueryItem(name: "_type", value: "json"),
            URLQueryItem(name: "serviceKey", value: tourApiKey),
        ]
    }

}
