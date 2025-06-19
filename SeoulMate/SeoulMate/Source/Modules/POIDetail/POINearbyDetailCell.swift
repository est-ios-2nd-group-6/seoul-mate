//
//  POINearbyDetailCell.swift
//  SeoulMate
//
//  Created by DEV on 6/16/25.
//

import UIKit

class POINearbyDetailCell: UITableViewCell {

    @IBOutlet weak var locationImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var ratingCountLabel: UILabel!
    @IBOutlet weak var startStack: UIStackView!
    
    var placeRating: Double = 0.0 {
        didSet {
            drawStar()
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        locationImageView.image = nil
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func drawStar(){
        let fullStars = Int(placeRating)
        let totalStars = 5
        for i in 1...totalStars {
            if let starImageView = startStack.viewWithTag(i) as? UIImageView {
                if i <= fullStars {
                    starImageView.image = UIImage(named: "star2")
                } else {
                    starImageView.image = UIImage(named: "star")
                }
            }
        }
        
    }

}
