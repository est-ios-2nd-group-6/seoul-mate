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

                })

                alert.addAction(UIAlertAction(title: "수정", style: .default) { _ in

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
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? MapViewController {
            guard let indexPath = scheduleListTableView.indexPathForSelectedRow else { return }

            let item = tripItems[indexPath.row]
            guard case .trip(let tour) = item else { return }

            // MapView에 tour 필요
            //vc.tour = tour
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        FloatingButtondesign()

        CoreDataManager.shared.seedDummyData()
        fetchScheduleList()
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
            let cell = tableView.dequeueReusableCell(withIdentifier: "TitleCell", for: indexPath)
            as! ScheduleListTitleTableViewCell
            cell.titleLabel.text = title
            return cell

        case .trip(let tour):
            let cell = tableView.dequeueReusableCell(withIdentifier: "TripCell", for: indexPath)
            as! ScheduleListTripTableViewCell

            var displayTitle = tour.title?.trimmingCharacters(in: .whitespacesAndNewlines)
            if displayTitle == nil || displayTitle == "" {
                if let pois = tour.pois as? Set<POI>,
                   let firstPOI = pois.sorted(by: { ($0.name ?? "") < ($1.name ?? "") }).first {
                    displayTitle = firstPOI.name
                }
            }

            cell.tripNameLabel.text = displayTitle ?? "제목 없는 여행"

            let start = tour.startDate ?? Date()
            let end = tour.endDate ?? Date()
            cell.tripDateLabel.text = formatDateRange(start, end)

            if
                let schedules = tour.days as? Set<Schedule>,
                let firstSchedule = schedules.sorted(by: { ($0.date ?? Date()) < ($1.date ?? Date()) }).first,
                let pois = firstSchedule.pois?.array as? [POI],
                let imageURLString = pois.first(where: { $0.imageURL != nil })?.imageURL,
                let imageURL = URL(string: imageURLString)
            {
                cell.tripImageView.load(from: imageURL)
            } else {
                cell.tripImageView.image = UIImage(systemName: "photo")
                cell.tripImageView.tintColor = UIColor(named: "Main")
            }

            cell.cityCountLabel.text = "\(tour.title?.count.description ?? "0") 개의 장소"
            return cell
        }
    }
}

extension UIImageView {
    func load(from url: URL) {
        DispatchQueue.global().async {
            if let data = try? Data(contentsOf: url),
               let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    self.image = image
                }
            }
        }
    }
}
