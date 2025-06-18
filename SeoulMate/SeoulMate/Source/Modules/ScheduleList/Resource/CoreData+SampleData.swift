//
//  CoreData+SampleData.swift
//  SeoulMate
//
//  Created by 윤혜주 on 6/12/25.
//

import Foundation
import CoreData

extension CoreDataManager {
    /// 미리 정의된 투어 및 일자별 POI 데이터를 Core Data에 시딩(seed)합니다.
      ///
      /// - 동작 순서:
      ///   1. 기존에 저장된 Tour 객체의 제목을 조회하여 중복 여부를 검사합니다.
      ///   2. `tours` 배열에 정의된 각 투어 정보(제목, 시작일, 종료일, 일자별 POI 목록)를 순회합니다.
      ///   3. 중복된 제목이 아니면 새 `Tour` 객체를 생성하고 속성을 설정합니다.
      ///   4. `start` 날짜 기준으로 일자별로 `Schedule` 객체를 생성하고 등록합니다.
      ///   5. 각 `Schedule`에 포함된 `(name, placeID, lat, lng, category, hours)` 튜플을 사용해 `POI` 객체를 생성하여 관계를 설정합니다.
      ///   6. 모든 객체 생성이 완료되면, 변경된 컨텍스트를 저장합니다.
    func seedDummyData() {
        let context = self.context

        // 1) 기존 Tour 제목 조회
        let existingTours = (try? context.fetch(Tour.fetchRequest()) as? [Tour]) ?? []
        let existingTitles = Set(existingTours.compactMap { $0.title })

        // 2) 시딩할 투어 정보 배열
        let tours: [(title: String, start: Date, end: Date,
                     poisByDay: [[(
                        name: String,
                        placeID: String,
                        lat: Double,
                        lng: Double,
                        category: String,
                        hours: String
                     )]])] = [
                        (
                            "서울 숨은 골목 탐방",
                            Calendar.current.date(from: DateComponents(year: 2025, month: 6, day: 1))!,
                            Calendar.current.date(from: DateComponents(year: 2025, month: 7, day: 3))!,
                            [
                                [
                                    ("익선동 한옥골목", "ChIJe4Jbot2ifDUR2zWhruwyaow", 37.5737132, 126.9901271,
                                     "한옥", "상시 개방"),
                                    ("성북동 카페", "ChIJmYX26bi9fDURmZxpVroyeSs", 37.5987526, 126.9996777,
                                     "카페", "09:00-22:00")
                                ],
                                [
                                    ("이화동 벽화마을", "ChIJ63NnRS6jfDURt-efnKIjXzs", 37.5779788, 127.0071915,
                                     "벽화마을", "상시 개방"),
                                    ("망원시장 골목 맛집", "ChIJ8xO_1lOZfDURF9FjPZrJ8D8", 37.555658, 126.905920,
                                     "골목 맛집", "10:00-21:00")
                                ],
                                [
                                    ("서촌 카페", "ChIJu1XATLmifDUR3pP9Y0ULP2s", 37.5828421, 126.9711398,
                                     "카페", "10:00-22:00"),
                                    ("홍제천 산책로", "ChIJ7ePlBmeYfDURRY4-X3iFZGI", 37.5796559,126.9348609,
                                     "산책로", "상시 개방")
                                ]
                            ]
                        ),
                        (
                            "역사 탐방",
                            Calendar.current.date(from: DateComponents(year: 2025, month: 6, day: 10))!,
                            Calendar.current.date(from: DateComponents(year: 2025, month: 6, day: 12))!,
                            [
                                [
                                    ("경복궁", "ChIJod7tSseifDUR9hXHLFNGMIs", 37.579617, 126.977041,
                                     "궁궐", "현재 영업 중 아님"),
                                    ("북촌한옥마을", "hIJYYvi88-ifDURjXxBcyZaEs4", 37.5814696, 126.9849519,
                                     "한옥", "상시 개방")
                                ],
                                [
                                    ("창덕궁", "ChIJ4wh0zluifDURaFBW2pdrKf8", 37.5794309, 126.9910426,
                                     "궁궐", "현재 영업 중")
                                ],
                                [
                                    ("N서울타워", "ChIJqWqOqFeifDURpYJ5LnxX-Fw", 37.5511694, 126.9882266,
                                     "전망대", "10:00-22:00")
                                ]
                            ]
                        ),
                        (
                            "동대문 탐방",
                            Calendar.current.date(from: DateComponents(year: 2025, month: 6, day: 13))!,
                            Calendar.current.date(from: DateComponents(year: 2025, month: 6, day: 15))!,
                            [
                                [
                                    ("동대문시장", "ChIJ8xRYr29FezUR3AtFqx2pIlw", 37.5707806, 127.0081119,
                                     "시장", "10:00-23:00"),
                                    ("DDP", "ChIJ48Kc0iKjfDURZg77ruL0bQM", 37.5665256, 127.0092236,
                                     "문화", "10:00-20:00")
                                ],
                                [
                                    ("을지로입구", "ChIJM7TRRu6ifDURReicbqvGLkg", 37.566065, 126.982679,
                                     "거리", "상시 개방")
                                ],
                                [
                                    ("남산골한옥마을", "ChIJs2hQTOWifDURk8inZqIttEQ", 37.5633851, 126.987436,
                                     "한옥", "09:00-17:00")
                                ]
                            ]
                        ),
                        (
                            "강남 쇼핑 투어",
                            Calendar.current.date(from: DateComponents(year: 2025, month: 6, day: 16))!,
                            Calendar.current.date(from: DateComponents(year: 2025, month: 6, day: 18))!,
                            [
                                [
                                    ("코엑스몰", "ChIJIRVdC6pFezUR02aa2I7i57A", 37.5113686, 127.0595931,
                                     "쇼핑몰", "10:00-22:00"),
                                    ("봉은사", "ChIJgZn6QWmkfDURaU3kwlecaEU", 37.514852, 127.0573766,
                                     "사찰", "09:00-17:00")
                                ],
                                [
                                    ("압구정로데오", "ChIJX4gGfXikfDURPO0YAKh1j40", 37.527394, 127.040572,
                                     "거리", "상시 개방"),
                                    ("가로수길", "ChIJI_IUbOujfDUReyU3t6AyGoM", 37.5210566, 127.0228686,
                                     "거리", "상시 개방")
                                ],
                                [
                                    ("베네청담명품거리점", "ChIJf3M4eXmkfDURC9wf46NMESU", 37.5260965, 127.0451308,
                                     "거리", "상시 개방"),
                                    ("롯데월드몰", "ChIJESJ9VqalfDUR9NRANup1KT8", 37.513618, 127.1038928,
                                     "쇼핑몰", "10:00-22:00")
                                ]
                            ]
                        ),
                        (
                            "홍대 맛집&카페 투어",
                            Calendar.current.date(from: DateComponents(year: 2025, month: 6, day: 19))!,
                            Calendar.current.date(from: DateComponents(year: 2025, month: 6, day: 21))!,
                            [
                                [
                                    ("레드로드 거리 버스킹", "ChIJRRN6RwCZfDURXXIrCbuNyzE", 37.5498377, 126.9209997,
                                     "거리", ""),
                                    ("헬로키티카페 홍대점", "ChIJaV9vtsSYfDURAzWO0I61eZc", 37.553341, 126.9222531,
                                     "카페", "")
                                ],
                                [
                                    ("연남동 꼼데가르송", "ChIJQ5XG5fGifDUROQkSRR7cUvg", 37.5645342, 126.9819093,
                                     "옷가게", "09:00-20:00")
                                ],
                                [
                                    ("망원시장", "ChIJA6gxryiZfDURJvmbeBvdz_Y", 37.5559018, 126.9062854,
                                     "시장", "10:00-20:00"),
                                    ("망원한강공원", "ChIJkfry2i-ZfDURdkxPeBp8x7Q", 37.5527919, 126.8985613,
                                     "공원", "상시 개방")
                                ]
                            ]
                        ),
                        (
                            "한강 산책 투어",
                            Calendar.current.date(from: DateComponents(year: 2025, month: 6, day: 22))!,
                            Calendar.current.date(from: DateComponents(year: 2025, month: 6, day: 24))!,
                            [
                                [
                                    ("뚝섬한강공원", "ChIJJ2rJzH6lfDURExW5AGd7Nok", 37.52935069999999, 127.0699562,
                                     "공원", "상시 개방"),
                                    ("서울숲", "ChIJK_b0UX2jfDURmkYPvmWYm90", 37.5443878, 127.0374424,
                                     "도심공원", "05:00-22:00")
                                ],
                                [
                                    ("한강 잠원지구", "ChIJ7cjjipWjfDURX5dWWWSmm6k", 37.5206865, 127.0122724,
                                     "공원", "상시 개방"),
                                    ("세빛섬", "ChIJX8eLq4GhfDURTUvpy5qGJ04", 37.5116807, 126.9947194,
                                     "복합문화공간", "10:00-23:00")
                                ]
                            ]
                        ),
                        (
                            "미술관 감성 투어",
                            Calendar.current.date(from: DateComponents(year: 2025, month: 6, day: 25))!,
                            Calendar.current.date(from: DateComponents(year: 2025, month: 6, day: 27))!,
                            [
                                [
                                    ("국립현대미술관 서울관", "ChIJRynTqcaifDURBaSFx8HncPs", 37.5788333, 126.9804281,
                                     "미술관", "10:00-18:00"),
                                    ("삼청동길", "ChIJ_ae0p86ifDURYCc5vk2z_5Q", 37.5837936, 126.9819183,
                                     "거리", "상시 개방")
                                ],
                                [
                                    ("디뮤지엄", "ChIJ64M7wqSjfDURYxY0hrd2eqI", 37.5438189, 127.0441812,
                                     "미술관", "10:00-20:00")
                                ]
                            ]
                        ),
                        (
                            "도심 속 역사기행",
                            Calendar.current.date(from: DateComponents(year: 2025, month: 6, day: 28))!,
                            Calendar.current.date(from: DateComponents(year: 2025, month: 6, day: 30))!,
                            [
                                [
                                    ("덕수궁", "ChIJMcWZMY2ifDUR2NLv8F3Togc", 37.5658049, 126.9751461,
                                     "궁궐", "09:00-21:00"),
                                    ("서울시청", "ChIJKwjLMvOifDURqPAMQqxwK-k", 37.5665851, 126.9782038,
                                     "건축", "상시 개방")
                                ],
                                [
                                    ("서소문성지역사박물관", "ChIJcWxy6eWjfDUR5VuxaZqfDQM", 37.5605541, 126.9688295,
                                     "박물관", "09:00-18:00")
                                ]
                            ]
                        ),
                        (
                            "서울 야경 투어",
                            Calendar.current.date(from: DateComponents(year: 2025, month: 7, day: 1))!,
                            Calendar.current.date(from: DateComponents(year: 2025, month: 7, day: 3))!,
                            [
                                [
                                    ("한강대교 야경", "ChIJIzPFp_yhfDURUJf5Uiad6Yc",37.516708,126.9580742,
                                     "야경", "상시 개방"),
                                    ("노들섬", "ChIJeSDcVPuhfDURtpnHjFavX9E", 37.5177627, 126.9596671,
                                     "공원", "10:00-24:00")
                                ],
                                [
                                    ("남산 케이블카", "ChIJP_jRlleifDUR5h_KAraBtAc", 37.5565908, 126.9839744,
                                     "전망", "10:00-22:00")
                                ]
                            ]
                        ),
                        (
                            "서울 힐링 스팟",
                            Calendar.current.date(from: DateComponents(year: 2025, month: 7, day: 10))!,
                            Calendar.current.date(from: DateComponents(year: 2025, month: 8, day: 13))!,
                            [
                                [
                                    ("북서울 꿈의 숲", "ChIJcQ3u64m7fDURRqDmlLjfnRw", 37.6214313, 127.0406246,
                                     "도심공원", "05:00-22:00"),
                                    ("서울식물원", "ChIJ6x48UAGdfDURmnBHA9MWdZQ", 37.5694132, 126.8350252,
                                     "식물원", "09:00-18:00")
                                ],
                                [
                                    ("양재 시민의 숲", "ChIJ88CGHjOhfDURffUdVElFo-U",37.473052,127.038371,
                                     "도심공원", "05:00-22:00"),
                                    ("서울숲공원", "ChIJK_b0UX2jfDURmkYPvmWYm90", 37.5443878, 127.0374424,
                                     "공원", "10:00-19:00")
                                ],
                                [
                                    ("천주교 중림동 약현성당", "ChIJyfyatmOifDURInd2PlDeFR4", 37.5591355, 126.9674611,
                                     "성당", "예약 필요"),
                                    ("청계천 산책로", "ChIJIwCT4-yifDUR1E63iG76hr0", 37.5691015, 126.9786692,
                                     "산책로", "상시 개방")
                                ]
                            ]
                        )
                     ]

        // 3) 투어 정보에 따라 Core Data 객체 생성
        for tourInfo in tours {
            // 중복된 제목은 건너뜁니다
            guard !existingTitles.contains(tourInfo.title) else { continue }

            // Tour 객체 생성 및 속성 설정
            let tour = Tour(context: context)
            tour.id = UUID()
            tour.title = tourInfo.title
            tour.startDate = tourInfo.start
            tour.endDate = tourInfo.end
            tour.createdAt = Date()

            // 4) 일자별 Schedule 생성
            for (dayOffset, dayPois) in tourInfo.poisByDay.enumerated() {
                let date = Calendar.current.date(byAdding: .day, value: dayOffset, to: tourInfo.start)!
                let schedule = Schedule(context: context)
                schedule.id = UUID()
                schedule.date = date
                schedule.tour = tour
                tour.addToDays(schedule)

                // 5) POI 객체 생성 및 관계 설정
                for poiInfo in dayPois {
                    let poi = POI(context: context)
                    poi.name = poiInfo.name
                    poi.latitude = poiInfo.lat
                    poi.longitude = poiInfo.lng
                    poi.category = poiInfo.category
                    poi.openingHours = poiInfo.hours
                    poi.placeID = poiInfo.placeID
                    poi.schedule = schedule
                    poi.tour = tour

                }
            }
        }
        // 6) 컨텍스트 변경 사항 저장
        if context.hasChanges {
            try? context.save()
        }
    }
}
