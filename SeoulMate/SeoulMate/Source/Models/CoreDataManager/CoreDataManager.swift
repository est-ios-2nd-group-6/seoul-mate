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

    // MARK: - Persistent Container
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "SeoulMate")
        guard let description = container.persistentStoreDescriptions.first else {
            fatalError("Persistent store description not found")
        }
        description.shouldMigrateStoreAutomatically = true
        description.shouldInferMappingModelAutomatically = true
        container.loadPersistentStores { storeDescription, error in
            if let error = error {
                fatalError("Unable to load store: \(error.localizedDescription)")
            }
        }
        return container
    }()

    var context: NSManagedObjectContext {
        persistentContainer.viewContext
    }

    // MARK: - Save Context
    func saveContext() {
        guard context.hasChanges else { return }
        do {
            try context.save()
        } catch {
            print("Context 저장 실패: \(error.localizedDescription)")
        }
    }

    func saveContextAsync() async {
        await context.perform {
            if self.context.hasChanges {
                try? self.context.save()
            }
        }
    }

    // MARK: - Tag
    func firstFetchTagsAsync() async {
        await context.perform {
            let request: NSFetchRequest<Tag> = Tag.fetchRequest()
            let count = (try? self.context.count(for: request)) ?? 0
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
                let existing = (try? self.context.count(for: dupCheck)) ?? 0
                guard existing == 0 else { continue }
                let tag = Tag(context: self.context)
                tag.id = UUID()
                tag.name = name
                tag.selected = false
            }
            self.saveContext()
        }
    }

    func fetchTagsAsync(sortedByName: Bool = true) async -> [Tag] {
        await context.perform {
            let request: NSFetchRequest<Tag> = Tag.fetchRequest()
            if sortedByName {
                request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
            }
            return (try? self.context.fetch(request)) ?? []
        }
    }

    func tagSelectToggleAsync (tag: Tag) async{
        await context.perform {
            tag.selected.toggle()
            self.saveContext()
        }
    }

    func fetchSelectedTagsAsync() async -> [Tag] {
        await context.perform {
            let request: NSFetchRequest<Tag> = Tag.fetchRequest()
            request.predicate = NSPredicate(format: "selected == YES")
            return (try? self.context.fetch(request)) ?? []
        }
    }

    // MARK: - Fetch Tours
    func fetchToursAsync() async -> [Tour] {
        await context.perform {
            let request: NSFetchRequest<Tour> = Tour.fetchRequest()
            request.sortDescriptors = [NSSortDescriptor(key: "startDate", ascending: true)]
            return (try? self.context.fetch(request)) ?? []
        }
    }


    func deleteTourAsync(_ tour: Tour) async {
        await context.perform {
            if let schedules = tour.days as? Set<Schedule> {
                for schedule in schedules {
                    schedule.pois = nil
                    self.context.delete(schedule)
                }
            }

            tour.course = nil
            tour.transportMode = nil
            self.context.delete(tour)

            try? self.context.save()
        }
    }


    func fetchSchedules(for tour: Tour) -> [Schedule] {
        let request: NSFetchRequest<Schedule> = Schedule.fetchRequest()
        request.predicate = NSPredicate(format: "tour == %@", tour)
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]
        return (try? context.fetch(request)) ?? []
    }
    // MARK: - POI
    func fetchPOIs(for schedule: Schedule) -> [POI] {
        guard let arr = schedule.pois else { return [] }
        return arr.compactMap { $0 as? POI }
    }

    func togglePOISaved(_ poi: POI) {
        poi.isSaved.toggle()
        saveContext()
    }

    func fetchSavedPOIs() -> [POI] {
        let request: NSFetchRequest<POI> = POI.fetchRequest()
        request.predicate = NSPredicate(format: "isSaved == true")
        return (try? context.fetch(request)) ?? []
    }

    // MARK: - Delete
    func delete(_ object: NSManagedObject) {
        context.delete(object)
        saveContext()
    }

}
