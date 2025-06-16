//
//  Detail.swift
//  SeoulMate
//
//  Created by DEV on 6/12/25.
//

import UIKit
class PoiDetailViewController: UIViewController {
    @IBOutlet weak var detailTableView: UITableView!
    @IBAction func dismissView(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        detailTableView.dataSource = self
        detailTableView.delegate = self
    }
}

extension PoiDetailViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: PoiInfoCell.self)) as! PoiInfoCell
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: PoiNearbyCell.self)) as! PoiNearbyCell
        return cell
    }
}

extension PoiDetailViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 380
    }
}
