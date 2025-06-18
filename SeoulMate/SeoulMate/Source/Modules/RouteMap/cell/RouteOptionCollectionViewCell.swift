//
//  RouteOptionCollectionViewCell.swift
//  SeoulMate
//
//  Created by JuHyeon Seong on 6/12/25.
//

import UIKit

/// 계산된 여러 경로 옵션(추천, 최단 등) 중 하나를 요약하여 보여주는 컬렉션 뷰 셀.
class RouteOptionCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var wrapperView: UIView!

    @IBOutlet weak var optionLabel: UILabel!
    @IBOutlet weak var estimatedTimeLabel: UILabel!
    @IBOutlet weak var totalDistance: UILabel!
    @IBOutlet weak var eTALabel: UILabel!

    var routeOption: RouteOption?
}
