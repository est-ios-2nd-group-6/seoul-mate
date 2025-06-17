//
//  RouteOptionCollectionViewCell.swift
//  SeoulMate
//
//  Created by JuHyeon Seong on 6/12/25.
//

import UIKit

class RouteOptionCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var wrapperView: UIView!
    
    @IBOutlet weak var optionLabel: UILabel!
    @IBOutlet weak var estimatedTimeLabel: UILabel!
    @IBOutlet weak var totalDistance: UILabel!
    @IBOutlet weak var eTALabel: UILabel!

    var routeOption: RouteOption?
}
