//
//  RecommandCourseItemListTableViewCell.swift
//  SeoulMate
//
//  Created by JuHyeon Seong on 6/10/25.
//

import UIKit

class RecommandCourseItemListTableViewCell: UITableViewCell {
    @IBOutlet weak var indexIndicator: UILabel!

    @IBOutlet weak var contentWrapperView: UIView!
    @IBOutlet weak var wrapperStackView: UIStackView!

    @IBOutlet weak var cellImageView: UIImageView!

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var typeLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func prepareForReuse() {
    }
}
