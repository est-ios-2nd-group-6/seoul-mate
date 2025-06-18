//
//  AddToScheduleTableViewCell.swift
//  SeoulMate
//
//  Created by JuHyeon Seong on 6/11/25.
//

import UIKit

/// `AddToScheduleTableViewCell`에서 발생하는 상호작용을 처리하기 위한 델리게이트 프로토콜.
protocol AddToScheduleTableViewCellDelegate: AnyObject {
    /// 셀 내부의 일자(Day) 아이템이 업데이트되었을 때 호출.
    /// - Parameters:
    ///   - cell: 이벤트가 발생한 `AddToScheduleTableViewCell`.
    ///   - item: 업데이트된 `CellItem` 데이터.
    func AddToScheduleTableViewCell(_ cell: AddToScheduleTableViewCell, didUpdateItem item: CellItem)
}

/// 단일 여행 계획(Tour) 정보를 표시하는 테이블 뷰 셀.
///
/// 내부에 일자 목록을 보여주는 컬렉션 뷰를 포함.
class AddToScheduleTableViewCell: UITableViewCell {
    @IBOutlet weak var wrapperStackView: UIStackView!

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var periodLabel: UILabel!
    @IBOutlet weak var scheduleListCollectionView: UICollectionView!

    @IBOutlet weak var scheduleListCollectionViewHeightConstraint: NSLayoutConstraint!

    weak var delegate: AddToScheduleTableViewCellDelegate?

    /// 현재 셀이 보여주고 있는 `CellItem` 데이터.
    private var currentItem: CellItem?

    /// 컬렉션 뷰에 표시될 일자(`Day`) 데이터 배열.
    private var dayItems: [CellItem.Day] = []

    override func awakeFromNib() {
        super.awakeFromNib()

        setupLayout()
        setupCollectionView()
        layoutSubviews()
    }

    /// 컬렉션 뷰의 데이터 소스와 델리게이트를 설정하고, 셀 nib을 등록.
    func setupCollectionView() {
        scheduleListCollectionView.dataSource = self
        scheduleListCollectionView.delegate = self

        scheduleListCollectionView.register(TourListCollectionViewCell.nib, forCellWithReuseIdentifier: TourListCollectionViewCell.identifier)
    }

    func setupLayout() {
        self.contentView.layer.cornerRadius = 8
        self.contentView.clipsToBounds = true
        self.contentView.backgroundColor = .lightGray.withAlphaComponent(0.1)

        scheduleListCollectionView.backgroundColor = UIColor.clear
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top: 0, left: 0, bottom: 16, right: 0))
    }

    /// 주어진 `CellItem` 데이터로 셀의 내용을 구성.
    /// - Parameter item: 셀에 표시할 여행 정보.
    func configure(with item: CellItem) {
        self.currentItem = item

        titleLabel.text = item.title
        periodLabel.text = item.period

        // 현재 여행이 선택되었는지 여부에 따라 일자 컬렉션 뷰의 노출 상태를 조절.
        scheduleListCollectionViewHeightConstraint.constant = item.isSelected ? 90 : 0

        dayItems = item.days

        scheduleListCollectionView.reloadData()

        for (index, _) in dayItems.enumerated() {
            scheduleListCollectionView.selectItem(at: IndexPath(item: index, section: 0), animated: false, scrollPosition: [])
        }
    }
}

// MARK: - UICollectionViewDataSource
extension AddToScheduleTableViewCell: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dayItems.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TourListCollectionViewCell.identifier, for: indexPath) as? TourListCollectionViewCell else {
            return UICollectionViewCell()
        }

        let day = dayItems[indexPath.item]

        cell.configure(with: day)

        return cell
    }
}

// MARK: - UICollectionViewDelegate
extension AddToScheduleTableViewCell: UICollectionViewDelegate {

    /// 사용자가 특정 일자를 선택했을 때 호출.
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard var item = currentItem else { return }

        // 선택된 일자의 isSelected 상태를 true로 변경하고, 나머지는 false로 변경.
        for (index, _) in item.days.enumerated() {
            item.days[index].isSelected = index == indexPath.item
        }

        // 변경된 데이터를 델리게이트를 통해 상위 뷰 컨트롤러로 전달.
        delegate?.AddToScheduleTableViewCell(self, didUpdateItem: item)
    }

    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        guard var item = currentItem else { return }

        item.days[indexPath.item].isSelected = false

        delegate?.AddToScheduleTableViewCell(self, didUpdateItem: item)
    }
}
