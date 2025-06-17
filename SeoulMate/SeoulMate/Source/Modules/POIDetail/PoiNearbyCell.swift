//
//  PoiNearbyCell.swift
//  SeoulMate
//
//  Created by DEV on 6/16/25.
//

import UIKit

class PoiNearbyCell: UITableViewCell {
    var segmentedIndex:Int = 0 {
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
        return 6
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch segmentedIndex {
            case 0:
                let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: POINearbyDetailCell.self)) as! POINearbyDetailCell
                cell.titleLabel.text = "밤비클럽"
                cell.detailLabel.text = "새벽까지 즐길 수 있는 인기 많은 클럽"
                return cell
            case 1:
                let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: POINearbyDetailCell.self)) as! POINearbyDetailCell
                cell.titleLabel.text = "안녕?"
                cell.detailLabel.text = "안녕하세요?"
                return cell
            default:
                return UITableViewCell()
        }
    }
}
