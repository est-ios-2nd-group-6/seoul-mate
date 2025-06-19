//
//  AddToScheduleSheetViewController.swift
//  SeoulMate
//
//  Created by JuHyeon Seong on 6/11/25.
//

import UIKit

/// 일정 추가 시트가 닫힐 때 호출될 델리게이트 프로토콜.
protocol AddToScheduleSheetViewControllerDelegate: AnyObject {
    /// POI가 일정에 성공적으로 추가되고 시트가 닫혔음을 알림.
    func sheetViewControllerDidDismiss(_ viewController: AddToScheduleSheetViewController)
}

/// `AddToScheduleSheet`의 테이블/컬렉션 뷰에서 사용할 데이터 모델.
struct CellItem {
    /// `Schedule` 객체의 데이터 모델.
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

    /// `Tour` 엔티티로부터 `CellItem`을 초기화.
    init(tour: Tour) {
        id = tour.id
        title = tour.title

        if let startDate = tour.startDate?.summary, let endDate = tour.endDate?.summary {
            period = "\(startDate) ~ \(endDate)"
        }
    }
}

/// 추천 코스나 검색한 장소를 기존 여행 일정에 추가하기 위한 시트(Sheet) 형태의 뷰 컨트롤러.
class AddToScheduleSheetViewController: UIViewController {

    // MARK: - IBOutlet
    @IBOutlet weak var addToScheduleTableView: UITableView!
    @IBOutlet weak var addToScheduleBtn: UIButton!

    // MARK: - IBAction

    /// '일정에 추가하기' 버튼을 탭했을 때 호출.
    ///
    /// 선택된 여행(`Tour`)과 일자(`Schedule`)에 POI들을 추가하고 CoreData에 저장.
    @IBAction func addToSchedule(_ sender: Any) {
        guard let selectedTour = cellItems.first(where: { $0.isSelected }) else { return }
        guard let selectedSchedule = selectedTour.days.first(where: { $0.isSelected }) else { return }
        guard let tourOriginal = ToursOriginal.first(where: { $0.id == selectedTour.id }) else { return }
        guard let schedulesOriginal = tourOriginal.days?.allObjects as? [Schedule] else { return }
        guard let targetSchedule = schedulesOriginal.first(where: { $0.id == selectedSchedule.id }) else { return }

        for poi in pois {
            targetSchedule.addToPois(poi)
        }

        Task {
            await CoreDataManager.shared.saveContextAsync()
        }

        delegate?.sheetViewControllerDidDismiss(self)

        dismiss(animated: true)
    }

    // MARK: - Properties

    /// 테이블 뷰에 표시될 데이터 아이템 배열.
    public var cellItems: [CellItem] = [] {
        didSet {
            validateButton()
        }
    }
    /// 원본 `Tour` 엔티티 배열.
    var ToursOriginal: [Tour] = []

    /// 추가할 `POI` 객체 배열.
    var pois: [POI] = []

    weak var delegate: AddToScheduleSheetViewControllerDelegate?

    var selectedRow: Int? = nil {
        didSet(oldVal) {
            if let oldVal, let selectedRow {
                let old = IndexPath(row: oldVal, section: 0)
                let new = IndexPath(row: selectedRow, section: 0)

                addToScheduleTableView.reloadRows(at: [old, new], with: .automatic)
            }
        }
    }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        self.sheetPresentationController?.detents = [.medium()]
        self.sheetPresentationController?.prefersGrabberVisible = false

        let cell = UINib(nibName: "AddToScheduleTableViewCell", bundle: nil)
        addToScheduleTableView.register(cell, forCellReuseIdentifier: "AddToScheduleTableViewCell")

        Task {
            // CoreData에서 모든 여행 정보를 비동기적으로 가져옴.
            ToursOriginal = await CoreDataManager.shared.fetchToursAsync()

            // 가져온 Tour 데이터를 UI에 표시하기 위한 CellItem 모델로 변환.
            for tour in ToursOriginal {
                guard var schedules = tour.days?.allObjects as? [Schedule] else {
                    continue
                }

                var item = CellItem(tour: tour)

                var days: [CellItem.Day] = []

                schedules = schedules.sorted { $0.date! < $1.date! }

                for (index, schedule) in schedules.enumerated() {
                    let dayText = "Day \(index + 1)"

                    guard let dateText = schedule.date?.monthDayWeekday else { continue }

                    let day = CellItem.Day(id: schedule.id, dayText: dayText, dateText: dateText)

                    days.append(day)
                }

                item.days = days

                cellItems.append(item)
            }

            validateButton()

            addToScheduleTableView.reloadData()
        }
    }

    /// '추가하기' 버튼의 활성화 상태를 검증.
    ///
    /// 선택된 '일자'가 하나라도 있어야 버튼이 활성화됨.
    func validateButton() {
        if cellItems.count(where: { $0.days.count(where: { $0.isSelected == true }) > 0 }) != 0 {
            addToScheduleBtn.isEnabled = true
        } else {
            addToScheduleBtn.isEnabled = false
        }
    }
}

// MARK: - UITableViewDataSource
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

// MARK: - UITableViewDelegate
extension AddToScheduleSheetViewController: UITableViewDelegate {

    /// 사용자가 특정 여행(행)을 선택했을 때 호출.
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let targetIndex = indexPath.row

        var reloadIndexs = [indexPath]

        // 이전에 선택된 행이 있다면 선택 해제하고, 새로운 행을 선택.
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

        // UI 갱신을 위해 해당 행들을 리로드.
        tableView.reloadRows(at: reloadIndexs, with: .automatic)
    }

    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        print(#function, indexPath)
    }
}

// MARK: - AddToScheduleTableViewCellDelegate
extension AddToScheduleSheetViewController: AddToScheduleTableViewCellDelegate {

    /// 하위 셀(AddToScheduleTableViewCell)에서 일자 선택 이벤트가 발생했을 때 호출됨.
    func AddToScheduleTableViewCell(_ cell: AddToScheduleTableViewCell, didUpdateItem item: CellItem) {
        if let index = cellItems.firstIndex(where: { $0.id == item.id }) {
            cellItems[index] = item
        }
    }
}
