//
//  ScheduleListViewController.swift
//  SeoulMate
//
//  Created by 윤혜주 on 6/8/25.
//

import UIKit

class ScheduleListViewController: UIViewController {
    var tripItems: [TripItem] = []

    @IBOutlet weak var scheduleListTableView: UITableView!
    @IBOutlet weak var floatingButton: UIButton!

    private let viewModel = ScheduleModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        FloatingButtondesign()

        Task {
            await CoreDataManager.shared.seedDummyData()
            await viewModel.fetchScheduleList()
            await MainActor.run {
                self.scheduleListTableView.reloadData()
            }
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? MapViewController {
            guard let indexPath = scheduleListTableView.indexPathForSelectedRow else { return }

            let item = viewModel.tripItems[indexPath.row]
            guard case .trip(let tour) = item else { return }

            // MapView에 tour 필요
            //vc.tour = tour
        }
    }

    private func FloatingButtondesign() {
        floatingButton.setImage(UIImage(systemName: "plus"), for: .normal)
        floatingButton.tintColor = .main
        floatingButton.layer.cornerRadius = floatingButton.frame.height / 2
        floatingButton.clipsToBounds = true
    }

    @IBAction func moreButton(_ sender: Any) {
        guard let button = sender as? UIButton else { return }

        var view = button.superview
        while let current = view {
            if let cell = current as? ScheduleListTripTableViewCell,
               let indexPath = scheduleListTableView.indexPath(for: cell) {

                let item = viewModel.tripItems[indexPath.row]
                guard case .trip(let tour) = item else { return }

                let alert = UIAlertController(title: "옵션", message: nil, preferredStyle: .actionSheet)

                alert.addAction(UIAlertAction(title: "삭제", style: .destructive) { _ in
                    Task {
                        await self.viewModel.delete(tour: tour)
                        await MainActor.run {
                            self.scheduleListTableView.reloadData()
                        }
                    }
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
}
extension ScheduleListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        return viewModel.tripItems.count
    }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = viewModel.tripItems[indexPath.row]

        switch item {
        case .sectionTitle(let title):
            let cell = tableView.dequeueReusableCell(withIdentifier: "TitleCell", for: indexPath)
            as! ScheduleListTitleTableViewCell
            cell.titleLabel.text = title
            return cell

        case .trip(let tour):
            let cell = tableView.dequeueReusableCell(withIdentifier: "TripCell", for: indexPath)
            as! ScheduleListTripTableViewCell

            cell.tripNameLabel.text = viewModel.displayTitle(for: tour)
            cell.tripDateLabel.text = viewModel.formatDateRange(tour.startDate ?? Date(), tour.endDate ?? Date())

            if let imageURL = viewModel.imageURL(for: tour) {
                cell.tripImageView.load(from: imageURL)
            } else {
                cell.tripImageView.image = UIImage(systemName: "photo")
                cell.tripImageView.tintColor = UIColor(named: "Main")
            }

            cell.placeCountLabel.text = viewModel.locationCountText(for: tour)
            return cell
        }
    }
}
