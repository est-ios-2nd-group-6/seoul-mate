//
//  SearchResultTableViewCell.swift
//  SeoulMate
//
//  Created by DEV on 6/10/25.
//

import UIKit

class SearchResultTableViewCell: UITableViewCell {


    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subTitleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }

}
