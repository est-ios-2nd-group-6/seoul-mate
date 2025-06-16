//
//  PoiNearbyCell.swift
//  SeoulMate
//
//  Created by DEV on 6/16/25.
//

import UIKit

class PoiNearbyCell: UITableViewCell {

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
        
    }
    
}

extension PoiNearbyCell: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 6
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: POINearbyDetailCell.self)) as! POINearbyDetailCell
        return cell
    }
}
