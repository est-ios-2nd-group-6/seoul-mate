//
//  TourListCollectionViewCell.swift
//  SeoulMate
//
//  Created by JuHyeon Seong on 6/16/25.
//

import UIKit

/// 특정 여행의 '일자'를 표시하는 컬렉션 뷰 셀.
///
/// `AddToScheduleTableViewCell` 내에서 사용되어 사용자가 POI를 추가할 날짜를 선택할 수 있도록 함.
class TourListCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var wrapperView: UIView!

    @IBOutlet weak var dayIndexLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!

    static var nib: UINib {
        return "TourListCollectionViewCell".loadNib()
    }

    static var identifier: String {
        return "TourListCollectionViewCell"
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        wrapperView.layer.borderWidth = 1
        wrapperView.layer.borderColor = UIColor.black.cgColor

        wrapperView.layer.cornerRadius = wrapperView.frame.height / 2
    }

    /// 셀의 UI를 주어진 `Day` 데이터로 설정.
    /// - Parameter day: 셀에 표시할 일자 데이터.
    func configure(with day: CellItem.Day) {
        dayIndexLabel.text = day.dayText
        dateLabel.text = day.dateText

        wrapperView.backgroundColor = day.isSelected ? .main : .systemBackground
    }

    /// 셀의 선택 상태가 변경될 때 호출되어 배경색을 업데이트.
    override var isSelected: Bool {
        didSet {
            wrapperView.backgroundColor = isSelected ? .main : .systemBackground
        }
    }
}
