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
        tour1.title = "역사 탐방"
        let calendar1 = Calendar.current
        let start1 = calendar1.date(from: DateComponents(year: 2025, month: 6, day: 10))!
        let end1   = calendar1.date(from: DateComponents(year: 2025, month: 6, day: 12))!
        tour1.startDate = start1
        tour1.endDate   = end1
        tour1.createdAt = Date()

        let poisDay1: [[(name: String, lat: Double, lng: Double, category: String, hours: String, image: String)]] = [
            [ // 6/10
                ("경복궁",      37.5796, 126.9770, "고궁",   "09:00-18:00", ""),
                ("북촌한옥마을", 37.5822, 126.9830, "한옥",   "상시 개방",    "")
            ],
            [ // 6/11
                ("창덕궁",      37.5794, 126.9910, "고궁",   "09:00-18:00", ""),
                ("인사동",      37.5740, 126.9852, "거리",   "상시 개방",    "")
            ],
            [ // 6/12
                ("N서울타워",   37.5512, 126.9882, "전망대", "10:00-22:00", ""),
                ("명동",        37.5611, 126.9861, "거리",   "상시 개방",    "")
            ]
        ]

        for (index, pois) in poisDay1.enumerated() {
            let dayDate = calendar1.date(byAdding: .day, value: index, to: start1)!
            let schedule1 = Schedule(context: context)
            schedule1.id = UUID()
            schedule1.date = dayDate
            schedule1.tour = tour1

            for item in pois {
                let poi = POI(context: context)
                poi.id           = UUID()
                poi.name         = item.name
                poi.latitude     = item.lat
                poi.longitude    = item.lng
                poi.category     = item.category
                poi.openingHours = item.hours
                poi.imageURL     = item.image
                poi.tour         = tour1
                poi.schedule     = schedule1
            }
        }

        // Tour 2: 동대문 탐방
        let tour2 = Tour(context: context)
        tour2.id = UUID()
        tour2.title = "동대문 탐방"
        let calendar2 = Calendar.current
        let start2 = calendar2.date(from: DateComponents(year: 2025, month: 6, day: 13))!
        let end2   = calendar2.date(from: DateComponents(year: 2025, month: 6, day: 15))!
        tour2.startDate = start2
        tour2.endDate   = end2
        tour2.createdAt = Date()

        let poisDay2: [[(name: String, lat: Double, lng: Double, category: String, hours: String, image: String)]] = [
            [ // 6/13
                ("동대문시장",  37.5665, 127.0090, "시장",   "10:00-23:00", ""),
                ("DDP",         37.5662, 127.0090, "문화",   "10:00-20:00", "")
            ],
            [ // 6/14
                ("을지로입구",  37.5660, 126.9912, "거리",   "상시 개방",    ""),
                ("명동성당",    37.5635, 126.9860, "성당",   "09:00-18:00", "")
            ],
            [ // 6/15
                ("남산골한옥마을",37.5499,126.9885, "한옥",   "09:00-17:00", ""),
                ("롯데월드타워", 37.5145, 127.1021, "전망대", "10:00-23:00", "")
            ]
        ]

        for (index, pois) in poisDay2.enumerated() {
            let dayDate = calendar2.date(byAdding: .day, value: index, to: start2)!
            let schedule2 = Schedule(context: context)
            schedule2.id = UUID()
            schedule2.date = dayDate
            schedule2.tour = tour2

            for item in pois {
                let poi = POI(context: context)
                poi.id           = UUID()
                poi.name         = item.name
                poi.latitude     = item.lat
                poi.longitude    = item.lng
                poi.category     = item.category
                poi.openingHours = item.hours
                poi.imageURL     = item.image
                poi.tour         = tour2
                poi.schedule     = schedule2
            }
        }

        // Tour 3: 강남 쇼핑
        let tour3 = Tour(context: context)
        tour3.id = UUID()
        tour3.title = "강남 쇼핑 투어"
        let calendar3 = Calendar.current
        let start3 = calendar3.date(from: DateComponents(year: 2025, month: 6, day: 16))!
        let end3   = calendar3.date(from: DateComponents(year: 2025, month: 6, day: 18))!
        tour3.startDate = start3
        tour3.endDate   = end3
        tour3.createdAt = Date()

        let poisDay3: [[(name: String, lat: Double, lng: Double, category: String, hours: String, image: String)]] = [
            [ // 6/16
                ("코엑스몰",    37.5117, 127.0593, "쇼핑몰", "10:00-22:00", ""),
                ("봉은사",      37.5155, 127.0594, "사찰",   "09:00-17:00", "")
            ],
            [ // 6/17
                ("압구정로데오",37.5255,127.0414, "거리",   "상시 개방",    ""),
                ("가로수길",    37.5178, 127.0208, "거리",   "상시 개방",    "")
            ],
            [ // 6/18
                ("청담동 명품거리",37.5245,127.0490,"거리", "상시 개방",    ""),
                ("잠실 롯데월드몰",37.5110,127.0984, "쇼핑몰", "10:00-22:00", "")
            ]
        ]

        for (index, pois) in poisDay3.enumerated() {
            let dayDate = calendar3.date(byAdding: .day, value: index, to: start3)!
            let schedule3 = Schedule(context: context)
            schedule3.id = UUID()
            schedule3.date = dayDate
            schedule3.tour = tour3

            for item in pois {
                let poi = POI(context: context)
                poi.id           = UUID()
                poi.name         = item.name
                poi.latitude     = item.lat
                poi.longitude    = item.lng
                poi.category     = item.category
                poi.openingHours = item.hours
                poi.imageURL     = item.image
                poi.tour         = tour3
                poi.schedule     = schedule3
            }
        }

        // Tour 4: 홍대 맛집&카페
        let tour4 = Tour(context: context)
        tour4.id = UUID()
        tour4.title = "홍대 맛집&카페 투어"
        let calendar4 = Calendar.current
        let start4 = calendar4.date(from: DateComponents(year: 2025, month: 6, day: 19))!
        let end4   = calendar4.date(from: DateComponents(year: 2025, month: 6, day: 21))!
        tour4.startDate = start4
        tour4.endDate   = end4
        tour4.createdAt = Date()

        let poisDay4: [[(name: String, lat: Double, lng: Double, category: String, hours: String, image: String)]] = [
            [ // 6/19
                ("홍대 감자탕", 37.5576, 126.9236, "맛집", "10:00-22:00", ""),
                ("헬로커피 홍대점",37.5544,126.9231,"카페","08:00-23:00","")
            ],
            [ // 6/20
                ("연남동 꼼데가르송",37.5651,126.9238,"카페","09:00-20:00",""),
                ("상수역 포차거리",37.5475,126.9230,"맛집","17:00-02:00","")
            ],
            [ // 6/21
                ("망원시장",    37.5563, 126.8985, "시장", "10:00-20:00", ""),
                ("망원한강공원",37.5466, 126.8890, "공원", "상시 개방", "")
            ]
        ]

        for (index, pois) in poisDay4.enumerated() {
            let dayDate = calendar4.date(byAdding: .day, value: index, to: start4)!
            let schedule4 = Schedule(context: context)
            schedule4.id = UUID()
            schedule4.date = dayDate
            schedule4.tour = tour4

            for item in pois {
                let poi = POI(context: context)
                poi.id           = UUID()
                poi.name         = item.name
                poi.latitude     = item.lat
                poi.longitude    = item.lng
                poi.category     = item.category
                poi.openingHours = item.hours
                poi.imageURL     = item.image
                poi.tour         = tour4
                poi.schedule     = schedule4
            }
        }

        // Tour 5: 한강 레저
        let tour5 = Tour(context: context)
        tour5.id = UUID()
        tour5.title = "한강 레저 투어"
        let calendar5 = Calendar.current
        let start5 = calendar5.date(from: DateComponents(year: 2025, month: 6, day: 22))!
        let end5   = calendar5.date(from: DateComponents(year: 2025, month: 6, day: 24))!
        tour5.startDate = start5
        tour5.endDate   = end5
        tour5.createdAt = Date()

        let poisDay5: [[(name: String, lat: Double, lng: Double, category: String, hours: String, image: String)]] = [
            [ // 6/22
                ("잠실종합운동장",37.5140,127.0993,"스포츠","상시 개방",""),
                ("석촌호수",      37.5145, 127.1052,"공원","상시 개방","")
            ],
            [ // 6/23
                ("올림픽공원",    37.5160,127.1225,"공원","상시 개방",""),
                ("방이동 먹자골목",37.5098,127.1035,"맛집","10:00-22:00","")
            ],
            [ // 6/24
                ("롯데월드",      37.5110,127.0984,"테마파크","09:00-22:00",""),
                ("서울스카이",    37.5120,127.1010,"전망대","10:00-23:00","")
            ]
        ]

        for (index, pois) in poisDay5.enumerated() {
            let dayDate = calendar5.date(byAdding: .day, value: index, to: start5)!
            let schedule5 = Schedule(context: context)
            schedule5.id = UUID()
            schedule5.date = dayDate
            schedule5.tour = tour5

            for item in pois {
                let poi = POI(context: context)
                poi.id           = UUID()
                poi.name         = item.name
                poi.latitude     = item.lat
                poi.longitude    = item.lng
                poi.category     = item.category
                poi.openingHours = item.hours
                poi.imageURL     = item.image
                poi.tour         = tour5
                poi.schedule     = schedule5
            }
        }


        // Tour 6: 예술 탐방
        let tour6 = Tour(context: context)
        tour6.id = UUID()
        tour6.title = "예술 탐방"
        let calendar6 =  Calendar.current
        let start6 = calendar6.date(from: DateComponents(year: 2025, month: 6, day: 25))!
        let end6   = calendar6.date(from: DateComponents(year: 2025, month: 6, day: 27))!
        tour6.startDate = start6
        tour6.endDate   = end6
        tour6.createdAt = Date()

        let poisDay6: [[(name: String, lat: Double, lng: Double, category: String, hours: String, image: String)]] = [
            [
                ("국립현대미술관 서울관", 37.5230, 127.0083, "미술관", "10:00-18:00", ""),
                ("DDP", 37.5662, 127.0090, "문화시설", "10:00-20:00", "")
            ],
            [
                ("대림미술관", 37.5552, 126.9238, "미술관", "10:00-18:00", ""),
                ("예술의전당", 37.4831, 127.0107, "공연장", "10:00-19:00", "")
            ],
            [
                ("서울시립미술관", 37.5721, 126.9691, "미술관", "10:00-18:00", ""),
                ("세종문화회관", 37.5720, 126.9790, "문화시설", "10:00-20:00", "")
            ]
        ]
        for (index, pois) in poisDay6.enumerated() {
            let date = calendar6.date(byAdding: .day, value: index, to: start6)!
            let schedule6 = Schedule(context: context)
            schedule6.id = UUID()
            schedule6.date = date
            schedule6.tour = tour6
            pois.forEach { item in
                let poi = POI(context: context)
                poi.id = UUID()
                poi.name = item.name
                poi.latitude = item.lat
                poi.longitude = item.lng
                poi.category = item.category
                poi.openingHours = item.hours
                poi.imageURL = item.image
                poi.tour = tour6
                poi.schedule = schedule6
            }
        }

        // Tour 7: 자연 탐방
        let tour7 = Tour(context: context)
        tour7.id = UUID()
        tour7.title = "자연 탐방 투어"
        let calendar7 = Calendar.current
        let start7 = calendar7.date(from: DateComponents(year: 2025, month: 6, day: 28))!
        let end7   = calendar7.date(from: DateComponents(year: 2025, month: 6, day: 30))!
        tour7.startDate = start7
        tour7.endDate   = end7
        tour7.createdAt = Date()

        let poisDay7: [[(name: String, lat: Double, lng: Double, category: String, hours: String, image: String)]] = [
            [ // 6/28
                ("북한산 국립공원", 37.6586, 127.0072, "자연", "상시 개방", ""),
                ("정릉천 둘레길",  37.6081, 127.0344, "자연", "상시 개방", "")
            ],
            [ // 6/29
                ("남산공원",       37.5512, 126.9882, "공원",   "05:00-23:00", ""),
                ("남산서울타워",   37.5515, 126.9880, "전망대", "10:00-23:00", "")
            ],
            [ // 6/30
                ("서울숲",         37.5445, 127.0374, "공원",   "05:00-22:00", ""),
                ("뚝섬 유원지",    37.5405, 127.0716, "공원",   "상시 개방", "")
            ]
        ]

        for (index, pois) in poisDay7.enumerated() {
            let dayDate = calendar7.date(byAdding: .day, value: index, to: start7)!
            let schedule7 = Schedule(context: context)
            schedule7.id = UUID()
            schedule7.date = dayDate
            schedule7.tour = tour7

            for item in pois {
                let poi = POI(context: context)
                poi.id           = UUID()
                poi.name         = item.name
                poi.latitude     = item.lat
                poi.longitude    = item.lng
                poi.category     = item.category
                poi.openingHours = item.hours
                poi.imageURL     = item.image
                poi.tour         = tour7
                poi.schedule     = schedule7
            }
        }

        // Tour 8: 카페 투어
        let tour8 = Tour(context: context)
        tour8.id = UUID()
        tour8.title = "서울 카페 투어"
        let calendar8 = Calendar.current
        let start8 = calendar8.date(from: DateComponents(year: 2025, month: 7, day: 1))!
        let end8   = calendar8.date(from: DateComponents(year: 2025, month: 7, day: 3))!
        tour8.startDate = start8
        tour8.endDate   = end8
        tour8.createdAt = Date()

        let poisDay8: [[(name: String, lat: Double, lng: Double, category: String, hours: String, image: String)]] = [
            [ // 7/1
                ("블루보틀 연남", 37.5660, 126.9234, "카페", "09:00-22:00", ""),
                ("카페 마마스",  37.5495, 126.9410, "카페", "08:00-21:00", "")
            ],
            [ // 7/2
                ("앤트러사이트 합정", 37.5499, 126.9137, "카페", "10:00-23:00", ""),
                ("피어카페",         37.5172, 127.0473, "카페", "09:00-20:00", "")
            ],
            [ // 7/3
                ("팩토리얼스 강남", 37.4997, 127.0276, "카페", "08:00-22:00", ""),
                ("커피리브레",       37.5563, 126.9985, "카페", "10:00-19:00", "")
            ]
        ]

        for (index, pois) in poisDay8.enumerated() {
            let dayDate = calendar8.date(byAdding: .day, value: index, to: start8)!
            let schedule8 = Schedule(context: context)
            schedule8.id = UUID()
            schedule8.date = dayDate
            schedule8.tour = tour8

            for item in pois {
                let poi = POI(context: context)
                poi.id           = UUID()
                poi.name         = item.name
                poi.latitude     = item.lat
                poi.longitude    = item.lng
                poi.category     = item.category
                poi.openingHours = item.hours
                poi.imageURL     = item.image
                poi.tour         = tour8
                poi.schedule     = schedule8
            }
        }

        // Tour 9: 사찰 탐방
        let tour9 = Tour(context: context)
        tour9.id = UUID()
        tour9.title = "서울 사찰 투어"
        let calendar9 = Calendar.current
        let start9 = calendar9.date(from: DateComponents(year: 2025, month: 7, day: 4))!
        let end9   = calendar9.date(from: DateComponents(year: 2025, month: 7, day: 6))!
        tour9.startDate = start9
        tour9.endDate   = end9
        tour9.createdAt = Date()

        let poisDay9: [[(name: String, lat: Double, lng: Double, category: String, hours: String, image: String)]] = [
            [ // 7/4
                ("조계사",       37.5720, 126.9881, "사찰", "05:00-21:00", ""),
                ("봉은사",       37.5101, 127.0588, "사찰", "06:00-20:00", "")
            ],
            [ // 7/5
                ("길상사",       37.5897, 127.0083, "사찰", "09:00-18:00", ""),
                ("석총사",       37.5799, 126.9784, "사찰", "상시 개방", "")
            ],
            [ // 7/6
                ("수국사",       37.5812, 126.9707, "사찰", "06:00-19:00", ""),
                ("화계사",       37.5851, 127.0218, "사찰", "상시 개방", "")
            ]
        ]

        for (index, pois) in poisDay9.enumerated() {
            let dayDate = calendar9.date(byAdding: .day, value: index, to: start9)!
            let schedule9 = Schedule(context: context)
            schedule9.id = UUID()
            schedule9.date = dayDate
            schedule9.tour = tour9

            for item in pois {
                let poi = POI(context: context)
                poi.id           = UUID()
                poi.name         = item.name
                poi.latitude     = item.lat
                poi.longitude    = item.lng
                poi.category     = item.category
                poi.openingHours = item.hours
                poi.imageURL     = item.image
                poi.tour         = tour9
                poi.schedule     = schedule9
            }
        }

        // Tour 10: 야경 투어
        let tour10 = Tour(context: context)
        tour10.id = UUID()
        tour10.title = "서울 야경 투어"
        let calendar10 = Calendar.current
        let start10 = calendar10.date(from: DateComponents(year: 2025, month: 7, day: 7))!
        let end10   = calendar10.date(from: DateComponents(year: 2025, month: 7, day: 9))!
        tour10.startDate = start10
        tour10.endDate   = end10
        tour10.createdAt = Date()

        let poisDay10: [[(name: String, lat: Double, lng: Double, category: String, hours: String, image: String)]] = [
            [ // 7/7
                ("63빌딩 전망대",         37.5212, 126.9395, "전망대", "10:00-23:00", ""),
                ("반포대교 달빛무지개분수", 37.5106, 126.9956, "야경",   "20:00-21:00", "")
            ],
            [ // 7/8
                ("남산서울타워 야경",     37.5515, 126.9880, "전망대", "10:00-23:00", ""),
                ("이태원 경리단길",       37.5342, 126.9944, "거리",   "상시 개방", "")
            ],
            [ // 7/9
                ("한강 야경 크루즈",      37.5170, 127.0154, "크루즈", "19:00-22:00", ""),
                ("청계천 야경 산책로",     37.5683, 126.9778, "산책로", "상시 개방", "")
            ]
        ]

        for (index, pois) in poisDay10.enumerated() {
            let dayDate = calendar10.date(byAdding: .day, value: index, to: start10)!
            let schedule10 = Schedule(context: context)
            schedule10.id = UUID()
            schedule10.date = dayDate
            schedule10.tour = tour10

            for item in pois {
                let poi = POI(context: context)
                poi.id           = UUID()
                poi.name         = item.name
                poi.latitude     = item.lat
                poi.longitude    = item.lng
                poi.category     = item.category
                poi.openingHours = item.hours
                poi.imageURL     = item.image
                poi.tour         = tour10
                poi.schedule     = schedule10
            }
        }

        saveContext()
    }
}
