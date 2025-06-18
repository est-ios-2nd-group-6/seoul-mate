//
//  TagCellCollectionViewCell.swift
//  SeoulMate
//
//  Created by DEV on 6/9/25.
//

import UIKit

class TagCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var label: UILabel!
    weak var delegate:(any SearchViewControllerDelegate)?
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func setCell(text: String){
        self.label.text = text
        self.layer.backgroundColor = .init(red:240/255, green: 240/255, blue: 240/255, alpha: 0.6)
        self.layer.cornerRadius = 4
        self.layer.masksToBounds = true
    }
    
    @IBAction func deselectItem(_ sender: Any) {
        self.delegate?.didDeselectButtonTapped(cell: self)
    }
}
