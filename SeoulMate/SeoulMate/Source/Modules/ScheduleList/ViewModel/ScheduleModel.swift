//
//  ScheduleModel.swift
//  SeoulMate
//
//  Created by 윤혜주 on 6/13/25.
//

import Foundation

/// 서울메이트 앱의 여행 일정 목록을 가져오고 관리하는 뷰 모델입니다.
///
/// - `fetchScheduleList()`: Core Data에서 저장된 여행(`Tour`)을 조회하여 다가오는 여행과 지난 여행으로 구분한 후, `tripItems` 배열에 `TripItem` 형태로 저장합니다.
/// - `formatDateRange(_:_)`: 시작일과 종료일을 "yyyy.M.d" 형식의 문자열 범위로 변환합니다.
/// - `displayTitle(for:)`: 투어의 제목이 비어있을 경우, 첫 번째 POI 이름 또는 기본 제목("서울 여행")을 반환합니다.
/// - `imageURL(for:)`: 투어의 첫 일정에서 이미지 URL이 존재하는 POI의 URL을 반환합니다.
/// - `thumbnailPOI(for:)`: 첫 일정의 첫 POI 객체를 반환합니다.
/// - `locationCountText(for:)`: 투어에 포함된 장소 개수를 문자열로 반환합니다.
/// - `delete(tour:)`: 지정된 투어를 삭제하고 목록을 다시 갱신합니다.
final class ScheduleModel: ObservableObject {
    /// 테이블 뷰에 바인딩할 `TripItem` 배열입니다.
    @Published var tripItems: [TripItem] = []

    /// Core Data에서 저장된 `Tour` 객체를 조회하여
    /// 다가오는 여행과 지난 여행을 구분 후 `tripItems`에 할당합니다.
    func fetchScheduleList() async {
        let allSchedules = await CoreDataManager.shared.fetchToursAsync()

        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        // 종료일이 오늘 이후인 투어
        let upcoming = allSchedules.filter {
            guard let end = $0.endDate else { return false }
            return calendar.startOfDay(for: end) >= today
        }

        // 종료일이 오늘 이전인 투어
        let past = allSchedules.filter {
            guard let end = $0.endDate else { return false }
            return calendar.startOfDay(for: end) < today
        }

        // 섹션 제목과 투어 항목을 조합
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

    /// 두 날짜를 "yyyy.M.d - yyyy.M.d" 형식의 문자열로 반환합니다.
    ///
    /// - Parameters:
    ///   - start: 시작 날짜
    ///   - end: 종료 날짜
    /// - Returns: 포맷된 날짜 범위 문자열
    func formatDateRange(_ start: Date, _ end: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.M.d"
        return "\(formatter.string(from: start)) - \(formatter.string(from: end))"
    }

    /// 투어의 제목이 없을 경우, 첫 번째 POI 이름 또는 기본 제목을 반환합니다.
    ///
    /// - Parameter tour: 제목을 확인할 `Tour` 객체
    /// - Returns: 표시할 제목 문자열
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

    /// 투어의 첫 일정에서 유효한 이미지 URL을 찾아 `URL` 객체로 반환합니다.
    ///
    /// - Parameter tour: 이미지 URL을 확인할 `Tour` 객체
    /// - Returns: 이미지 URL (`URL`), 없으면 `nil`
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


    /// 투어의 첫 일정에서 대표로 사용할 POI 객체를 반환합니다.
    ///
    /// - Parameter tour: `Tour` 객체
    /// - Returns: 첫 POI (`POI`), 없으면 `nil`
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

    /// 투어에 포함된 장소 개수를 "X개의 장소" 형식으로 반환합니다.
    ///
    /// - Parameter tour: `Tour` 객체
    /// - Returns: 장소 개수 문자열
    func locationCountText(for tour: Tour) -> String {
        let count = (tour.pois as? Set<POI>)?.count ?? 0
        return "\(count)개의 장소"
    }

    /// 지정된 투어를 삭제하고, 일정 목록을 다시 조회합니다.
    ///
    /// - Parameter tour: 삭제할 `Tour` 객체
    func delete(tour: Tour) async {
        await CoreDataManager.shared.deleteTourAsync(tour)
        await fetchScheduleList()
    }
}
