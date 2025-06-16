//
//  TourListCollectionViewCell.swift
//  SeoulMate
//
//  Created by JuHyeon Seong on 6/16/25.
//

import UIKit

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
}
