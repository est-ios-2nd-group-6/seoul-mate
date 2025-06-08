//
//  TourApiManager.swift
//  SeoulMate
//
//  Created by JuHyeon Seong on 6/8/25.
//

import Foundation

enum AreaCode: Int {
    case seoul = 1
}

enum fetchCourseListType: String {
    case area
    case location
}

class TourApiManager {
	static let shared = TourApiManager()

    private init() {

    }

    func fetchRcmCourseListByArea(by: fetchCourseListType, x: Double?, y: Double?) async {

        var baseUrl: String
        var queryItems: [URLQueryItem]

        guard let x, let y else {
            print("coordinate x, y is missing")

            return
        }

        switch by {
        case .area:
            baseUrl = "http://apis.data.go.kr/B551011/KorService2/areaBasedList2"
            queryItems = [
                URLQueryItem(name: "arrange", value: "O"), // 대표 이미지가 반드시 있는 항목 제목순 정렬
                URLQueryItem(name: "contentTypeId", value: "25"),
                URLQueryItem(name: "areaCode", value: "1") // 서울
            ]
        case .location:
            baseUrl = "http://apis.data.go.kr/B551011/KorService2/locationBasedList2"
            queryItems = [
                URLQueryItem(name: "arrange", value: "S"), // 대표 이미지가 반드시 있는 항목 거리순 정렬
                URLQueryItem(name: "mapX", value: String(x)),
                URLQueryItem(name: "mapY", value: String(y)),
                URLQueryItem(name: "radius", value: "20000"), // 반경 20km(20000m)
            ]
        }

        guard var url = URL(string: baseUrl) else {
            print("invalida URL")

            return
        }

        url.append(queryItems: getCommonHeader())
        url.append(queryItems: queryItems)

        let request = URLRequest(url: url)

        do {
            let (data, urlResponse) = try await URLSession.shared.data(for: request)

            guard let httpResponse = urlResponse as? HTTPURLResponse else {
				return
            }

        	guard 200...299 ~= httpResponse.statusCode else {
                return
            }

            let json = try JSONDecoder().decode(TourApiAreaBasedListResponseDto.self, from: data)

            if let resultCd = json.resultCode, let resultMsg = json.resultMsg {
				print(resultCd, resultMsg)

                return
            }

            let rcmCourses = json.response.body.items.item

            for rcmCourse in rcmCourses {
                guard let contentId = rcmCourse.contentid else { continue }

                print(contentId)

                // 코스 상세 정보 조회
                await fetchRcmCourseDetail(contentId)

                print()
            }

        } catch {
            print("Fetcing Recommand Course List is Failed!!", error, separator: "\n")
        }
    }
    
    /// 한국관광공사 국문 관광정보 서비스 > 상세정보조회 API 호출
    /// - Parameter id: 상세 정보 조회할 컨텐츠(관광지, 숙박시설, 여행코스 ...) ID
    func fetchRcmCourseDetail(_ id: String) async {
        guard var url = URL(string: "http://apis.data.go.kr/B551011/KorService2/detailInfo2") else {
            print("invalida URL")

            return
        }

        url.append(queryItems: getCommonHeader())

        url.append(queryItems: [
            URLQueryItem(name: "contentId", value: id),
            URLQueryItem(name: "contentTypeId", value: "25"),
        ])

        let request = URLRequest(url: url)

        do {
            let (data, urlResponse) = try await URLSession.shared.data(for: request)

            guard let httpResponse = urlResponse as? HTTPURLResponse else {
                return
            }

            guard 200...299 ~= httpResponse.statusCode else {
                return
            }

            let json = try JSONDecoder().decode(TourAPIDetailInfoResponseDto.self, from: data)

            if let resultCd = json.resultCode, let resultMsg = json.resultMsg {
                print(resultCd, resultMsg)

                return
            }

            let courses = json.response.body.items.item

            for course in courses {
                print(course)
            }

        } catch {
            print("Fetcing Recommand Course Detail is Failed!!", error, separator: "\n")
        }

    }

    private func getCommonHeader(numOfRows: Int = 10, pageNo: Int = 1) -> [URLQueryItem] {
        guard let tourApiKey = Bundle.main.tourApiKey else {
			print("API KEY를 찾을 수 없습니다.")

            return []
        }

        return [
			URLQueryItem(name: "numOfRows", value: String(numOfRows)),
            URLQueryItem(name: "pageNo", value: String(pageNo)),
            URLQueryItem(name: "MobileOS", value: "IOS"),
            URLQueryItem(name: "MobileApp", value: "SeoulMate"),
            URLQueryItem(name: "_type", value: "json"),
            URLQueryItem(name: "serviceKey", value: tourApiKey)
        ]
    }
}
