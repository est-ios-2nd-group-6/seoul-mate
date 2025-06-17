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
            await TourApiManager_hs.shared.fetchPOIDetailNearbyPlace(latitude: 37.7937, longitude: -122.3965)
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
                tableView.dequeueReusableCell(withIdentifier: String(describing: PoiInfoCell.self)) as! PoiInfoCell
            if let location = location {
                cell.titleLabel.text = location.title
                cell.reviewNumberLabel.text = "\(location.rating)"
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
                tableView.dequeueReusableCell(withIdentifier: String(describing: PoiNearbyCell.self)) as! PoiNearbyCell
                cell.nearbyPlaceList = TourApiManager_hs.shared.nearybyPlaceList
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
