//
//  SearchResultTableViewCell.swift
//  SeoulMate
//
//  Created by DEV on 6/10/25.
//

import UIKit

class SearchResultTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var searchImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subTitleLabel: UILabel!
    weak var delegate: (any SearchViewControllerDelegate)?
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        searchImageView.image = nil
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    @IBAction func removeItemButton(_ sender: Any) {
        self.delegate?.didRemoveButtonTapped(cell: self)
    }
}
