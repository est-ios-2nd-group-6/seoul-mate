//
//  ScheduleListViewController.swift
//  SeoulMate
//
//  Created by 윤혜주 on 6/8/25.
//

import UIKit

enum TripItem {
    case sectionTitle(String)
    case trip(Tour)
}

class ScheduleListViewController: UIViewController {
    var tripItems: [TripItem] = []

    @IBOutlet weak var scheduleListTableView: UITableView!
    @IBOutlet weak var floatingButton: UIButton!

    func fetchScheduleList() {
        let allSchedules: [Tour] = CoreDataManager.shared.fetchTours()
        let today = Date()

        let upcoming = allSchedules.filter{ $0.endDate ?? Date() >= today }
        let past = allSchedules.filter{ $0.endDate! < today }

        var trips: [TripItem] = []
        if !upcoming.isEmpty {
            trips.append(.sectionTitle("다가오는 여행"))
            trips.append(contentsOf: upcoming.map{ .trip($0) })
        }
        if !past.isEmpty {
            trips.append(.sectionTitle("지난 여행"))
            trips.append(contentsOf: past.map{ .trip($0) })
        }

        self.tripItems = trips
        self.scheduleListTableView.reloadData()
    }

    func formatDateRange(_ start: Date, _ end: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.M.d"
        return "\(formatter.string(from: start)) - \(formatter.string(from: end))"
    }

    @IBAction func floatingButton(_ sender: Any) {
        // 새 여행 일정 추가
    }

    @IBAction func moreButton(_ sender: Any) {
        guard let button = sender as? UIButton else { return }

        var view = button.superview
        while let current = view {
            if let cell = current as? ScheduleListTripTableViewCell,
               let indexPath = scheduleListTableView.indexPath(for: cell) {

                let item = tripItems[indexPath.row]
                guard case .trip(let tour) = item else { return }

                let alert = UIAlertController(title: "여행 옵션", message: nil, preferredStyle: .actionSheet)

                alert.addAction(UIAlertAction(title: "일정 보기", style: .default) { _ in
//                    let vc = ScheduleDetailViewController()
//                    vc.tour = tour
//                    self.navigationController?.pushViewController(vc, animated: true)
                })

                alert.addAction(UIAlertAction(title: "수정", style: .default) { _ in
                    //                    let vc = ScheduleEditViewController()
                    //                    vc.tourToEdit = tour
                    //                    self.navigationController?.pushViewController(editVC, animated: true)
                })

                alert.addAction(UIAlertAction(title: "삭제", style: .destructive) { _ in
                    CoreDataManager.shared.deleteTour(tour)
                    self.fetchScheduleList()
                })

                alert.addAction(UIAlertAction(title: "취소", style: .cancel))

                if let popoverController = alert.popoverPresentationController {
                    popoverController.sourceView = button
                    popoverController.sourceRect = button.bounds
                }

                self.present(alert, animated: true)
                return
            }
            view = current.superview
        }
    }

    private func FloatingButtondesign() {
        floatingButton.setImage(UIImage(systemName: "plus"), for: .normal)
        floatingButton.tintColor = .main
        floatingButton.layer.cornerRadius = floatingButton.frame.height / 2
        floatingButton.clipsToBounds = true
    }

//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if segue.identifier == "ScheduleDetail",
//           let cell = sender as? UITableViewCell,
//           let indexPath = scheduleListTableView.indexPath(for: cell),
//           let destination = segue.destination as? ScheduleDetailViewController {
//
//            let selectedItem = tripItems[indexPath.row]
//
//            switch selectedItem {
//            case .trip(let tour):
//                destination.tour = tour
//            default:
//                break
//            }
//        }
//    }
    override func viewDidLoad() {
        super.viewDidLoad()
        FloatingButtondesign()

        let manager = CoreDataManager.shared
        let existing = manager.fetchTours()

        if existing.isEmpty {
            insertUpdatedSampleData(into: manager.context)
            print("샘플 데이터 삽입됨")
        } else {
            print("이미 Tour 데이터 \(existing.count)개 존재")
        }

        fetchScheduleList()

        //        guard Bundle.main.NAVER_API_KEY != nil else {
        //            print("API 키를 로드하지 못했습니다")
        //            return
        //        }
        //
        //        guard Bundle.main.GoolgePlace_API_KEY != nil else {
        //            print("API 키를 로드하지 못했습니다")
        //            return
        //        }
    }
}
extension ScheduleListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        return tripItems.count
    }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = tripItems[indexPath.row]

        switch item {
        case .sectionTitle(let title):
            let cell = tableView
                .dequeueReusableCell(withIdentifier: "TitleCell", for: indexPath)
            as! ScheduleListTitleTableViewCell
            cell.titleLabel.text = title
            return cell

        case .trip(let tour):
            let cell = tableView
                .dequeueReusableCell(withIdentifier: "TripCell", for: indexPath)
            as! ScheduleListTripTableViewCell

            var displayTitle = tour.title?.trimmingCharacters(in: .whitespacesAndNewlines)

            if displayTitle == nil || displayTitle == "" {
                if let placesSet = tour.places as? Set<Place>, !placesSet.isEmpty {
                    let sortedPlaces = placesSet.sorted { ($0.name ?? "") < ($1.name ?? "") }

                    if let firstPlace = sortedPlaces.first, let placeName = firstPlace.name {
                        displayTitle = placeName
                    }
                }
            }

            cell.tripNameLabel.text = displayTitle ?? "제목 없는 여행"
            let start = tour.startDate ?? Date()
            let end   = tour.endDate   ?? Date()
            cell.tripDateLabel.text = formatDateRange(start, end)

            cell.tripImageView.image = UIImage(systemName: "map")
            return cell
        }
    }
}
