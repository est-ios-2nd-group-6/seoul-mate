//
//  TransitDetailTableViewCell.swift
//  SeoulMate
//
//  Created by JuHyeon Seong on 6/17/25.
//

import UIKit

class TransitDetailTableViewCell: UITableViewCell {

    @IBOutlet weak var departureStackView: UIStackView!
    @IBOutlet weak var departureCircleView: UIView!
    @IBOutlet weak var departureTitleLabel: UILabel!

    @IBOutlet weak var segueLineView: UIView!
    @IBOutlet weak var descriptionLabel: UILabel!

    @IBOutlet weak var arrivalStackView: UIStackView!
    @IBOutlet weak var arrivalCircleView: UIView!
    @IBOutlet weak var arrivalTitleLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()

        makeCircle(departureCircleView)
        makeCircle(arrivalCircleView)
    }

    func makeCircle(_ view: UIView) {
//        view.layer.cornerRadius = view.frame.height / 2
        view.layer.borderColor = UIColor.label.cgColor
        view.layer.borderWidth = 2
    }

    override func prepareForReuse() {
        departureStackView.isHidden = true
        arrivalStackView.isHidden = true
    }
}
