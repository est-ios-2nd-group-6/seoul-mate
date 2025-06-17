//
//  ScheduleListTableViewCell.swift
//  SeoulMate
//
//  Created by 윤혜주 on 6/9/25.
//

import UIKit

class ScheduleListTripTableViewCell: UITableViewCell {
    @IBOutlet weak var tripImageView: UIImageView!
    @IBOutlet weak var tripNameLabel: UILabel!
    @IBOutlet weak var tripDateLabel: UILabel!
    @IBOutlet weak var placeCountLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        tripImageView.clipsToBounds = true
        tripImageView.contentMode = .scaleAspectFill
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        tripImageView.layer.cornerRadius = tripImageView.frame.height / 2
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
