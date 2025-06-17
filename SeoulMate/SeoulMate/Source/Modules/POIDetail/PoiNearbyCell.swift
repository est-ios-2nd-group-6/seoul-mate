//
//  PoiNearbyCell.swift
//  SeoulMate
//
//  Created by DEV on 6/16/25.
//

import CoreLocation
import UIKit

class PoiNearbyCell: UITableViewCell {

    var nearbyPlaceList: [TourNearybyAPIGoogleResponse.Place] = [] {
        didSet {
            self.PoiNearbyDetailTableView.reloadData()
        }
    }
    var currentLocation:CurrentLocation = CurrentLocation(longitude: 0.0, latitude: 0.0)
    var segmentedIndex: Int = 0 {
        didSet {
            self.PoiNearbyDetailTableView.reloadData()
        }
    }

    @IBOutlet weak var PoiNearbyDetailTableView: UITableView!
    override func awakeFromNib() {
        super.awakeFromNib()
        PoiNearbyDetailTableView.dataSource = self
        PoiNearbyDetailTableView.delegate = self
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }

    @IBAction func changeCategorySegment(_ sender: UISegmentedControl) {
        print(sender.selectedSegmentIndex)
        segmentedIndex = sender.selectedSegmentIndex
        self.PoiNearbyDetailTableView.reloadData()
    }

}

extension PoiNearbyCell: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch segmentedIndex {
        case 0:
            return nearbyPlaceList.filter { !$0.types.contains("restaurant") }.count
        case 1:
            return nearbyPlaceList.filter { !$0.types.contains("tourist_attraction") }.count
        default:
            break
        }
        return 0
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch segmentedIndex {
        case 0:
            let cell =
                tableView.dequeueReusableCell(withIdentifier: String(describing: POINearbyDetailCell.self))
                as! POINearbyDetailCell
            var list = nearbyPlaceList.filter { !$0.types.contains("restaurant") }
            guard indexPath.row < list.count else { return UITableViewCell() }
            cell.titleLabel.text = list[indexPath.row].displayName.text
            cell.detailLabel.text = list[indexPath.row].primaryTypeDisplayName?.text
            cell.ratingCountLabel.text = "\(list[indexPath.row].rating)"
            if let profileURL = list[indexPath.row].photos.first?.name, let apiKey = Bundle.main.googleApiKey,
                let url = URL(
                    string:
                        "https://places.googleapis.com/v1/\(profileURL)/media?maxHeightPx=75&maxWidthPx=75&key=\(apiKey)"
                )
            {
                Task {
                    do {
                        let (data, _) = try await URLSession.shared.data(from: url)
                        DispatchQueue.main.async {
                            cell.locationImageView.image = UIImage(data: data)
                        }
                    } catch {
                        print(error)
                    }
                }
            }
                let meterDistance = CLLocation(latitude: list[indexPath.row].location.latitude, longitude: list[indexPath.row].location.longitude).distance(from: CLLocation(latitude: currentLocation.latitude, longitude: currentLocation.longitude))
                let killoDistance = meterDistance/1000
                cell.distanceLabel.text = "\(String(format: "%.2f", killoDistance)) KM"
            return cell
        case 1:
            let cell =
                tableView.dequeueReusableCell(withIdentifier: String(describing: POINearbyDetailCell.self))
                as! POINearbyDetailCell
            var list = nearbyPlaceList.filter { !$0.types.contains("tourist_attraction") }
            guard indexPath.row < list.count else { return UITableViewCell() }
            cell.titleLabel.text = list[indexPath.row].displayName.text
            cell.detailLabel.text = list[indexPath.row].primaryTypeDisplayName?.text
            cell.ratingCountLabel.text = "\(list[indexPath.row].rating)"
            if let profileURL = list[indexPath.row].photos.first?.name, let apiKey = Bundle.main.googleApiKey,
                let url = URL(
                    string:
                        "https://places.googleapis.com/v1/\(profileURL)/media?maxHeightPx=75&maxWidthPx=75&key=\(apiKey)"
                )
            {
                Task {
                    do {
                        let (data, _) = try await URLSession.shared.data(from: url)
                        DispatchQueue.main.async {
                            cell.locationImageView.image = UIImage(data: data)
                        }
                    } catch {
                        print(error)
                    }
                }
            }
            return cell
        default:
            return UITableViewCell()
        }
    }
}
extension PoiNearbyCell: UITableViewDelegate {

}
