//
//  TransitDetailTableViewCell.swift
//  SeoulMate
//
//  Created by JuHyeon Seong on 6/17/25.
//

import UIKit

/// 대중교통 경로의 상세 구간(하나의 이동 단계)을 표시하는 테이블 뷰 셀.
///
/// 출발지, 도착지 정보와 함께 해당 구간의 이동 수단, 소요 시간 등을 나타냄.
class TransitDetailTableViewCell: UITableViewCell {

    @IBOutlet weak var departureStackView: UIStackView!
    @IBOutlet weak var departureCircleView: UIView!
    @IBOutlet weak var departureTitleLabel: UILabel!

    @IBOutlet weak var segueLineView: UIView!
    @IBOutlet weak var descriptionLabel: UILabel!

    @IBOutlet weak var arrivalStackView: UIStackView!
    @IBOutlet weak var arrivalCircleView: UIView!
    @IBOutlet weak var arrivalTitleLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        makeCircle(departureCircleView)
        makeCircle(arrivalCircleView)
    }

    func makeCircle(_ view: UIView) {
        view.layer.borderColor = UIColor.label.cgColor
        view.layer.borderWidth = 2
    }

    /// 셀이 재사용되기 전에 숨김 처리된 뷰들을 초기화.
    override func prepareForReuse() {
        departureStackView.isHidden = true
        arrivalStackView.isHidden = true
    }
}
