//
//  ScheduleListViewController.swift
//  SeoulMate
//
//  Created by 윤혜주 on 6/8/25.
//

import UIKit

class ScheduleListViewController: UIViewController {
    private var tripItems: [TripItem] = []

    @IBOutlet weak var scheduleListTableView: UITableView!
    @IBOutlet weak var floatingButton: UIButton!

    private var loadingOverlay: UIView?
    private let viewModel = ScheduleModel()

    private lazy var allAssetNames: [String] = {
        viewModel.tripItems.compactMap { item in
            if case .trip(let tour) = item,
               let poi = viewModel.thumbnailPOI(for: tour) {
                return poi.assetImageName
            }
            return nil
        }
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        scheduleListTableView.prefetchDataSource = self
        FloatingButtondesign()
        showLoadingOverlay()

        Task {
            await CoreDataManager.shared.seedDummyData()
            await viewModel.fetchScheduleList()
            preloadAssetImages()
            await MainActor.run {
                self.hideLoadingOverlay()
                self.scheduleListTableView.reloadData()
            }
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
        Task {
            await viewModel.fetchScheduleList()
            await MainActor.run {
                scheduleListTableView.reloadData()
            }
        }
    }

    private func preloadAssetImages() {
        DispatchQueue.global(qos: .userInitiated).async {
            for name in self.allAssetNames {
                _ = UIImage(named: name)
            }
        }
    }

    private func showLoadingOverlay() {
        let overlay = UIView(frame: view.bounds)
        overlay.backgroundColor = UIColor.systemBackground.withAlphaComponent(0.8)
        overlay.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        let spinner = UIActivityIndicatorView(style: .large)
        spinner.color = .main
        spinner.translatesAutoresizingMaskIntoConstraints = false
        spinner.startAnimating()
        overlay.addSubview(spinner)

        let label = UILabel()
        label.text = "여행 기록 불러오는 중..."
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textColor = .main
        label.translatesAutoresizingMaskIntoConstraints = false
        overlay.addSubview(label)

        NSLayoutConstraint.activate([
            spinner.centerXAnchor.constraint(equalTo: overlay.centerXAnchor),
            spinner.centerYAnchor.constraint(equalTo: overlay.centerYAnchor),
            label.topAnchor.constraint(equalTo: spinner.bottomAnchor, constant: 12),
            label.centerXAnchor.constraint(equalTo: overlay.centerXAnchor)
        ])

        view.addSubview(overlay)
        loadingOverlay = overlay
    }

    private func hideLoadingOverlay() {
        loadingOverlay?.removeFromSuperview()
        loadingOverlay = nil
    }

    @IBAction func floattingTapped(_ sender: Any) {
        let sb = UIStoryboard(name: "Calendar", bundle: nil)
        guard let vc = sb.instantiateViewController(
            withIdentifier: "CalendarViewController"
        ) as? CalendarViewController
        else {
            return
        }
        navigationController?.pushViewController(vc, animated: true)
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
            let placeholder = UIImage(systemName: "photo")?.withTintColor(UIColor(named: "Main")!, renderingMode: .alwaysOriginal)
            cell.contentView.alpha = 0

            if let imageURL = viewModel.imageURL(for: tour) {
                cell.tripImageView.load(from: imageURL) {
                    UIView.animate(withDuration: 0.25) {
                        cell.contentView.alpha = 1
                    }
                }
            } else if let poi = viewModel.thumbnailPOI(for: tour) {
                let assetName = poi.assetImageName
                if let img = UIImage(named: assetName) {
                    cell.tripImageView.image = img
                } else {
                    cell.tripImageView.image = placeholder
                }
                cell.contentView.alpha = 1
            } else {
                cell.tripImageView.image = placeholder
                cell.contentView.alpha = 1
            }

            cell.tripImageView.layer.drawsAsynchronously = true
            cell.tripImageView.layer.shouldRasterize = true
            cell.tripImageView.layer.rasterizationScale = UIScreen.main.scale

            cell.placeCountLabel.text = viewModel.locationCountText(for: tour)
            return cell
        }
    }
}
extension ScheduleListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let item = viewModel.tripItems[indexPath.row]
        guard case .trip(let tour) = item else { return }

        let sb = UIStoryboard(name: "Map", bundle: nil)
        guard let mapVC = sb.instantiateViewController(
            withIdentifier: "MapViewController"
        ) as? MapViewController
        else { return }

        mapVC.tour = tour
        navigationController?.pushViewController(mapVC, animated: true)
    }
}
extension ScheduleListViewController: UITableViewDataSourcePrefetching {
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        for ip in indexPaths {
            guard case .trip(let tour) = viewModel.tripItems[ip.row],
                  viewModel.imageURL(for: tour) == nil,
                  let name = viewModel.thumbnailPOI(for: tour)?.assetImageName else { continue }

            DispatchQueue.global(qos: .utility).async {
                _ = UIImage(named: name)
            }
        }
    }
}
