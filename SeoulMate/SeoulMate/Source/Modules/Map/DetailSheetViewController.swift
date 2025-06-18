//
//  DetailSheetViewController.swift
//  SeoulMate
//
//  Created by 하재준 on 6/13/25.
//

import UIKit
protocol DetailSheetDelegate: AnyObject {
    func detailSheetGoToDetail(_ sheet: DetailSheetViewController)
    func detailSheetGoToRoute(_ sheet: DetailSheetViewController, didRequestRouteFor pois: [POI])

}

class DetailSheetViewController: UIViewController {
    @IBOutlet weak var placeNameLabel: UILabel!
    @IBOutlet weak var placeCategoryLabel: UILabel!
    @IBOutlet weak var openTimeLabel: UILabel!
    
    @IBAction func goToRoute(_ sender: Any) {
        dismiss(animated: true) { [weak self] in
            guard let self = self else { return }
            self.delegate?.detailSheetGoToRoute(self, didRequestRouteFor: self.pois)
        }
    }
    
    @IBAction func goToDetail(_ sender: Any) {
        dismiss(animated: true) { [weak self] in
            guard let self = self else { return }
            self.delegate?.detailSheetGoToDetail(self)
}
    }
    
    var pois: [POI] = []
    var selectedRow: Int = 0
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
            
        } else if segue.identifier == "RouteMap",
                  let vc = segue.destination as? RouteMapViewController {
//            vc.pois = self.pois
        }
    }
    
}



