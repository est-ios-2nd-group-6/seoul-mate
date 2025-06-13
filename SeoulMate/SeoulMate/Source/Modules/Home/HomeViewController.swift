//
//  HomeViewController.swift
//  SeoulMate
//
//  Created by JuHyeon Seong on 6/9/25.
//

import UIKit
import CoreLocation

class HomeViewController: UIViewController {
    @IBOutlet weak var rcmCourseListByAreaCollectionView: UICollectionView!
    let locationManager: CLLocationManager = CLLocationManager()

    var rcmCourseListByArea: [RecommandCourse] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        locationManager.delegate = self

        Task {
            await TourApiManager.shared.fetchRcmCourseList(by: .area)
            //            await TourApiManager.shared.fetchRcmCourseList(by: .location, x: , )
            rcmCourseListByArea = TourApiManager.shared.rcmCourseListByArea

            rcmCourseListByAreaCollectionView.reloadData()

            locationManager.startUpdatingLocation()
        }
    }
}

extension HomeViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return min(rcmCourseListByArea.count, 5)
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "RecommandCourseCollectionViewCell", for: indexPath) as? RecommandCourseCollectionViewCell
        else { return UICollectionViewCell() }

        let course = rcmCourseListByArea[indexPath.item]

        cell.wrapperView.layer.borderColor = UIColor.tertiaryLabel.cgColor
        cell.wrapperView.layer.borderWidth = 1
        cell.wrapperView.layer.cornerRadius = 8

        cell.wrapperView.clipsToBounds = true

        cell.thumbnailImageView.image = course.image
        cell.titleLabel.text = course.title

        return cell
    }
}

extension HomeViewController: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedWhenInUse: // 위치 서비스를 사용 가능한 상태
            print("위치 서비스 사용 가능")
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
            print(coordinate)
        }
    }

    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("위치 정보를 받아오는 데 실패함")
    }
}
