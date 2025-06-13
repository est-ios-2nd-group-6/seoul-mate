//
//  DetailSheetViewController.swift
//  SeoulMate
//
//  Created by 하재준 on 6/13/25.
//

import UIKit

class DetailSheetViewController: UIViewController {
    @IBOutlet weak var placeNameLabel: UILabel!
    @IBOutlet weak var placeCategoryLabel: UILabel!
    @IBOutlet weak var openTimeLabel: UILabel!
    
    @IBAction func goToNavigate(_ sender: Any) {
    }
    
    var place: String = ""
    var placeCategory: String = ""
    var placeOpenTime: String = ""
    
    
    override func viewDidLoad() {
        placeNameLabel.text = place
        placeCategoryLabel.text = placeCategory
        openTimeLabel.text = "영업 시간: \(placeOpenTime)"
        super.viewDidLoad()
    }
    
}

