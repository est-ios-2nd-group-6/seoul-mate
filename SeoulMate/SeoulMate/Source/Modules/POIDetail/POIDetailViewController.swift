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
    var nameLabel:String = ""
    
    @IBOutlet weak var detailTableView: UITableView!

    @IBAction func dismissView(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        detailTableView.dataSource = self
        detailTableView.delegate = self
        var testItem:[POICellType] = []
        testItem.append(.Location)
        testItem.append(.Recommandation)
        POIItems = testItem
        self.detailTableView.reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print(#line,nameLabel)
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
                return cell
        case .Recommandation:
            let cell =
                tableView.dequeueReusableCell(withIdentifier: String(describing: PoiNearbyCell.self)) as! PoiNearbyCell
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
