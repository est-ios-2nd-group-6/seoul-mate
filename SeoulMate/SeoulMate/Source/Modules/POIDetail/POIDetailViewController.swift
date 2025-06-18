//
//  Detail.swift
//  SeoulMate
//
//  Created by DEV on 6/12/25.
//

import UIKit

enum POICellType {
    case Location
    case Recommandation
}

class POIDetailViewController: UIViewController {

    var POIItems: [POICellType] = []
    var nameLabel: String = ""
    var location: PlaceInfo?
    var id: String?
    var latitude: Double?
    var longtitude: Double?
    var pois: [POI] = []

    @IBOutlet weak var detailTableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        detailTableView.dataSource = self
        detailTableView.delegate = self
        var cellItem: [POICellType] = []
        cellItem.append(.Location)
        cellItem.append(.Recommandation)
        POIItems = cellItem
        self.detailTableView.reloadData()
        Task {
            await TourApiManager_hs.shared.fetchGooglePlaceAPIByName(name: nameLabel)
            location = TourApiManager_hs.shared.placeInfo
            guard let longitude = location?.longitude, let latitude = location?.latitude else { return }
            await TourApiManager_hs.shared.fetchPOIDetailNearbyPlace(latitude: latitude, longitude: longitude)
            self.detailTableView.reloadData()
        }
    }
}

extension POIDetailViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return POIItems.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch POIItems[indexPath.row] {
        case .Location:
            let cell =
                tableView.dequeueReusableCell(withIdentifier: String(describing: POIInfoCell.self)) as! POIInfoCell
            cell.delegate = self
            if let location = location {
                cell.titleLabel.text = location.title
                cell.reviewNumberLabel.text = "\(String(describing: location.rating ?? 0))"
                cell.addressLabel.text = location.address
                if let url = location.profileImage {
                    URLSession.shared.dataTask(with: url) { data, _, error in
                        if let data = data {
                            DispatchQueue.main.async {
                                cell.placeImageView.image = UIImage(data: data)
                            }
                        }
                    }.resume()
                }
            }
            return cell
        case .Recommandation:
            let cell =
                tableView.dequeueReusableCell(withIdentifier: String(describing: POINearbyCell.self)) as! POINearbyCell
            cell.nearbyPlaceList = TourApiManager_hs.shared.nearybyPlaceList
            if let longitude = location?.longitude, let latitude = location?.latitude {
                cell.currentLocation = CurrentLocation(longitude: longitude, latitude: latitude)
            }
            return cell
        }
    }
}

extension POIDetailViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch POIItems[indexPath.row] {
        case .Location:
            return 400
        case .Recommandation:
            return 675
        }
    }
}

protocol POIDetailViewControllerDelegate: AnyObject {
    func didAddScheduleButtonTapped()
    func didFindRoutesButtonTapped()
    func didShareButtonTapped()
}

extension POIDetailViewController: POIDetailViewControllerDelegate {
    func didAddScheduleButtonTapped() {
        let sheet = AddToScheduleSheetViewController()
        sheet.pois = pois
        sheet.delegate = self
        present(sheet, animated: true)
    }

    func didFindRoutesButtonTapped() {
        let route = RouteMapViewController()
        route.pois = pois
        performSegue(withIdentifier: "RouteMap", sender: pois)
    }

    func didShareButtonTapped() {

    }
}

extension POIDetailViewController: AddToScheduleSheetViewControllerDelegate {
    func sheetViewControllerDidDismiss(_ viewController: AddToScheduleSheetViewController) {
        self.showInAppNotification(message: "길 안내로 이동합니다.", duration: 2, backgroundColor: .main)
    }
}
