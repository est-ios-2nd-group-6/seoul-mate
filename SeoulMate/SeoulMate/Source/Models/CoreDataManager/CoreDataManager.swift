//
//  CoreDataManager.swift
//  SeoulMate
//
//  Created by 윤혜주 on 6/9/25.
//

import CoreData
import UIKit

final class CoreDataManager {
    static let shared = CoreDataManager()
    private init() {}

    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "SeoulMate")
        container.persistentStoreDescriptions.first?.shouldMigrateStoreAutomatically = true
        container.persistentStoreDescriptions.first?.shouldInferMappingModelAutomatically = true

        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Core Data load error: \(error)")
            }
        }
        return container
    }()

    var context: NSManagedObjectContext {
        persistentContainer.viewContext
    }
    
    func firstFetchTag() {
        let request: NSFetchRequest<Tag> = Tag.fetchRequest()
        let count = (try? context.count(for: request)) ?? 0
        guard count == 0 else { return }

        let tagNames = [
            "역사", "고궁", "한옥마을", "전통시장",
            "맛집", "카페투어", "스트리트푸드", "브런치 스팟",
            "뮤지엄·미술관", "공연·페스티벌", "인디·라이브", "스트리트아트",
            "핫플레이스", "플리마켓", "디자이너숍", "테마거리",
            "한강공원", "도심공원", "산책로·둘레길", "자전거투어",
            "야경 명소", "루프탑바", "전망대"
        ]

        for name in tagNames {
            let dupCheck: NSFetchRequest<Tag> = Tag.fetchRequest()
            dupCheck.predicate = NSPredicate(format: "name == %@", name)
            let existing = (try? context.count(for: dupCheck)) ?? 0
            guard existing == 0 else { continue }
            let tag = Tag(context: context)
            tag.id = UUID()
            tag.name = name
            tag.selected = false
        }

        saveContext()
    }

    func fetchTags(sortedByName: Bool = true) -> [Tag] {
        let request: NSFetchRequest<Tag> = Tag.fetchRequest()
        if sortedByName {
            request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        }
        do {
            return try context.fetch(request)
        } catch {
            print("Tag fetch 실패: \(error.localizedDescription)")
            return []
        }
    }

    func toggle(tag: Tag) {
        tag.selected.toggle()
        saveContext()
    }

    func fetchSelectedTags() -> [Tag] {
        let request: NSFetchRequest<Tag> = Tag.fetchRequest()
        request.predicate = NSPredicate(format: "selected == YES")
        do {
            return try context.fetch(request)
        } catch {
            print("Selected Tag fetch 실패: \(error.localizedDescription)")
            return []
        }
    }
    func fetchTours() -> [Tour] {
        let request: NSFetchRequest<Tour> = Tour.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "startDate", ascending: true)]

        do {
            return try context.fetch(request)
        } catch {
            print("Failed to fetch tours: \(error.localizedDescription)")
            return []
        }
    }

    func savePlace(from dto: PlaceTextSearchDTO, context: NSManagedObjectContext) {
        let place = Place(context: context)
        place.id = UUID()
        place.name = dto.name
        place.address = dto.formattedAddress
        place.latitude = dto.location.latitude
        place.longitude = dto.location.longitude

        do {
            try context.save()
            print("장소 저장 완료: \(place.name ?? "-")")
        } catch {
            print("저장 실패: \(error.localizedDescription)")
        }
    }

    func savePOI(from dto: PlaceTextSearchDTO, category: String, context: NSManagedObjectContext) {
        let poi = POI(context: context)
        poi.id = UUID()
        poi.name = dto.name
        poi.category = category
        poi.address = dto.formattedAddress
        poi.latitude = dto.location.latitude
        poi.longitude = dto.location.longitude
        poi.openingHours = dto.regularOpeningHours.weekdayDescriptions.joined(separator: "\n")
        poi.descriptionText = "⭐️ 평점: \(dto.rating) (\(dto.userRatingCount)명)"
        poi.imageURL = dto.photos.first?.googleMapsURI
        poi.rating = Double(dto.rating)
        poi.isSaved = false

        let fetchRequest: NSFetchRequest<Tag> = Tag.fetchRequest()
        if let tags = try? context.fetch(fetchRequest).shuffled().prefix(1) {
            for tag in tags {
                poi.addToTags(tag)
            }
        }

        do {
            try context.save()
            print("POI 저장 완료: \(poi.name ?? "-")")
        } catch {
            print("POI 저장 실패: \(error.localizedDescription)")
        }
    }

    func saveContext() {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print("저장 실패: \(error.localizedDescription)")
            }
        }
    }

    func delete(_ object: NSManagedObject) {
        context.delete(object)
        saveContext()
    }

    func deleteTour(_ tour: Tour) {
        if let schedules = tour.days as? Set<Schedule> {
            for schedule in schedules {
                // 관계 수동 제거
                schedule.pois = nil
                context.delete(schedule)
            }
        }

        tour.course = nil
        tour.transportMode = nil

        context.delete(tour)
        saveContext()
    }
}
