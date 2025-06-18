//
//  ScheduleModel.swift
//  SeoulMate
//
//  Created by 윤혜주 on 6/13/25.
//

import Foundation

final class ScheduleModel: ObservableObject {
    @Published var tripItems: [TripItem] = []

    func fetchScheduleList() async {
        let allSchedules = await CoreDataManager.shared.fetchToursAsync()

        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        let upcoming = allSchedules.filter {
            guard let end = $0.endDate else { return false }
            return calendar.startOfDay(for: end) >= today
        }

        let past = allSchedules.filter {
            guard let end = $0.endDate else { return false }
            return calendar.startOfDay(for: end) < today
        }

        let trips: [TripItem] = {
            var result: [TripItem] = []
            if !upcoming.isEmpty {
                result.append(.sectionTitle("다가오는 여행"))
                result.append(contentsOf: upcoming.map { .trip($0) })
            }
            if !past.isEmpty {
                result.append(.sectionTitle("지난 여행"))
                result.append(contentsOf: past.map { .trip($0) })
            }
            return result
        }()

        await MainActor.run {
            self.tripItems = trips
        }
    }

    func formatDateRange(_ start: Date, _ end: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.M.d"
        return "\(formatter.string(from: start)) - \(formatter.string(from: end))"
    }

    func displayTitle(for tour: Tour) -> String {
        let trimmed = tour.title?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        if !trimmed.isEmpty {
            return trimmed
        }

        if let pois = tour.pois as? Set<POI>,
           let firstPOI = pois.sorted(by: { ($0.name ?? "") < ($1.name ?? "") }).first {
            return firstPOI.name ?? "서울 여행"
        }

        return "서울 여행"
    }

    func imageURL(for tour: Tour) -> URL? {
        guard
            let schedules = tour.days as? Set<Schedule>,
            let firstSchedule = schedules.sorted(by: { ($0.date ?? Date()) < ($1.date ?? Date()) }).first,
            let pois = firstSchedule.pois?.array as? [POI],
            let imageURLString = pois.first(where: { $0.imageURL != nil })?.imageURL,
            let url = URL(string: imageURLString)
        else {
            return nil
        }
        return url
    }

    func thumbnailPOI(for tour: Tour) -> POI? {
        guard
            let scheduleSet = tour.days as? Set<Schedule>,
            !scheduleSet.isEmpty
        else { return nil }

        let sortedSchedules = scheduleSet.sorted {
            ($0.date ?? .distantPast) < ($1.date ?? .distantPast)
        }

        for schedule in sortedSchedules {
            if let pois = schedule.pois?.array as? [POI], let first = pois.first {
                return first
            }
        }
        return nil
    }
    
    func locationCountText(for tour: Tour) -> String {
        let count = (tour.pois as? Set<POI>)?.count ?? 0
        return "\(count)개의 장소"
    }

    func delete(tour: Tour) async {
        await CoreDataManager.shared.deleteTourAsync(tour)
        await fetchScheduleList()
    }
}
