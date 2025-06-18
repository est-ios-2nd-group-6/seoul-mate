//
//  CoreDataManager.swift
//  SeoulMate
//
//  Created by 윤혜주 on 6/9/25.
//

import CoreData
import UIKit

/// Core Data 스택을 관리하며, 태그, 투어, 일정, POI 등 앱 전반의 데이터 CRUD 기능을 제공하는 싱글톤 클래스입니다.
final class CoreDataManager {
    /// 전역에서 접근 가능한 싱글톤 인스턴스입니다.
    static let shared = CoreDataManager()
    private init() {}

    // MARK: - Persistent Container
    /// NSPersistentContainer로 Core Data 스택을 초기화하고, 마이그레이션 설정을 자동으로 수행합니다.
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

    /// 기본 컨텍스트로 사용되는 NSManagedObjectContext입니다.
    var context: NSManagedObjectContext {
        persistentContainer.viewContext
    }

    // MARK: - Save Context
    /// 변경 사항이 있으면 즉시 저장합니다.
    func saveContext() {
        guard context.hasChanges else { return }
        do {
            try context.save()
        } catch {
            print("Context 저장 실패: \(error.localizedDescription)")
        }
    }

    /// 비동기 컨텍스트 저장을 수행합니다.
    func saveContextAsync() async {
        await context.perform {
            if self.context.hasChanges {
                try? self.context.save()
            }
        }
    }

    // MARK: - Tag
    /// 앱 최초 실행 시 태그 데이터가 없으면 기본 태그를 생성합니다.
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


    /// 태그를 이름 순으로 또는 기본 순서대로 비동기 조회합니다.
    /// - Parameter sortedByName: `true`면 이름 오름차순으로 정렬
    /// - Returns: 조회된 태그 배열
    func fetchTagsAsync(sortedByName: Bool = true) async -> [Tag] {
        await context.perform {
            let request: NSFetchRequest<Tag> = Tag.fetchRequest()
            if sortedByName {
                request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
            }
            return (try? self.context.fetch(request)) ?? []
        }
    }

    /// 특정 태그의 선택 값을 토글하고 저장합니다.
    /// - Parameter tag: 토글할 `Tag` 객체
    func tagSelectToggleAsync (tag: Tag) async{
        await context.perform {
            tag.selected.toggle()
            self.saveContext()
        }
    }

    /// 선택된 태그만 비동기 조회합니다.
    /// - Returns: `selected == true`인 태그 배열
    func fetchSelectedTagsAsync() async -> [Tag] {
        await context.perform {
            let request: NSFetchRequest<Tag> = Tag.fetchRequest()
            request.predicate = NSPredicate(format: "selected == YES")
            return (try? self.context.fetch(request)) ?? []
        }
    }

    // MARK: - Fetch Tours
    /// 모든 `Tour` 객체를 시작일 순으로 비동기 조회합니다.
    /// - Returns: 조회된 `Tour` 배열
    func fetchToursAsync() async -> [Tour] {
        await context.perform {
            let request: NSFetchRequest<Tour> = Tour.fetchRequest()
            request.sortDescriptors = [NSSortDescriptor(key: "startDate", ascending: true)]
            return (try? self.context.fetch(request)) ?? []
        }
    }

    /// 특정 투어와 연관된 모든 일정(`Schedule`)을 삭제 후 해당 투어를 삭제합니다.
    /// - Parameter tour: 삭제할 `Tour` 객체
    func deleteTourAsync(_ tour: Tour) async {
        await context.perform {
            if let schedules = tour.days as? Set<Schedule> {
                for schedule in schedules {
                    schedule.pois = nil
                    self.context.delete(schedule)
                }
            }

            self.context.delete(tour)
            try? self.context.save()
        }
    }

    /// 특정 투어의 일정 목록을 날짜 순으로 동기 조회합니다.
    /// - Parameter tour: 조회할 `Tour` 객체
    /// - Returns: `Schedule` 배열
    func fetchSchedules(for tour: Tour) -> [Schedule] {
        let request: NSFetchRequest<Schedule> = Schedule.fetchRequest()
        request.predicate = NSPredicate(format: "tour == %@", tour)
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]
        return (try? context.fetch(request)) ?? []
    }

    // MARK: - POI
    /// 특정 일정의 POI 배열을 동기 조회합니다.
    /// - Parameter schedule: 조회할 `Schedule` 객체
    /// - Returns: `POI` 배열
    func fetchPOIs(for schedule: Schedule) -> [POI] {
        guard let arr = schedule.pois else { return [] }
        return arr.compactMap { $0 as? POI }
    }

    /// 저장된(즐겨찾기) POI만 동기 조회합니다.
    /// - Returns: `isSaved == true`인 POI 배열
    func fetchSavedPOIs() -> [POI] {
        let request: NSFetchRequest<POI> = POI.fetchRequest()
        request.predicate = NSPredicate(format: "isSaved == true")
        return (try? context.fetch(request)) ?? []
    }

    // MARK: - Delete
    /// 특정 NSManagedObject를 삭제하고 컨텍스트를 저장합니다.
    /// - Parameter object: 삭제할 `NSManagedObject`
    func delete(_ object: NSManagedObject) {
        context.delete(object)
        saveContext()
    }

}
