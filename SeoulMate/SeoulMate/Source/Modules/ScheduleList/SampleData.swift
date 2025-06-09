//
//  SampleData.swift
//  SeoulMate
//
//  Created by 윤혜주 on 6/9/25.
//

import Foundation
import CoreData
func insertUpdatedSampleData(into context: NSManagedObjectContext) {
    // MARK: 1. Tag 생성
    let tagNames = ["자연", "맛집", "역사", "카페", "액티비티"]
    var tags: [Tag] = []
    for name in tagNames {
        let tag = Tag(context: context)
        tag.id = UUID()
        tag.name = name
        tag.selected = Bool.random()
        tags.append(tag)
    }
    print("✅ Tag \(tags.count)개 생성 완료")

    // MARK: 2. POI 생성
    let categories = ["명소", "식당", "카페"]
    var pois: [POI] = []
    for i in 1...30 {
        let poi = POI(context: context)
        poi.id = UUID()
        poi.name = "서울 장소 \(i)"
        poi.category = categories.randomElement()!
        poi.address = "서울시 종로구 세종대로 \(i)길"
        poi.latitude = 37.5 + Double.random(in: -0.02...0.02)
        poi.longitude = 126.98 + Double.random(in: -0.02...0.02)
        poi.openingHours = "10:00 - 20:00"
        poi.descriptionText = "📍 서울의 장소 \(i)번입니다."
        poi.imageURL = "https://example.com/seoul/poi\(i).jpg"
        poi.rating = Double.random(in: 3.5...5.0)
        poi.isSaved = Bool.random()

        for tag in tags.shuffled().prefix(Int.random(in: 1...2)) {
            poi.addToTags(tag)
        }

        pois.append(poi)
        print("🧭 POI 생성: \(poi.name ?? "") [\(poi.category)]")
    }

    // MARK: 3. Course 생성
    var courses: [Course] = []
    for i in 1...5 {
        let course = Course(context: context)
        course.id = UUID()
        course.title = "추천 코스 \(i)"
        course.descriptionText = "서울 명소 중심의 코스 \(i)"
        course.createdAt = Date()
        course.isRecommended = Bool.random()
        course.sharedURL = "https://example.com/course/seoul/\(i)"

        let selectedPOIs = pois.shuffled().prefix(Int.random(in: 3...6))
        for poi in selectedPOIs {
            course.addToPois(poi)
        }

        courses.append(course)
        print("📘 Course 생성: \(course.title ?? "") - 포함 POI: \(selectedPOIs.map { $0.name ?? "-" }.joined(separator: ", "))")
    }

    // MARK: 4. Place 생성
    let placeNames = ["경복궁", "한강공원", "DDP", "광장시장", "북촌", "홍대", "성수", "이태원", "용산", "남산타워"]
    var places: [Place] = []
    for name in placeNames {
        let place = Place(context: context)
        place.id = UUID()
        place.name = name
        place.address = "서울시 \(name)"
        place.latitude = 37.5 + Double.random(in: -0.02...0.02)
        place.longitude = 126.98 + Double.random(in: -0.02...0.02)
        places.append(place)
        print("📍 Place 생성: \(place.name ?? "")")
    }

    // MARK: 5. Tour 생성 (과거/미래 각각 5개)
    for i in 1...10 {
        let tour = Tour(context: context)
        tour.id = UUID()
        tour.startDate = Calendar.current.date(byAdding: .day, value: i <= 5 ? -Int.random(in: 3...10) : Int.random(in: 1...10), to: Date())!
        tour.endDate = Calendar.current.date(byAdding: .day, value: Int.random(in: 2...4), to: tour.startDate ?? Date())!
        tour.transportMode = ["도보", "대중교통", "자차"].randomElement()!
        tour.createdAt = Date()
        tour.notes = "서울의 다채로운 여행 \(i)"
        tour.course = courses.randomElement()

        let selectedPlaces = places.shuffled().prefix(Int.random(in: 2...4))
        for place in selectedPlaces {
            tour.mutableSetValue(forKey: "places").add(place)
        }

        print("🚶 Tour 생성: \(tour.notes ?? "") (\(tour.transportMode ?? "") / \(tour.startDate!.formatted(date: .abbreviated, time: .omitted)) ~ \(tour.endDate!.formatted(date: .abbreviated, time: .omitted)))")

        // Schedule 생성 (날짜별 일정)
        let dayCount = Int.random(in: 1...3)
        for d in 0..<dayCount {
            let schedule = Schedule(context: context)
            schedule.id = UUID()
            schedule.date = Calendar.current.date(byAdding: .day, value: d, to: tour.startDate ?? Date())!
            schedule.tour = tour

            let selectedPOIs = pois.shuffled().prefix(Int.random(in: 2...4))
            for poi in selectedPOIs {
                schedule.addToPois(poi)
            }

            print("   📅 Schedule 생성 - \(schedule.date?.formatted(date: .abbreviated, time: .omitted)) (POI 수: \(selectedPOIs.count))")
        }
    }

    // MARK: 6. 저장
    do {
        try context.save()
        print("✅ 전체 더미 데이터 저장 완료")
    } catch {
        print("❌ 저장 실패: \(error.localizedDescription)")
    }
}
