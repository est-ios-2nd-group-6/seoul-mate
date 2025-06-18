//
//  HomeViewController.swift
//  SeoulMate
//
//  Created by JuHyeon Seong on 6/9/25.
//

import UIKit
import CoreLocation

/// 앱의 홈 화면을 담당하는 뷰 컨트롤러.
///
/// 지역 기반 추천 코스와 사용자 위치 기반 추천 코스를 각각 컬렉션 뷰에 표시함.
class HomeViewController: UIViewController {

    // MARK: - IBOutlet
    @IBOutlet weak var rcmCourseListByAreaLabel: UIStackView!
    @IBOutlet weak var rcmCourseListByAreaCollectionView: UICollectionView!

    @IBOutlet weak var rcmCourseListByLocationLabel: UIStackView!
    @IBOutlet weak var rcmCourseListByLocationCollectionView: UICollectionView!

    // MARK: - Properties
    let locationManager: CLLocationManager = CLLocationManager()

    var rcmCourseListByArea: [RecommandCourse] = []
    var rcmCourseListByLocation: [RecommandCourse] = []

    /// 위치 기반 코스 목록 API가 이미 호출되었는지 여부를 확인하는 플래그. 중복 호출 방지용.
    var isFetchedLocationList: Bool = false

    // MARK: - Navigation

    /// 화면 전환 직전 호출되어, 목적지에 따라 적절한 데이터를 전달.
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let courseListVC = segue.destination as? RecommandCourseListViewController {
            // '더보기' 버튼을 통해 전환 시
            if let button = sender as? UIButton {
                switch button.tag {
                case 1:
                    courseListVC.by = .area
                case 2:
                    courseListVC.by = .location
                default: return
                }
            }
        } else if let courseDetailVC = segue.destination as? RecommandCourseDetailViewController {
            // 특정 코스 셀을 선택하여 전환 시
            if let cell = sender as? RecommandCourseCollectionViewCell {
                if cell.reuseIdentifier == "rcmCourseListByAreaCell" {
                    let selectedIndex = rcmCourseListByAreaCollectionView.indexPath(for: cell)?.item

                    if let selectedIndex {
                        courseDetailVC.course = rcmCourseListByArea[selectedIndex]
                    }

                } else if cell.reuseIdentifier == "rcmCourseListByLocationCell" {
                    let selectedIndex = rcmCourseListByLocationCollectionView.indexPath(for: cell)?.item

                    if let selectedIndex {
                        courseDetailVC.course = rcmCourseListByLocation[selectedIndex]
                    }
                }
            }
        }
    }

    // MARK: - Lifecycle

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        // 다크/라이트 모드 변경 시 UI 갱신
        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            rcmCourseListByAreaCollectionView.reloadData()

            if rcmCourseListByLocationCollectionView.isHidden == false {
                rcmCourseListByLocationCollectionView.reloadData()
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // 초기에는 위치 기반 추천 목록 숨김 처리.
        rcmCourseListByLocationLabel.isHidden = true
        rcmCourseListByLocationCollectionView.isHidden = true

        locationManager.delegate = self

        Task {
            // 뷰 로드 시 지역 기반 추천 코스 목록을 우선적으로 비동기 호출.
            await TourApiManager.shared.fetchRcmCourseList(by: .area)
            rcmCourseListByArea = TourApiManager.shared.rcmCourseListByArea

            rcmCourseListByAreaCollectionView.reloadData()

            // 위치 정보 사용 권한 요청.
            locationManager.requestLocation()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = false
    }
}

// MARK: - UICollectionViewDataSource
extension HomeViewController: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == rcmCourseListByAreaCollectionView {
            return min(rcmCourseListByArea.count, 5)
        } else if collectionView == rcmCourseListByLocationCollectionView {
            return min(rcmCourseListByLocation.count, 5)
        } else {
            return 0
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == rcmCourseListByAreaCollectionView {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "rcmCourseListByAreaCell", for: indexPath) as? RecommandCourseCollectionViewCell else { return UICollectionViewCell() }

            let course: RecommandCourse = rcmCourseListByArea[indexPath.item]

            cell.wrapperView.layer.borderColor = UIColor.tertiaryLabel.cgColor
            cell.wrapperView.layer.borderWidth = 1
            cell.wrapperView.layer.cornerRadius = 8
            cell.wrapperView.clipsToBounds = true
            cell.thumbnailImageView.image = course.image
            cell.titleLabel.text = course.title

            return cell

        } else if collectionView == rcmCourseListByLocationCollectionView {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "rcmCourseListByLocationCell", for: indexPath) as? RecommandCourseCollectionViewCell else { return UICollectionViewCell() }

            let course = rcmCourseListByLocation[indexPath.item]

            cell.wrapperView.layer.borderColor = UIColor.tertiaryLabel.cgColor
            cell.wrapperView.layer.borderWidth = 1
            cell.wrapperView.layer.cornerRadius = 8
            cell.wrapperView.clipsToBounds = true
            cell.thumbnailImageView.image = course.image
            cell.titleLabel.text = course.title

            return cell

        } else {
            return UICollectionViewCell()
        }
    }
}

// MARK: - CLLocationManagerDelegate
extension HomeViewController: CLLocationManagerDelegate {

    /// 위치 서비스 권한 상태가 변경될 때 호출.
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedWhenInUse: // 위치 서비스를 사용 가능한 상태
            print("위치 서비스 사용 가능")
            locationManager.requestLocation()
            break
        case .restricted, .denied: // 위치 서비스를 사용 가능하지 않은 상태
            print("위치 서비스 사용 불가")
            break
        case .notDetermined: // 권한 설정이 되어 있지 않은 상태
            print("권한 설정 필요")
            locationManager.requestWhenInUseAuthorization() // 권한 요청
            break
        default:
            break
        }
    }

    /// 위치 정보가 업데이트될 때 호출.
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let coordinate = locations.last?.coordinate {
            // 위치 기반 코스 목록이 아직 호출되지 않았을 경우에만 API 호출 실행.
            if isFetchedLocationList { return }

            if TourApiManager.shared.rcmCourseListByLocation.count == 0 {
                Task {
                    isFetchedLocationList = true

                    await TourApiManager.shared.fetchRcmCourseList(
                        by: .location,
                        x: coordinate.longitude,
                        y: coordinate.latitude
                    )

                    rcmCourseListByLocation = TourApiManager.shared.rcmCourseListByLocation

                    rcmCourseListByLocationCollectionView.reloadData()

                    // 데이터 로드 후 숨겨뒀던 UI를 애니메이션과 함께 표시.
                    UIView.animate(withDuration: 0.3) { [weak self] in
                        self?.rcmCourseListByLocationLabel.isHidden = false
                        self?.rcmCourseListByLocationCollectionView.isHidden = false
                    }
                }
            }
        }
    }

    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location manager failed with error: \(error.localizedDescription)")
    }
}
