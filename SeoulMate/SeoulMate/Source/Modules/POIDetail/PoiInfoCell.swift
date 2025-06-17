//
//  PoiInfoCell.swift
//  SeoulMate
//
//  Created by DEV on 6/14/25.
//

import UIKit

class PoiInfoCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var reviewNumberLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var placeImageView: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        placeImageView.layer.masksToBounds = true
        placeImageView.layer.cornerRadius = 20
    }
    
    override func prepareForReuse() {
        placeImageView.image = nil
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
