//
//  CoreData+SampleData.swift
//  SeoulMate
//
//  Created by 윤혜주 on 6/12/25.
//

import Foundation
import CoreData

extension CoreDataManager {
    func seedDummyData() async {
        guard await fetchToursAsync().isEmpty else { return }

        // Tour 1: 역사 탐방
        let tour1 = Tour(context: context)
        tour1.id = UUID()
        tour1.title = "서울 역사 탐방"
        tour1.startDate = Date()
        tour1.endDate = Calendar.current.date(byAdding: .day, value: 2, to: tour1.startDate!)!
        tour1.createdAt = Date()

        let schedule1 = Schedule(context: context)
        schedule1.id = UUID()
        schedule1.date = tour1.startDate
        schedule1.tour = tour1

        let poisDay1 = [
            ("경복궁", 37.5796, 126.9770, "고궁", "09:00-18:00", ""),
            ("북촌한옥마을", 37.5822, 126.9830, "한옥마을", "상시 개방", ""),
            ("창덕궁", 37.5794, 126.9910, "고궁", "09:00-18:00", "")
        ]
        
        for item in poisDay1 {
            let poi = POI(context: context)
            poi.id = UUID()
            poi.name = item.0; poi.latitude = item.1; poi.longitude = item.2
            poi.category = item.3; poi.openingHours = item.4; poi.imageURL = item.5
            poi.tour = tour1; poi.schedule = schedule1
        }

        // Tour 2: 홍대 맛집 & 카페 투어
        let tour2 = Tour(context: context)
        tour2.id = UUID()
        tour2.title = "홍대 맛집&카페 투어"
        tour2.startDate = Calendar.current.date(byAdding: .day, value: 3, to: Date())!
        tour2.endDate = Calendar.current.date(byAdding: .day, value: 4, to: Date())!
        tour2.createdAt = Date()

        let schedule2 = Schedule(context: context)
        schedule2.id = UUID()
        schedule2.date = tour2.startDate
        schedule2.tour = tour2
        let poisDay2 = [
            ("홍대 감자탕", 37.5576, 126.9236, "맛집", "10:00-22:00", ""),
            ("헬로커피 홍대점", 37.5544, 126.9231, "카페", "08:00-23:00", ""),
            ("연남동 꼼데가르송", 37.5651, 126.9238, "카페", "09:00-20:00", "")
        ]
        for item in poisDay2 {
            let poi = POI(context: context)
            poi.id = UUID()
            poi.name = item.0; poi.latitude = item.1; poi.longitude = item.2
            poi.category = item.3; poi.openingHours = item.4; poi.imageURL = item.5
            poi.tour = tour2; poi.schedule = schedule2
        }

        // Tour 3: 강남 쇼핑 투어 (지난 여행)
        let tour3 = Tour(context: context)
        tour3.id = UUID()
        tour3.title = "강남 쇼핑 투어"
        tour3.startDate = Calendar.current.date(byAdding: .day, value: -7, to: Date())!
        tour3.endDate = Calendar.current.date(byAdding: .day, value: -5, to: Date())!
        tour3.createdAt = Calendar.current.date(byAdding: .day, value: -10, to: Date())!
        let schedule3 = Schedule(context: context)
        schedule3.id = UUID()
        schedule3.date = tour3.startDate
        schedule3.tour = tour3
        let poisDay3 = [
            ("신사 가로수길", 37.5162, 127.0200, "테마거리", "상시 개방", ""),
            ("현대백화점 무역센터점", 37.5088, 127.0636, "디자이너숍", "10:30-20:00", ""),
            ("코엑스몰", 37.5123, 127.0584, "핫플레이스", "10:00-22:00", "")
        ]
        for item in poisDay3 {
            let poi = POI(context: context)
            poi.id = UUID()
            poi.name = item.0; poi.latitude = item.1; poi.longitude = item.2
            poi.category = item.3; poi.openingHours = item.4; poi.imageURL = item.5
            poi.tour = tour3; poi.schedule = schedule3
        }

        // Tour 4: 역사 탐방 투어
        let tour4 = Tour(context: context)
        tour4.id = UUID()
        tour4.title = "역사 탐방 투어"
        tour4.startDate = Calendar.current.date(from: DateComponents(year: 2025, month: 6, day: 2))!
        tour4.endDate = Calendar.current.date(from: DateComponents(year: 2025, month: 6, day: 3))!
        tour4.createdAt = Calendar.current.date(from: DateComponents(year: 2025, month: 5, day: 30))!
        let schedule4 = Schedule(context: context)
        schedule4.id = UUID()
        schedule4.date = tour4.startDate
        schedule4.tour = tour4
        let poisDay4 = [
            ("경복궁", 37.5796, 126.9770, "고궁", "09:00-18:00", ""),
            ("국립고궁박물관", 37.5774, 126.9723, "뮤지엄·미술관", "09:00-18:00", ""),
            ("북촌한옥마을", 37.5826, 126.9831, "한옥마을", "상시 개방", "")
        ]
        for item in poisDay4 {
            let poi = POI(context: context)
            poi.id = UUID()
            poi.name = item.0; poi.latitude = item.1; poi.longitude = item.2
            poi.category = item.3; poi.openingHours = item.4; poi.imageURL = item.5
            poi.tour = tour4; poi.schedule = schedule4
        }

        // Tour 5: 한강 피크닉 투어
        let tour5 = Tour(context: context)
        tour5.id = UUID()
        tour5.title = "한강 피크닉 투어"
        tour5.startDate = Calendar.current.date(from: DateComponents(year: 2025, month: 6, day: 10))!
        tour5.endDate = tour5.startDate
        tour5.createdAt = Calendar.current.date(from: DateComponents(year: 2025, month: 6, day: 8))!
        let schedule5 = Schedule(context: context)
        schedule5.id = UUID()
        schedule5.date = tour5.startDate
        schedule5.tour = tour5
        let poisDay5 = [
            ("뚝섬 한강공원", 37.5311, 127.0685, "한강공원", "상시 개방", ""),
            ("자전거 대여소", 37.5318, 127.0651, "자전거투어", "09:00-21:00", ""),
            ("서울숲", 37.5444, 127.0371, "도심공원", "06:00-22:00", "")
        ]
        for item in poisDay5 {
            let poi = POI(context: context)
            poi.id = UUID()
            poi.name = item.0; poi.latitude = item.1; poi.longitude = item.2
            poi.category = item.3; poi.openingHours = item.4; poi.imageURL = item.5
            poi.tour = tour5; poi.schedule = schedule5
        }

        // Tour 6: 미술관 데이트 투어
        let tour6 = Tour(context: context)
        tour6.id = UUID()
        tour6.title = "미술관 데이트 투어"
        tour6.startDate = Calendar.current.date(from: DateComponents(year: 2025, month: 6, day: 15))!
        tour6.endDate = tour6.startDate
        tour6.createdAt = Calendar.current.date(from: DateComponents(year: 2025, month: 6, day: 12))!
        let schedule6 = Schedule(context: context)
        schedule6.id = UUID()
        schedule6.date = tour6.startDate
        schedule6.tour = tour6
        let poisDay6 = [
            ("서울시립미술관", 37.5640, 126.9752, "뮤지엄·미술관", "10:00-18:00", ""),
            ("아라리오뮤지엄", 37.5754, 126.9849, "뮤지엄·미술관", "10:00-19:00", ""),
            ("쌈지길", 37.5746, 126.9849, "디자이너숍", "10:30-20:30", "")
        ]
        for item in poisDay6 {
            let poi = POI(context: context)
            poi.id = UUID()
            poi.name = item.0; poi.latitude = item.1; poi.longitude = item.2
            poi.category = item.3;poi.openingHours = item.4; poi.imageURL = item.5
            poi.tour = tour6; poi.schedule = schedule6
        }

        // Tour 7: 남산 야경 투어
        let tour7 = Tour(context: context)
        tour7.id = UUID()
        tour7.title = "남산 야경 투어"
        tour7.startDate = Calendar.current.date(from: DateComponents(year: 2025, month: 6, day: 20))!
        tour7.endDate = tour7.startDate
        tour7.createdAt = Calendar.current.date(from: DateComponents(year: 2025, month: 6, day: 18))!
        let schedule7 = Schedule(context: context)
        schedule7.id = UUID()
        schedule7.date = tour7.startDate
        schedule7.tour = tour7
        let poisDay7 = [
            ("남산서울타워", 37.5512, 126.9882, "전망대", "10:00-23:00", ""),
            ("N서울타워 플라자", 37.5516, 126.9885, "핫플레이스", "10:00-22:00", ""),
            ("남산공원 산책로", 37.5506, 126.9903, "산책로·둘레길", "상시 개방", "")
        ]
        for item in poisDay7 {
            let poi = POI(context: context)
            poi.id = UUID(); poi.name = item.0; poi.latitude = item.1; poi.longitude = item.2
            poi.category = item.3; poi.openingHours = item.4; poi.imageURL = item.5
            poi.tour = tour7; poi.schedule = schedule7
        }

        // Tour 8: 전통시장 미식 투어
        let tour8 = Tour(context: context)
        tour8.id = UUID()
        tour8.title = "전통시장 미식 투어"
        tour8.startDate = Calendar.current.date(from: DateComponents(year: 2025, month: 6, day: 25))!
        tour8.endDate = Calendar.current.date(from: DateComponents(year: 2025, month: 6, day: 26))!
        tour8.createdAt = Calendar.current.date(from: DateComponents(year: 2025, month: 6, day: 22))!
        let schedule8 = Schedule(context: context)
        schedule8.id = UUID(); schedule8.date = tour8.startDate; schedule8.tour = tour8
        let poisDay8 = [
            ("광장시장", 37.5704, 126.9997, "전통시장", "09:00-18:00", ""),
            ("망원시장", 37.5565, 126.9057, "전통시장", "09:00-21:00", ""),
            ("남대문시장", 37.5590, 126.9770, "전통시장", "08:00-19:00", "")
        ]
        for item in poisDay8 {
            let poi = POI(context: context)
            poi.id = UUID(); poi.name = item.0; poi.latitude = item.1; poi.longitude = item.2
            poi.category = item.3; poi.openingHours = item.4; poi.imageURL = item.5
            poi.tour = tour8; poi.schedule = schedule8
        }

        // Tour 9: 서울 랜드마크 투어
        let tour9 = Tour(context: context)
        tour9.id = UUID()
        tour9.title = "서울 랜드마크 투어"
        tour9.startDate = Calendar.current.date(from: DateComponents(year: 2025, month: 7, day: 1))!
        tour9.endDate = Calendar.current.date(from: DateComponents(year: 2025, month: 7, day: 2))!
        tour9.createdAt = Calendar.current.date(from: DateComponents(year: 2025, month: 6, day: 28))!
        let schedule9 = Schedule(context: context)
        schedule9.id = UUID(); schedule9.date = tour9.startDate; schedule9.tour = tour9
        let poisDay9 = [
            ("63빌딩", 37.5194, 126.9406, "전망대", "10:00-22:00", ""),
            ("롯데월드타워", 37.5145, 127.1021, "전망대", "10:00-23:00", ""),
            ("한옥마을", 37.5826, 126.9831, "한옥마을", "상시 개방", "")
        ]
        for item in poisDay9 {
            let poi = POI(context: context)
            poi.id = UUID(); poi.name = item.0; poi.latitude = item.1; poi.longitude = item.2
            poi.category = item.3; poi.openingHours = item.4; poi.imageURL = item.5
            poi.tour = tour9; poi.schedule = schedule9
        }

        // Tour 10: 강북 문화 투어
        let tour10 = Tour(context: context)
        tour10.id = UUID()
        tour10.title = "강북 문화 투어"
        tour10.startDate = Calendar.current.date(from: DateComponents(year: 2025, month: 7, day: 5))!
        tour10.endDate = Calendar.current.date(from: DateComponents(year: 2025, month: 7, day: 6))!
        tour10.createdAt = Calendar.current.date(from: DateComponents(year: 2025, month: 7, day: 1))!
        let schedule10 = Schedule(context: context)
        schedule10.id = UUID(); schedule10.date = tour10.startDate; schedule10.tour = tour10
        let poisDay10 = [
            ("삼청동 골목", 37.5843, 126.9849, "거리", "상시 개방", ""),
            ("조계사", 37.5740, 126.9855, "사찰", "상시 개방", ""),
            ("인사동 쌈지길", 37.5746, 126.9849, "디자인숍", "10:00-20:00", "")
        ]
        for item in poisDay10 {
            let poi = POI(context: context)
            poi.id = UUID(); poi.name = item.0; poi.latitude = item.1; poi.longitude = item.2
            poi.category = item.3; poi.openingHours = item.4; poi.imageURL = item.5
            poi.tour = tour10; poi.schedule = schedule10
        }

        // Tour 11: 한강 야경 투어
        let tour11 = Tour(context: context)
        tour11.id = UUID()
        tour11.title = "한강 야경 투어"
        tour11.startDate = Calendar.current.date(from: DateComponents(year: 2025, month: 7, day: 10))!
        tour11.endDate = tour11.startDate
        tour11.createdAt = Calendar.current.date(from: DateComponents(year: 2025, month: 7, day: 5))!
        let schedule11 = Schedule(context: context)
        schedule11.id = UUID(); schedule11.date = tour11.startDate; schedule11.tour = tour11
        let poisDay11 = [
            ("반포대교 분수", 37.5215, 127.0075, "야경", "19:00-23:00", ""),
            ("여의도 한강공원", 37.5338, 126.9249, "강변공원", "상시 개방", ""),
            ("선유도공원", 37.5170, 126.8962, "공원", "상시 개방", "")
        ]
        for item in poisDay11 {
            let poi = POI(context: context)
            poi.id = UUID(); poi.name = item.0; poi.latitude = item.1; poi.longitude = item.2
            poi.category = item.3; poi.openingHours = item.4; poi.imageURL = item.5
            poi.tour = tour11; poi.schedule = schedule11
        }
        saveContext()
    }
}
