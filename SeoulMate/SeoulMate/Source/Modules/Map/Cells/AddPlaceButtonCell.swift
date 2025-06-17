//
//  AddPlaceButtonCell.swift
//  SeoulMate
//
//  Created by 하재준 on 6/10/25.
//

import UIKit

protocol AddPlaceButtonCellDelegate: AnyObject {
    func addPlace(_ cell: AddPlaceButtonCell)
}

class AddPlaceButtonCell: UITableViewCell {
    weak var delegate: AddPlaceButtonCellDelegate?
    
    @IBOutlet weak var addButton: UIButton!
    @IBAction func addPlaceAction(_ sender: Any) {
        delegate?.addPlace(self)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
