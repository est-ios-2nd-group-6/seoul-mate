//
//  HomeViewController.swift
//  SeoulMate
//
//  Created by JuHyeon Seong on 6/9/25.
//

import UIKit
import CoreLocation

class HomeViewController: UIViewController {
    @IBOutlet weak var rcmCourseListByAreaLabel: UIStackView!
    @IBOutlet weak var rcmCourseListByAreaCollectionView: UICollectionView!

    @IBOutlet weak var rcmCourseListByLocationLabel: UIStackView!
    @IBOutlet weak var rcmCourseListByLocationCollectionView: UICollectionView!

    let locationManager: CLLocationManager = CLLocationManager()

    var rcmCourseListByArea: [RecommandCourse] = []
    var rcmCourseListByLocation: [RecommandCourse] = []

    var isFetchedLocationList: Bool = false

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let courseListVC = segue.destination as? RecommandCourseListViewController {
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

    override func viewDidLoad() {
        super.viewDidLoad()

        rcmCourseListByLocationLabel.isHidden = true
        rcmCourseListByLocationCollectionView.isHidden = true

        locationManager.delegate = self

        Task {
            await TourApiManager.shared.fetchRcmCourseList(by: .area)
            rcmCourseListByArea = TourApiManager.shared.rcmCourseListByArea

            rcmCourseListByAreaCollectionView.reloadData()

            locationManager.requestLocation()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.tabBarController?.tabBar.isHidden = false
    }
}

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

extension HomeViewController: UICollectionViewDelegate {

}

extension HomeViewController: CLLocationManagerDelegate {
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

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let coordinate = locations.last?.coordinate {
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

                    UIView.animate(withDuration: 0.3) { [weak self] in
                        self?.rcmCourseListByLocationLabel.isHidden = false
                        self?.rcmCourseListByLocationCollectionView.isHidden = false
                    }

                }

            }

        }
    }

    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {

    }
}
