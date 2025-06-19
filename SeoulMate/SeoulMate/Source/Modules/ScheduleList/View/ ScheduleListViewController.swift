//
//  ScheduleListViewController.swift
//  SeoulMate
//
//  Created by 윤혜주 on 6/8/25.
//

import UIKit

/// 서울메이트 앱의 일정 목록 화면을 관리하는 뷰 컨트롤러입니다.
///
/// - 여행 일정 리스트를 표시하고,
/// - 플로팅 버튼 또는 네비게이션 바 버튼을 통해 새 일정을 추가하며,
/// - 여행 일정 삭제 및 상세 지도 화면으로 이동 기능을 제공합니다.
class ScheduleListViewController: UIViewController {
    /// `TripItem` 배열을 로컬에 저장하는 프로퍼티입니다.
    private var tripItems: [TripItem] = []

    /// 일정 목록을 표시하는 테이블 뷰 아웃렛입니다.
    @IBOutlet weak var scheduleListTableView: UITableView!

    /// iPad에서의 추가 버튼 대체용 바텀 플로팅 버튼 아웃렛입니다.
    @IBOutlet weak var floatingButton: UIButton!

    /// 로딩 중 오버레이 뷰를 참조합니다.
    private var loadingOverlay: UIView?

    /// 일정 데이터를 가져오는 뷰 모델 객체입니다.
    private let viewModel = ScheduleModel()

    /// 모든 POI의 Asset 이미지 이름 배열을 계산하여 미리 로드에 사용합니다.
    private lazy var allAssetNames: [String] = {
        viewModel.tripItems.compactMap { item in
            if case .trip(let tour) = item,
               let poi = viewModel.thumbnailPOI(for: tour) {
                return poi.assetImageName
            }
            return nil
        }
    }()

    /// 뷰가 로드된 후 초기 설정을 수행합니다.
    override func viewDidLoad() {
        super.viewDidLoad()

        // 테이블 뷰 프리페치 설정
        scheduleListTableView.prefetchDataSource = self
        // 로딩 오버레이 표시
        showLoadingOverlay()

        // iPad일 경우, 플로팅 버튼 대신 내비게이션 바 버튼 사용
        if UIDevice.current.userInterfaceIdiom == .pad {
            floatingButton.isHidden = true
            navigationItem.rightBarButtonItem = UIBarButtonItem(
                barButtonSystemItem: .add,
                target: self,
                action: #selector(floattingTapped)
            )
        } else {
            // iPhone은 플로팅 버튼 디자인 및 액션 설정
            FloatingButtondesign()
            floatingButton.addTarget(self,
                                     action: #selector(floattingTapped),
                                     for: .touchUpInside)
        }

        // 더미 데이터 시딩
        CoreDataManager.shared.seedDummyData()

        // 뷰 모델에서 일정 목록을 가져오고 UI 갱신
        Task { @MainActor in
            await viewModel.fetchScheduleList()
            preloadAssetImages()
            hideLoadingOverlay()
            scheduleListTableView.reloadData()
        }
    }

    /// 뷰가 화면에 표시되기 직전에 내비게이션 바 보이기 및 색상 설정.
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
        navigationController?.navigationBar.tintColor = .label

        // 화면 재진입 시 리스트 갱신
        Task {
            await viewModel.fetchScheduleList()
            await MainActor.run {
                scheduleListTableView.reloadData()
            }
        }
    }

    /// 모든 Asset  이미지 이름을 백그라운드 스레드에서 미리 로드합니다.
    private func preloadAssetImages() {
        DispatchQueue.global(qos: .userInitiated).async {
            for name in self.allAssetNames {
                _ = UIImage(named: name)
            }
        }
    }

    /// 로딩 오버레이와 스피너, 텍스트를 추가하여 화면을 덮습니다.
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

    /// 로딩 오버레이를 제거합니다.
    private func hideLoadingOverlay() {
        loadingOverlay?.removeFromSuperview()
        loadingOverlay = nil
    }

    /// 플로팅 버튼 또는 내비게이션 버튼 탭 시 호출되어 일정 추가 화면으로 이동합니다.
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

    /// 플로팅 버튼 디자인을 설정합니다.
    private func FloatingButtondesign() {
        floatingButton.setImage(UIImage(systemName: "plus"), for: .normal)
        floatingButton.tintColor = .main
        floatingButton.layer.cornerRadius = floatingButton.frame.height / 2
        floatingButton.clipsToBounds = true
    }

    /// "..." 버튼 액션: 투어 삭제 액션 시트 표시 기능.
    @IBAction func moreButton(_ sender: Any) {
        guard let button = sender as? UIButton else { return }

        // 버튼의 셀을 찾아 해당 인덱스 경로, 투어 객체 검색
        var view = button.superview
        while let current = view {
            if let cell = current as? ScheduleListTripTableViewCell,
               let indexPath = scheduleListTableView.indexPath(for: cell) {

                let item = viewModel.tripItems[indexPath.row]
                guard case .trip(let tour) = item else { return }

                let alert = UIAlertController(title: "옵션", message: nil, preferredStyle: .actionSheet)

                // 삭제 액션 추가
                alert.addAction(UIAlertAction(title: "삭제", style: .destructive) { _ in
                    let row = indexPath.row
                    let index = IndexPath(row: row, section: 0)

                    self.viewModel.tripItems.remove(at: row)

                    self.scheduleListTableView.performBatchUpdates {
                        self.scheduleListTableView.deleteRows(at: [index], with: .automatic)
                    }

                    Task {
                        await self.viewModel.delete(tour: tour)
                    }
                })

                // 취소 액션 추가
                alert.addAction(UIAlertAction(title: "취소", style: .cancel))

                // iPad용 팝오버 설정
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

// MARK: - UITableViewDataSource
extension ScheduleListViewController: UITableViewDataSource {
    /// 섹션 없이 단일 섹션 형태로 총 행 개수를 반환합니다.
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        return viewModel.tripItems.count
    }

    /// `TripItem` 배열을 기반으로 각 행에 알맞은 셀을 반환합니다.
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

            // 투어 정보 설정
            cell.tripNameLabel.text = viewModel.displayTitle(for: tour)
            cell.tripDateLabel.text = viewModel.formatDateRange(tour.startDate ?? Date(), tour.endDate ?? Date())
            let placeholder = UIImage(systemName: "photo")?.withTintColor(UIColor(named: "Main")!, renderingMode: .alwaysOriginal)
            cell.contentView.alpha = 0

            // 이미지 URL이 있으면 비동기 로드, 없으면 asset 또는 placeholder
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

            // 렌더링 성능 최적화 설정
            cell.tripImageView.layer.drawsAsynchronously = true
            cell.tripImageView.layer.shouldRasterize = true
            cell.tripImageView.layer.rasterizationScale = UIScreen.main.scale

            cell.placeCountLabel.text = viewModel.locationCountText(for: tour)
            return cell
        }
    }
}
// MARK: - UITableViewDelegate
extension ScheduleListViewController: UITableViewDelegate {
    /// 셀 선택 시 상세 일정을 표시해주는 지도 화면으로 이동합니다.
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
// MARK: - UITableViewDataSourcePrefetching
extension ScheduleListViewController: UITableViewDataSourcePrefetching {
    /// 다음 로드할 행의 자산 이미지를 미리 로드하여 스크롤 성능을 개선합니다.
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
