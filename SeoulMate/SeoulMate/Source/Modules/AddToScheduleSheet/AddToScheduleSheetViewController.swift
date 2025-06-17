//
//  AddToScheduleSheetViewController.swift
//  SeoulMate
//
//  Created by JuHyeon Seong on 6/11/25.
//

import UIKit

struct CellItem {
    struct Day {
        var id: UUID?
        var dayText: String
        var dateText: String
        var isSelected: Bool = false
    }

    var id: UUID?
    var title: String?
    var period: String?
    var days: [Day] = []
    var isSelected: Bool = false

    init(tour: Tour) {
        id = tour.id
        title = tour.title

        if let startDate = tour.startDate?.summary, let endDate = tour.endDate?.summary {
            period = "\(startDate) ~ \(endDate)"
        }
    }
}

class AddToScheduleSheetViewController: UIViewController {
    @IBOutlet weak var addToScheduleTableView: UITableView!

    @IBOutlet weak var addToScheduleBtn: UIButton!

    @IBAction func addToSchedule(_ sender: Any) {
        guard let selectedTour = cellItems.first(where: { $0.isSelected }) else { return }
        guard let selectedSchedule = selectedTour.days.first(where: { $0.isSelected }) else { return }
        guard let tourOriginal = ToursOriginal.first(where: { $0.id == selectedTour.id }) else { return }
        guard let schedulesOriginal = tourOriginal.days?.allObjects as? [Schedule] else { return }
        guard let targetSchedule = schedulesOriginal.first(where: { $0.id == selectedSchedule.id }) else { return }

        for poi in pois {
            targetSchedule.addToPois(poi)
        }

        CoreDataManager.shared.saveContext()

        dismiss(animated: true)
    }

    public var cellItems: [CellItem] = [] {
        didSet {
            validateButton()
        }
    }

    var ToursOriginal: [Tour] = []

    var pois: [POI] = []

    var selectedRow: Int? = nil {
        didSet(oldVal) {
            if let oldVal, let selectedRow {
                let old = IndexPath(row: oldVal, section: 0)
                let new = IndexPath(row: selectedRow, section: 0)

                addToScheduleTableView.reloadRows(at: [old, new], with: .automatic)
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.sheetPresentationController?.detents = [.medium()]
        self.sheetPresentationController?.prefersGrabberVisible = false

		let cell = UINib(nibName: "AddToScheduleTableViewCell", bundle: nil)
        addToScheduleTableView.register(cell, forCellReuseIdentifier: "AddToScheduleTableViewCell")

        Task {
            ToursOriginal = await CoreDataManager.shared.fetchToursAsync()

            for tour in ToursOriginal {
                guard let schedules = tour.days?.allObjects as? [Schedule] else {
					continue
                }

                var item = CellItem(tour: tour)

                var days: [CellItem.Day] = []

                for (index, schedule) in schedules.enumerated() {
                    let dayText = "Day \(index + 1)"

                    guard let dateText = schedule.date?.monthDayWeekday else { continue }

                    let day = CellItem.Day(id: schedule.id, dayText: dayText, dateText: dateText)

                    days.append(day)
                }

                item.days = days

                cellItems.append(item)
            }

            cellItems[0].isSelected = true
            cellItems[0].days[0].isSelected = true

            addToScheduleTableView.reloadData()
        }
    }

    func validateButton() {
        if cellItems.count(where: { $0.days.count(where: { $0.isSelected == true }) > 0 }) != 0 {
            addToScheduleBtn.isEnabled = true
        } else {
            addToScheduleBtn.isEnabled = false
        }
    }
}

extension AddToScheduleSheetViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cellItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "AddToScheduleTableViewCell") as? AddToScheduleTableViewCell else {
            return UITableViewCell()
        }

        let item = cellItems[indexPath.row]

        cell.delegate = self
        cell.configure(with: item)

        return cell
    }
}

extension AddToScheduleSheetViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let targetIndex = indexPath.row

        var reloadIndexs = [indexPath]

        if let selected = cellItems.firstIndex(where: { $0.isSelected == true }) {
            if selected != targetIndex {
                cellItems[selected].isSelected = false
                cellItems[targetIndex].isSelected = true

                for (i, _) in cellItems[selected].days.enumerated() {
                    cellItems[selected].days[i].isSelected = false
                }

                reloadIndexs.append(IndexPath(row: selected, section: 0))
            }
        } else {
            cellItems[targetIndex].isSelected = true
        }

        tableView.reloadRows(at: reloadIndexs, with: .automatic)
    }

    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        print(#function, indexPath)
    }
}

extension AddToScheduleSheetViewController: AddToScheduleTableViewCellDelegate {
    func AddToScheduleTableViewCell(_ cell: AddToScheduleTableViewCell, didUpdateItem item: CellItem) {
        if let index = cellItems.firstIndex(where: { $0.id == item.id }) {
			cellItems[index] = item
        }
    }
}
