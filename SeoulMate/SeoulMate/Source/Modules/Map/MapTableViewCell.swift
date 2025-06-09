//
//  MapTableViewCell.swift
//  SeoulMate
//
//  Created by 하재준 on 6/9/25.
//

import UIKit

class MapTableViewCell: UITableViewCell {
    @IBOutlet weak var numberView: UIView!
    @IBOutlet weak var numberLabel: UILabel!
    @IBOutlet weak var placeTitleLabel: UILabel!
    @IBOutlet weak var placeCategoryLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        numberView.clipsToBounds = true
        numberView.layer.cornerRadius = numberView.bounds.width / 2
        numberView.backgroundColor = .orange
        
        
        
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }

}
