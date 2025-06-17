//
//  TransitDetailSegueTableViewCell.swift
//  SeoulMate
//
//  Created by JuHyeon Seong on 6/15/25.
//

import UIKit

class TransitDetailSegueTableViewCell: UITableViewCell {

    @IBOutlet weak var circleView: UIView!
    @IBOutlet weak var transitLineView: UIView!

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
}
