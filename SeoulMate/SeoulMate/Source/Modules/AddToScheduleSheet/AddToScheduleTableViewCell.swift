//
//  AddToScheduleTableViewCell.swift
//  SeoulMate
//
//  Created by JuHyeon Seong on 6/11/25.
//

import UIKit

class AddToScheduleTableViewCell: UITableViewCell {
    @IBOutlet weak var wrapperStackView: UIStackView!

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var periodLabel: UILabel!
    @IBOutlet weak var scheduleListCollectionView: UICollectionView!

    var schedules: [Schedule] = []

    override func awakeFromNib() {
        super.awakeFromNib()

        setupLayout()
        layoutSubviews()
    }

    func setupLayout() {
        scheduleListCollectionView.dataSource = self

        scheduleListCollectionView.register(TourListCollectionViewCell.nib, forCellWithReuseIdentifier: TourListCollectionViewCell.identifier)

        scheduleListCollectionView.backgroundColor = UIColor.clear
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top: 0, left: 0, bottom: 16, right: 0))
    }

    func reloadCollectionView() {
        scheduleListCollectionView.reloadData()
    }
}

extension AddToScheduleTableViewCell: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return schedules.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TourListCollectionViewCell.identifier, for: indexPath) as? TourListCollectionViewCell else {
            return UICollectionViewCell()
        }

        let index = indexPath.item
        let schedule = schedules[index]

        cell.dayIndexLabel.text = "Day \(indexPath.item + 1)"
//        cell.dateLabel.text = schedule.date

		return cell
    }
}
