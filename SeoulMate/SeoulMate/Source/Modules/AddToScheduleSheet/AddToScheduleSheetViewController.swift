//
//  AddToScheduleSheetViewController.swift
//  SeoulMate
//
//  Created by JuHyeon Seong on 6/11/25.
//

import UIKit

class AddToScheduleSheetViewController: UIViewController {
    @IBOutlet weak var addToScheduleTableView: UITableView!

    var tours: [Tour] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        self.sheetPresentationController?.detents = [.medium()]
        self.sheetPresentationController?.prefersGrabberVisible = false

		let cell = UINib(nibName: "AddToScheduleTableViewCell", bundle: nil)
        addToScheduleTableView.register(cell, forCellReuseIdentifier: "AddToScheduleTableViewCell")

        Task {
            tours = await CoreDataManager.shared.fetchToursAsync()

            addToScheduleTableView.reloadData()
        }
    }
}

extension AddToScheduleSheetViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tours.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "AddToScheduleTableViewCell") as? AddToScheduleTableViewCell else {
            return UITableViewCell()
        }

        let tour = tours[indexPath.item]

        if let schedules = tour.days?.allObjects as? [Schedule] {
            cell.schedules = schedules

            cell.reloadCollectionView()
        }

        cell.contentView.layer.cornerRadius = 8
        cell.contentView.clipsToBounds = true

        cell.contentView.backgroundColor = .lightGray.withAlphaComponent(0.1)

        cell.titleLabel.text = tour.title

        if let startDate = tour.startDate?.summary, let endDate = tour.endDate?.summary {
            cell.periodLabel.text = "\(startDate) ~ \(endDate)"
        }

        return cell
    }
    

}
