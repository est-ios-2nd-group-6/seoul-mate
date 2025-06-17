//
//  AddToScheduleTableViewCell.swift
//  SeoulMate
//
//  Created by JuHyeon Seong on 6/11/25.
//

import UIKit

protocol AddToScheduleTableViewCellDelegate: AnyObject {
    func AddToScheduleTableViewCell(_ cell: AddToScheduleTableViewCell, didUpdateItem item: CellItem)
}

class AddToScheduleTableViewCell: UITableViewCell {
    @IBOutlet weak var wrapperStackView: UIStackView!

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var periodLabel: UILabel!
    @IBOutlet weak var scheduleListCollectionView: UICollectionView!

    @IBOutlet weak var scheduleListCollectionViewHeightConstraint: NSLayoutConstraint!

    weak var delegate: AddToScheduleTableViewCellDelegate?

    private var currentItem: CellItem?

    private var dayItems: [CellItem.Day] = []

    override func awakeFromNib() {
        super.awakeFromNib()

        setupLayout()
        setupCollectionView()
        layoutSubviews()
    }

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

    func configure(with item: CellItem) {
        self.currentItem = item

        titleLabel.text = item.title
        periodLabel.text = item.period

        scheduleListCollectionViewHeightConstraint.constant = item.isSelected ? 90 : 0

        dayItems = item.days

        scheduleListCollectionView.reloadData()

        for (index, _) in dayItems.enumerated() {
            scheduleListCollectionView.selectItem(at: IndexPath(item: index, section: 0), animated: false, scrollPosition: [])
        }
    }
}

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

extension AddToScheduleTableViewCell: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard var item = currentItem else { return }

        for (index, _) in item.days.enumerated() {
            item.days[index].isSelected = index == indexPath.item
        }

        delegate?.AddToScheduleTableViewCell(self, didUpdateItem: item)
    }

    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        guard var item = currentItem else { return }

        item.days[indexPath.item].isSelected = false

        delegate?.AddToScheduleTableViewCell(self, didUpdateItem: item)
    }
}
