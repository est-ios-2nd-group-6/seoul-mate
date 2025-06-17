//
//  SearchViewFromMapTableViewCell.swift
//  SeoulMate
//
//  Created by DEV on 6/17/25.
//

import UIKit

class SearchViewFromMapTableViewCell: UITableViewCell {

    @IBOutlet weak var placeImageView: UIImageView!
    @IBOutlet weak var placeTitleLabel: UILabel!
    @IBOutlet weak var placeCategoryLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    @IBAction func selectButton(_ sender: UIButton) {
    }
    
}
