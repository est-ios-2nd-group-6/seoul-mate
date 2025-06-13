//
//  CoreData+SampleData.swift
//  SeoulMate
//
//  Created by 윤혜주 on 6/12/25.
//

import Foundation
import CoreData

extension CoreDataManager {
    func seedDummyData() {
        guard fetchTours().isEmpty else { return }

        // Tour 1: 역사 탐방
        let tour1 = Tour(context: context)
        tour1.id = UUID()
        tour1.title = "서울 역사 탐방"
        tour1.startDate = Date()
        tour1.endDate = Calendar.current.date(byAdding: .day, value: 2, to: tour1.startDate!)!
        tour1.transportMode = "도보"
        tour1.notes = "경복궁, 북촌한옥마을 위주"
        tour1.createdAt = Date()

        // Day 1 POIs
        let schedule1 = Schedule(context: context)
        schedule1.id = UUID()
        schedule1.date = tour1.startDate
        schedule1.tour = tour1
        let poisDay1 = [
            ("경복궁","서울 종로구 사직로 161",37.5796,126.9770,"고궁","09:00-18:00",4.5,"200명",""),
            ("북촌한옥마을","서울 종로구 계동길 37",37.5822,126.9830,"한옥마을","상시 개방",4.2,"150명",""),
            ("창덕궁","서울 종로구 율곡로 99",37.5794,126.9910,"고궁","09:00-18:00",4.3,"180명","")
        ]
        for item in poisDay1 {
            let poi = POI(context: context)
            poi.id = UUID()
            poi.name = item.0
            poi.address = item.1
            poi.latitude = item.2
            poi.longitude = item.3
            poi.category = item.4
            poi.openingHours = item.5
            poi.rating = item.6
            poi.descriptionText = "⭐️ 평점: \(item.6) (\(item.7))"
            poi.imageURL = item.8
            poi.isSaved = false
            poi.tour = tour1
            poi.schedule = schedule1
        }

        // Day 2 POIs
        let schedule2 = Schedule(context: context)
        schedule2.id = UUID()
        schedule2.date = Calendar.current.date(byAdding: .day, value: 1, to: tour1.startDate!)!
        schedule2.tour = tour1
        let poisDay2 = [
            ("인사동거리","서울 종로구 인사동길",37.5740,126.9852,"스트리트아트","상시 개방",4.0,"120명",""),
            ("덕수궁","서울 중구 세종대로 99",37.5656,126.9769,"고궁","09:00-19:00",4.1,"160명",""),
            ("서울시립미술관","서울 중구 덕수궁길 61",37.5658,126.9769,"뮤지엄·미술관","10:00-18:00",4.4,"140명","")
        ]
        for item in poisDay2 {
            let poi = POI(context: context)
            poi.id = UUID()
            poi.name = item.0
            poi.address = item.1
            poi.latitude = item.2
            poi.longitude = item.3
            poi.category = item.4
            poi.openingHours = item.5
            poi.rating = item.6
            poi.descriptionText = "⭐️ 평점: \(item.6) (\(item.7))"
            poi.imageURL = item.8; poi.isSaved = false
            poi.tour = tour1
            poi.schedule = schedule2
        }

        // Tour 2: 홍대 맛집 투어
        let tour2 = Tour(context: context)
        tour2.id = UUID()
        tour2.title = "홍대 맛집&카페 투어"
        tour2.startDate = Calendar.current.date(byAdding: .day, value: 3, to: Date())!
        tour2.endDate = Calendar.current.date(byAdding: .day, value: 4, to: Date())!
        tour2.transportMode = "지하철"
        tour2.notes = "홍대 맛집과 카페 방문"
        tour2.createdAt = Date()

        let schedule3 = Schedule(context: context)
        schedule3.id = UUID()
        schedule3.date = tour2.startDate
        schedule3.tour = tour2
        let poisDay3 = [
            ("홍대 감자탕","서울 마포구 홍익로 10",37.5576,126.9236,"맛집","10:00-22:00",4.6,"300명",""),
            ("헬로커피 홍대점","서울 마포구 와우산로 12",37.5544,126.9231,"카페","08:00-23:00",4.4,"210명",""),
            ("연남동 꼼데가르송","서울 마포구 동교로 34",37.5651,126.9238,"카페","09:00-20:00",4.7,"180명","")
        ]
        for item in poisDay3 {
            let poi = POI(context: context)
            poi.id = UUID()
            poi.name = item.0
            poi.address = item.1
            poi.latitude = item.2
            poi.longitude = item.3
            poi.category = item.4
            poi.openingHours = item.5
            poi.rating = item.6
            poi.descriptionText = "⭐️ 평점: \(item.6) (\(item.7))"
            poi.imageURL = item.8
            poi.isSaved = false
            poi.tour = tour2
            poi.schedule = schedule3
        }

        // Tour 3: 강남 쇼핑 투어 (지난 여행)
        let tour3 = Tour(context: context)
        tour3.id = UUID()
        tour3.title = "강남 쇼핑 투어"
        tour3.startDate = Calendar.current.date(byAdding: .day, value: -7, to: Date())!
        tour3.endDate = Calendar.current.date(byAdding: .day, value: -5, to: Date())!
        tour3.transportMode = "버스"
        tour3.notes = "가로수길, 백화점 중심 쇼핑"
        tour3.createdAt = Calendar.current.date(byAdding: .day, value: -10, to: Date())!

        let schedulePast = Schedule(context: context)
        schedulePast.id = UUID()
        schedulePast.date = tour3.startDate
        schedulePast.tour = tour3

        let poisPast = [
            ("신사 가로수길", "서울 강남구 압구정로", 37.5162, 127.0200, "테마거리", "상시 개방", 4.3, "110명", ""),
            ("현대백화점 무역센터점", "서울 강남구 테헤란로 517", 37.5088, 127.0636, "디자이너숍", "10:30-20:00", 4.2, "95명", ""),
            ("코엑스몰", "서울 강남구 영동대로 513", 37.5123, 127.0584, "핫플레이스", "10:00-22:00", 4.5, "130명", "")
        ]

        for item in poisPast {
            let poi = POI(context: context)
            poi.id = UUID()
            poi.name = item.0
            poi.address = item.1
            poi.latitude = item.2
            poi.longitude = item.3
            poi.category = item.4
            poi.openingHours = item.5
            poi.rating = item.6
            poi.descriptionText = "⭐️ 평점: \(item.6) (\(item.7))"
            poi.imageURL = item.8
            poi.isSaved = false
            poi.tour = tour3
            poi.schedule = schedulePast
        }

        // Tour 4: 역사 탐방 투어
        let tour4 = Tour(context: context)
        tour4.id = UUID()
        tour4.title = "역사 탐방 투어"
        tour4.startDate = Calendar.current.date(from: DateComponents(year: 2025, month: 6, day: 2))!
        tour4.endDate = Calendar.current.date(from: DateComponents(year: 2025, month: 6, day: 3))!
        tour4.transportMode = "지하철"
        tour4.notes = "서울의 역사적 명소 탐방"
        tour4.createdAt = Calendar.current.date(from: DateComponents(year: 2025, month: 5, day: 30))!

        let schedule4 = Schedule(context: context)
        schedule4.id = UUID()
        schedule4.date = tour4.startDate
        schedule4.tour = tour4

        let poisDays4 = [
            ("경복궁", "서울 종로구 사직로 161", 37.5796, 126.9770, "고궁", "09:00-18:00", 4.7, "240명", ""),
            ("국립고궁박물관", "서울 종로구 효자로 12", 37.5774, 126.9723, "뮤지엄·미술관", "09:00-18:00", 4.6, "180명", ""),
            ("북촌한옥마을", "서울 종로구 계동길 37", 37.5826, 126.9831, "한옥마을", "상시 개방", 4.4, "210명", "")
        ]

        for item in poisDays4 {
            let poi = POI(context: context)
            poi.id = UUID()
            poi.name = item.0
            poi.address = item.1
            poi.latitude = item.2
            poi.longitude = item.3
            poi.category = item.4
            poi.openingHours = item.5
            poi.rating = item.6
            poi.descriptionText = "⭐️ 평점: \(item.6) (\(item.7))"
            poi.imageURL = item.8
            poi.isSaved = false
            poi.tour = tour1
            poi.schedule = schedule1
        }

        // Tour 5: 한강 피크닉 투어
        let tour5 = Tour(context: context)
        tour5.id = UUID()
        tour5.title = "한강 피크닉 투어"
        tour5.startDate = Calendar.current.date(from: DateComponents(year: 2025, month: 6, day: 10))!
        tour5.endDate = Calendar.current.date(from: DateComponents(year: 2025, month: 6, day: 10))!
        tour5.transportMode = "자전거"
        tour5.notes = "한강변 피크닉 및 라이딩"
        tour5.createdAt = Calendar.current.date(from: DateComponents(year: 2025, month: 6, day: 8))!

        let schedule5 = Schedule(context: context)
        schedule5.id = UUID()
        schedule5.date = tour5.startDate
        schedule5.tour = tour5

        let poisDays5 = [
            ("뚝섬 한강공원", "서울 광진구 자양동", 37.5311, 127.0685, "한강공원", "상시 개방", 4.3, "150명", ""),
            ("자전거 대여소", "서울 성동구 뚝섬로 273", 37.5318, 127.0651, "자전거투어", "09:00-21:00", 4.1, "60명", ""),
            ("서울숲", "서울 성동구 뚝섬로 273", 37.5444, 127.0371, "도심공원", "06:00-22:00", 4.6, "200명", "")
        ]

        for item in poisDays5 {
            let poi = POI(context: context)
            poi.id = UUID()
            poi.name = item.0
            poi.address = item.1
            poi.latitude = item.2
            poi.longitude = item.3
            poi.category = item.4
            poi.openingHours = item.5
            poi.rating = item.6
            poi.descriptionText = "⭐️ 평점: \(item.6) (\(item.7))"
            poi.imageURL = item.8
            poi.isSaved = false
            poi.tour = tour2
            poi.schedule = schedule2
        }

        // Tour 6: 미술관 데이트 투어
        let tour6 = Tour(context: context)
        tour6.id = UUID()
        tour6.title = "미술관 데이트 투어"
        tour6.startDate = Calendar.current.date(from: DateComponents(year: 2025, month: 6, day: 15))!
        tour6.endDate = Calendar.current.date(from: DateComponents(year: 2025, month: 6, day: 15))!
        tour6.transportMode = "도보"
        tour6.notes = "서울 주요 미술관 탐방"
        tour6.createdAt = Calendar.current.date(from: DateComponents(year: 2025, month: 6, day: 12))!

        let schedule6 = Schedule(context: context)
        schedule6.id = UUID()
        schedule6.date = tour6.startDate
        schedule6.tour = tour6

        let poisDays6 = [
            ("서울시립미술관", "서울 중구 덕수궁길 61", 37.5640, 126.9752, "뮤지엄·미술관", "10:00-18:00", 4.4, "130명", ""),
            ("아라리오뮤지엄", "서울 종로구 율곡로 83", 37.5754, 126.9849, "뮤지엄·미술관", "10:00-19:00", 4.5, "100명", ""),
            ("쌈지길", "서울 종로구 인사동길 44", 37.5746, 126.9849, "디자이너숍", "10:30-20:30", 4.2, "90명", "")
        ]

        for item in poisDays6 {
            let poi = POI(context: context)
            poi.id = UUID()
            poi.name = item.0
            poi.address = item.1
            poi.latitude = item.2
            poi.longitude = item.3
            poi.category = item.4
            poi.openingHours = item.5
            poi.rating = item.6
            poi.descriptionText = "⭐️ 평점: \(item.6) (\(item.7))"
            poi.imageURL = item.8
            poi.isSaved = false
            poi.tour = tour3
            poi.schedule = schedule3
        }

        // Tour 7: 남산 야경 투어
        let tour7 = Tour(context: context)
        tour7.id = UUID()
        tour7.title = "남산 야경 투어"
        tour7.startDate = Calendar.current.date(from: DateComponents(year: 2025, month: 6, day: 20))!
        tour7.endDate = Calendar.current.date(from: DateComponents(year: 2025, month: 6, day: 20))!
        tour7.transportMode = "도보"
        tour7.notes = "남산타워와 주변 야경 감상"
        tour7.createdAt = Calendar.current.date(from: DateComponents(year: 2025, month: 6, day: 18))!

        let schedule7 = Schedule(context: context)
        schedule7.id = UUID()
        schedule7.date = tour7.startDate
        schedule7.tour = tour7

        let poisDays7 = [
            ("남산서울타워", "서울 용산구 남산공원길 105", 37.5512, 126.9882, "전망대", "10:00-23:00", 4.6, "300명", ""),
            ("N서울타워 플라자", "서울 용산구 남산공원길 105", 37.5516, 126.9885, "핫플레이스", "10:00-22:00", 4.3, "120명", ""),
            ("남산공원 산책로", "서울 중구 삼일대로 231", 37.5506, 126.9903, "산책로·둘레길", "상시 개방", 4.5, "180명", "")
        ]

        for item in poisDays7 {
            let poi = POI(context: context)
            poi.id = UUID()
            poi.name = item.0
            poi.address = item.1
            poi.latitude = item.2
            poi.longitude = item.3
            poi.category = item.4
            poi.openingHours = item.5
            poi.rating = item.6
            poi.descriptionText = "⭐️ 평점: \(item.6) (\(item.7))"
            poi.imageURL = item.8
            poi.isSaved = false
            poi.tour = tour4
            poi.schedule = schedule4
        }

        // Tour 8: 전통시장 미식 투어
        let tour8 = Tour(context: context)
        tour8.id = UUID()
        tour8.title = "전통시장 미식 투어"
        tour8.startDate = Calendar.current.date(from: DateComponents(year: 2025, month: 6, day: 25))!
        tour8.endDate = Calendar.current.date(from: DateComponents(year: 2025, month: 6, day: 26))!
        tour8.transportMode = "버스"
        tour8.notes = "서울의 전통시장 탐방과 먹거리"
        tour8.createdAt = Calendar.current.date(from: DateComponents(year: 2025, month: 6, day: 22))!

        let schedule8 = Schedule(context: context)
        schedule8.id = UUID()
        schedule8.date = tour8.startDate
        schedule8.tour = tour8

        let poisDays8 = [
            ("광장시장", "서울 종로구 창경궁로 88", 37.5704, 126.9997, "전통시장", "09:00-18:00", 4.3, "170명", ""),
            ("망원시장", "서울 마포구 망원로8길 14", 37.5565, 126.9057, "전통시장", "09:00-21:00", 4.4, "90명", ""),
            ("남대문시장", "서울 중구 남대문시장4길 21", 37.5590, 126.9770, "전통시장", "08:00-19:00", 4.2, "210명", "")
        ]

        for item in poisDays8 {
            let poi = POI(context: context)
            poi.id = UUID()
            poi.name = item.0
            poi.address = item.1
            poi.latitude = item.2
            poi.longitude = item.3
            poi.category = item.4
            poi.openingHours = item.5
            poi.rating = item.6
            poi.descriptionText = "⭐️ 평점: \(item.6) (\(item.7))"
            poi.imageURL = item.8
            poi.isSaved = false
            poi.tour = tour5
            poi.schedule = schedule5
        }

        saveContext()
    }
}
