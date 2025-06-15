//
//  TransitDetailTableViewCell.swift
//  SeoulMate
//
//  Created by JuHyeon Seong on 6/15/25.
//

import UIKit

class TransitDetailTableViewCell: UITableViewCell {

    @IBOutlet weak var circleView: UIView!
    @IBOutlet weak var transitLineView: UIView!

    @IBOutlet weak var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
}
