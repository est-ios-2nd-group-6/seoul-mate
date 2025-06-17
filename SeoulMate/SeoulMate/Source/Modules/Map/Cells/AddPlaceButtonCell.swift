//
//  AddPlaceButtonCell.swift
//  SeoulMate
//
//  Created by 하재준 on 6/10/25.
//

import UIKit

protocol AddPlaceButtonCellDelegate: AnyObject {
    func addPlace(_ cell: AddPlaceButtonCell)
    func goToRoute(_ cell: AddPlaceButtonCell)
}

class AddPlaceButtonCell: UITableViewCell {
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var routeButton: UIButton!
    
    weak var delegate: AddPlaceButtonCellDelegate?
    
    @IBAction func addPlaceAction(_ sender: Any) {
        delegate?.addPlace(self)
    }
    @IBAction func goToRouteAction(_ sender: Any) {
        delegate?.goToRoute(self)
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
