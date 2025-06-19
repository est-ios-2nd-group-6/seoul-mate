//
//  TourApiManager.swift
//  SeoulMate
//
//  Created by JuHyeon Seong on 6/8/25.
//

import Foundation

/// TourAPI 호출 시 지역 코드 정의.
enum AreaCode: Int {
    case seoul = 1
}

/// 추천 코스 목록 조회 API의 타입 정의.
enum fetchCourseListType: String {
    case area // 지역 기반
    case location // 위치 기반
}

/// 한국관광공사 TourAPI 관련 통신을 관리하는 싱글톤 클래스.
class TourApiManager {
    static let shared = TourApiManager()

    /// API 호출 결과를 저장하는 캐시 프로퍼티.
    var rcmCourseListByArea: [RecommandCourse] = []
    var rcmCourseListByLocation: [RecommandCourse] = []

    private init() { }

    /// 추천 여행 코스 목록을 비동기적으로 조회.
    /// - Parameters:
    ///   - by: 조회 기준 (`.area` 또는 `.location`).
    ///   - x: 경도 (위치 기반 조회 시 필요).
    ///   - y: 위도 (위치 기반 조회 시 필요).
    func fetchRcmCourseList(by: fetchCourseListType, x: Double? = nil, y: Double? = nil) async {

        var baseUrl: String
        var queryItems: [URLQueryItem]

        switch by {
        case .area:
            // 서울 지역의 대표 이미지가 있는 여행 코스를 제목순으로 정렬하여 요청.
            baseUrl = "http://apis.data.go.kr/B551011/KorService2/areaBasedList2"

            queryItems = [
                URLQueryItem(name: "arrange", value: "O"),
                URLQueryItem(name: "contentTypeId", value: "25"),
                URLQueryItem(name: "areaCode", value: "1")
            ]
        case .location:
            // 특정 좌표를 기준으로 반경 20km 내의 여행 코스를 거리순으로 정렬하여 요청.
            guard let x, let y else {
                print("x, y is missing")
                return
            }

            baseUrl = "http://apis.data.go.kr/B551011/KorService2/locationBasedList2"

            queryItems = [
                URLQueryItem(name: "arrange", value: "S"),
                URLQueryItem(name: "mapX", value: String(x)),
                URLQueryItem(name: "mapY", value: String(y)),
                URLQueryItem(name: "radius", value: "20000"),
                URLQueryItem(name: "contentTypeId", value: "25"),
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
            let (data, _) = try await URLSession.shared.data(for: request)

            let decoder = JSONDecoder()

            let formatter = DateFormatter()
            formatter.dateFormat = "yyyyMMddHHmmss"

            decoder.dateDecodingStrategy = .formatted(formatter)

            let json = try decoder.decode(TourApiListResponseDto.self, from: data)

            let courseList = json.response.body.items.item

            // 각 코스에 대해 대표 이미지를 비동기적으로 다운로드하여 모델에 추가.
            for course in courseList {
                var rcmCourse = RecommandCourse(courseItem: course)

                let image = await ImageManager.shared.getImage(course.firstimage)
                rcmCourse.image = image

                if by == .area {
                    rcmCourseListByArea.append(rcmCourse)
                } else {
                    rcmCourseListByLocation.append(rcmCourse)
                }
            }
        } catch {
            print("Fetcing Recommand Course List is Failed!!", error, separator: "\n")
        }
    }

    /// 특정 여행 코스(contentId)의 상세 정보(포함된 장소 목록)를 조회.
    /// - Parameter id: 조회할 코스의 콘텐츠 ID.
    /// - Returns: `TourAPIDetailInfoItem` 배열. 실패 시 `nil`.
    func fetchRcmCourseDetail(_ id: String) async -> [TourAPIDetailInfoItem]? {
        guard var url = URL(string: "http://apis.data.go.kr/B551011/KorService2/detailInfo2") else {
            print("invalida URL")
            return nil
        }

        url.append(queryItems: getCommonHeader())

        url.append(queryItems: [
            URLQueryItem(name: "contentId", value: id),
            URLQueryItem(name: "contentTypeId", value: "25"),
        ])

        let request = URLRequest(url: url)

        do {
            let (data, _) = try await URLSession.shared.data(for: request)

            let json = try JSONDecoder().decode(TourAPIDetailInfoResponseDto.self, from: data)

            let detailInfo = json.response.body.items.item

            return detailInfo
        } catch {
            print("Fetcing Recommand Course Detail is Failed!!", error, separator: "\n")
        }
        return nil
    }

    /// 특정 콘텐츠 ID의 공통 상세 정보(개요, 주소 등)를 조회.
    /// - Parameter id: 조회할 콘텐츠의 ID.
    /// - Returns: `TourApiCommonDetailInfoItem` 객체. 실패 시 `nil`.
    func fetchCommonDetailInfo(_ id: String) async -> TourApiCommonDetailInfoItem? {
        guard var url = URL(string: "http://apis.data.go.kr/B551011/KorService2/detailCommon2") else {
            print("invalida URL")
            return nil
        }

        url.append(queryItems: getCommonHeader())
        url.append(queryItems: [
            URLQueryItem(name: "contentId", value: id)
        ])

        let request = URLRequest(url: url)

        do {
            let (data, _) = try await URLSession.shared.data(for: request)

            let json = try JSONDecoder().decode(TourApiDetailCommonResponseDto.self, from: data)
            let commonDetailInfo = json.response.body.items.item.first

            return commonDetailInfo
        } catch {
            print("Fetcing Common Detail Info is Failed!!", error, separator: "\n")
        }
        return nil
    }

    /// TourAPI 호출에 필요한 공통 헤더 쿼리 아이템을 생성.
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
