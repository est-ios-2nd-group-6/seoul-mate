//
//  AddToScheduleSheetViewController.swift
//  SeoulMate
//
//  Created by JuHyeon Seong on 6/11/25.
//

import UIKit

class AddToScheduleSheetViewController: UIViewController {
    @IBOutlet weak var addToScheduleTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.sheetPresentationController?.detents = [.medium()]
        self.sheetPresentationController?.prefersGrabberVisible = false

		let cell = UINib(nibName: "AddToScheduleTableViewCell", bundle: nil)
        addToScheduleTableView.register(cell, forCellReuseIdentifier: "AddToScheduleTableViewCell")
    }
}

extension AddToScheduleSheetViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "AddToScheduleTableViewCell") as? AddToScheduleTableViewCell else {
            return UITableViewCell()
        }

        cell.contentView.layer.cornerRadius = 8
        cell.contentView.clipsToBounds = true

        cell.contentView.backgroundColor = .lightGray.withAlphaComponent(0.1)


        cell.titleLabel
        cell.periodLabel

        return cell
    }
    

}
