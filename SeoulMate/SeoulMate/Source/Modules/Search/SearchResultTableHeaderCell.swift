//
//  SearchResultTableHeaderCell.swift
//  SeoulMate
//
//  Created by DEV on 6/11/25.
//

import UIKit

class SearchResultTableHeaderCell: UITableViewCell {
    
    @IBOutlet weak var deleteAllButton: UIButton!
    weak var delegate: (any SearchViewControllerDelegate)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        deleteAllButton.addTarget(self, action: #selector(deleteAll), for: .touchUpInside)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    @objc func deleteAll() {
        delegate?.didButtonTapped(cell: self)
    }
    
}
