//
//  PoiNearbyCell.swift
//  SeoulMate
//
//  Created by DEV on 6/16/25.
//

import UIKit

class PoiNearbyCell: UITableViewCell {

    var nearbyPlaceList: [TourNearybyAPIGoogleResponse.Place] = [] {
        didSet {
            self.PoiNearbyDetailTableView.reloadData()
        }
    }

    var segmentedIndex: Int = 0 {
        didSet {
            self.PoiNearbyDetailTableView.reloadData()
        }
    }

    @IBOutlet weak var PoiNearbyDetailTableView: UITableView!
    override func awakeFromNib() {
        super.awakeFromNib()
        PoiNearbyDetailTableView.dataSource = self

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }

    @IBAction func changeCategorySegment(_ sender: UISegmentedControl) {
        segmentedIndex = sender.selectedSegmentIndex
    }

}

extension PoiNearbyCell: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch segmentedIndex {
        case 0:
            return nearbyPlaceList.filter { !$0.types.contains("restaurant") }.count
        case 1:
            return nearbyPlaceList.filter { !$0.types.contains("tourist-attraction") }.count
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
                URLSession.shared.dataTask(with: url) { data, _, error in
                    if let data = data {
                        DispatchQueue.main.async {
                            cell.locationImageView.image = UIImage(data: data)
                        }
                    }
                }.resume()
            }
            return cell
        case 1:
            let cell =
                tableView.dequeueReusableCell(withIdentifier: String(describing: POINearbyDetailCell.self))
                as! POINearbyDetailCell
            var list = nearbyPlaceList.filter { !$0.types.contains("tourist-attraction") }
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
                URLSession.shared.dataTask(with: url) { data, _, error in
                    if let data = data {
                        DispatchQueue.main.async {
                            cell.locationImageView.image = UIImage(data: data)
                        }
                    }
                }.resume()
            }
            return cell
        default:
            return UITableViewCell()
        }
    }
}
