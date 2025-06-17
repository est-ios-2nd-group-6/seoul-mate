//
//  TransitDetailPointTableViewCell.swift
//  SeoulMate
//
//  Created by JuHyeon Seong on 6/17/25.
//

import UIKit

class TransitDetailTableViewCell: UITableViewCell {
    @IBOutlet weak var circleView: UIView!
    @IBOutlet weak var titleLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()

        circleView.layer.cornerRadius = circleView.frame.height / 2
        circleView.layer.borderColor = UIColor.label.cgColor
        circleView.layer.borderWidth = 2
    }
}
