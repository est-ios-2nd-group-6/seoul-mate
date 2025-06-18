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
    @IBOutlet weak var checkmarkButton: UIButton!
    weak var delegate:(any SearchPlaceViewControllerDelegate)?
    var isChecked:Bool = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        placeImageView.image = nil
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    @IBAction func selectButton(_ sender: UIButton) {
        delegate?.didPlaceScheduleAddTapped(cell: self)
        if isChecked {
            DispatchQueue.main.async {
                self.checkmarkButton.setImage(UIImage(systemName: "checkmark.square"), for: .normal)
            }
            isChecked = false
        } else {
            DispatchQueue.main.async {
                self.checkmarkButton.setImage(UIImage(systemName: "square"), for: .normal)
            }
            isChecked = true
        }
    }
    
}
