//
//  GooglePlaceApiMnager.swift
//  SeoulMate
//
//  Created by JuHyeon Seong on 6/16/25.
//

import Foundation

enum GooglePlaceApiError: Error {
    case invalidURL
    case apiKeyNotFound
    case responseNotFound
    case invalidStatusCode
}

struct fetchGooglePlaceNameResponoseDto: Codable {
    struct Place: Codable {
        let name: String
    }

    let places: [Place]
}


class GooglePlaceApiManager {
    static let shared = GooglePlaceApiManager()

    private init() {

    }

    func fetchGooglePlaceName(textQuery: String) async -> String? {
        let baseUrl: String = "https://places.googleapis.com/v1/places:searchText"

        var queryItems: [URLQueryItem]

        queryItems = [
            URLQueryItem(name: "textQuery", value: textQuery),
            URLQueryItem(name: "languageCode", value: "ko")
        ]

        guard var url = URL(string: baseUrl) else {
            return nil
        }

        url.append(queryItems: queryItems)

        var request = URLRequest(url: url)

        guard let googleApiKey = Bundle.main.googleApiKey else {
            return nil
        }

        var fieldMasks: [String] = [
            "places.name",
        ]

        request.httpMethod = "POST"

        request.setValue(googleApiKey, forHTTPHeaderField: "X-Goog-Api-Key")
        request.setValue(Bundle.main.bundleIdentifier, forHTTPHeaderField: "X-Ios-Bundle-Identifier")
        request.setValue(fieldMasks.joined(separator: ","), forHTTPHeaderField: "X-Goog-FieldMask")

        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            let (data, urlResponse) = try await URLSession.shared.data(for: request)

            guard let httpResponse = urlResponse as? HTTPURLResponse else {
                return nil
            }

            guard 200...299 ~= httpResponse.statusCode else {
                return nil
            }

            let json = try JSONDecoder().decode(fetchGooglePlaceNameResponoseDto.self, from: data)

            return json.places[0].name
        } catch {
            print("Fetcing is Failed!!", error, separator: "\n")

            return nil
        }
    }
}
