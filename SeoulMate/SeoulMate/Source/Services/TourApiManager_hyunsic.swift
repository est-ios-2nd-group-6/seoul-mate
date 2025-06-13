//
//  TourApiManager_hyunsic.swift
//  SeoulMate
//
//  Created by DEV on 6/11/25.
//

import Foundation

struct SearchResult {
    var title:String
    var category:[String]
    var profileImage:String?
    var photos:[TourApiGoogleResponse.Photo]?
    var primaryTypeDisplayName:TourApiGoogleResponse.PrimaryTypeDisplayName?
    struct DisplayName: Codable {
        var text: String
        var languageCode: String
    }
    struct PrimaryTypeDisplayName: Codable {
        var text: String
        var lagnuageCode: String
    }
    
}

class TourApiManager_hs {
    
    static let shared = TourApiManager_hs()
    var searchByTitleResultList = [SearchResult]()

    private init() {}

//    func fetchRcmCourseList(keyword:String) async {
//        var baseUrl: String
//        var queryItems: [URLQueryItem]
//
//        baseUrl = "http://apis.data.go.kr/B551011/KorService2/searchKeyword2"
//        baseUrl.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
//        queryItems = [
//            URLQueryItem(name: "keyword", value: keyword),
//            URLQueryItem(name: "areaCode", value: "1"),  // 서울
//        ]
//
//        guard var url = URL(string: baseUrl) else {
//            print("invalida URL")
//            return
//        }
//        url.append(queryItems: getCommonHeaderKorPublic())
//        url.append(queryItems: queryItems)
//        
//        let request = URLRequest(url: url)
//
//        do {
//            let (data, urlResponse) = try await URLSession.shared.data(for: request)
//
//            guard let httpResponse = urlResponse as? HTTPURLResponse else {
//                return
//            }
//
//            guard 200...299 ~= httpResponse.statusCode else {
//                return
//            }
//            let decoder = JSONDecoder()
//
//            let formatter = DateFormatter()
//            formatter.dateFormat = "yyyyMMddHHmmss"
//
//            decoder.dateDecodingStrategy = .formatted(formatter)
//
//            let json = try decoder.decode(TourApiListResponseDto2.self, from: data)
//            
//            for (key,value) in json.response.body.items.item.enumerated() {
//                var item = SearchResult(title: value.title, profileImage: value.firstimage)
//                searchByTitleResultList.append(item)
//            }
//        } catch {
//            print("Fetcing Recommand Course List is Failed!!", error, separator: "\n")
//        }
//    }
    
    func fetchGooglePlaceAPI(keyword:String) async {
        var baseUrl: String
        var queryItems: [URLQueryItem]
        
        baseUrl = "https://places.googleapis.com/v1/places:searchText"
      queryItems = [
            URLQueryItem(name: "textQuery", value: keyword),
            URLQueryItem(name: "languageCode", value: "ko")
        ]
        guard var url = URL(string: baseUrl) else { print("invalida URL")
            return }
        url.append(queryItems: queryItems)
        
        
        var request = URLRequest(url: url)
        guard let googleApiKey = Bundle.main.googleApiKey else { return }
        
        request.httpMethod = "POST"
        request.setValue(googleApiKey, forHTTPHeaderField: "X-Goog-Api-Key")
        request.setValue("places.displayName,places.types,places.photos,places.primaryTypeDisplayName", forHTTPHeaderField: "X-Goog-FieldMask")
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
            for (key,value) in json.places.enumerated() {
                var result = SearchResult(title: value.displayName.text, category: value.types,profileImage: value.photos.first?.name,photos: value.photos,primaryTypeDisplayName: value.primaryTypeDisplayName)
                print(result)
                searchByTitleResultList.append(result)
            }
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
