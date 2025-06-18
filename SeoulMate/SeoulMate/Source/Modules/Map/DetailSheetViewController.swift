//
//  DetailSheetViewController.swift
//  SeoulMate
//
//  Created by 하재준 on 6/13/25.
//

import UIKit
protocol DetailSheetDelegate: AnyObject {
    func detailSheetDidTapNavigate(_ sheet: DetailSheetViewController)
}

class DetailSheetViewController: UIViewController {
    @IBOutlet weak var placeNameLabel: UILabel!
    @IBOutlet weak var placeCategoryLabel: UILabel!
    @IBOutlet weak var openTimeLabel: UILabel!
    
    @IBAction func goToNavigate(_ sender: Any) {

    }
    
    @IBAction func goToDetail(_ sender: Any) {
        delegate?.detailSheetDidTapNavigate(self)
        dismiss(animated: true, completion: nil)

//        let detailStoryboard = UIStoryboard(name: "POIDetail", bundle: nil)
//        
//        guard let poiDetailVC = detailStoryboard
//                .instantiateViewController(withIdentifier: "POIDetail")
//                as? PoiDetailViewController else {
//            return
//        }
//        
//        navigationController?.pushViewController(poiDetailVC, animated: true)
    }
    
    var place: String = ""
    var placeCategory: String = ""
    var placeOpenTime: String = ""
    weak var delegate: DetailSheetDelegate?

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        placeNameLabel.text = place
        placeCategoryLabel.text = placeCategory
        openTimeLabel.text = "영업 시간: \(placeOpenTime)"
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        if segue.identifier == "POIDetail",
           let vc = segue.destination as? POIDetailViewController {
                
        }
        
    }
    
}

