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
