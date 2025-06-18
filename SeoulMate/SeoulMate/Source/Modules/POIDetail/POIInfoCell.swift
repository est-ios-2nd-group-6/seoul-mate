//
//  PoiInfoCell.swift
//  SeoulMate
//
//  Created by DEV on 6/14/25.
//

import UIKit

class POIInfoCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var reviewNumberLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var placeImageView: UIImageView!
    
    weak var delegate:(any POIDetailViewControllerDelegate)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        placeImageView.layer.cornerRadius = 20
        placeImageView.layer.masksToBounds = true
    }
    
    override func prepareForReuse() {
        placeImageView.image = nil
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    @IBAction func addScheduleButton(_ sender: Any) {
        print(#line,"일정추가",sender)
        delegate?.didAddScheduleButtonTapped()
    }
    
    @IBAction func findRoutesButton(_ sender: Any) {
        delegate?.didFindRoutesButtonTapped()
    }
    
    @IBAction func shareButton(_ sender: Any) {
        delegate?.didShareButtonTapped()
    }
}
