//
//  RouteInfoTableViewCell.swift
//  SeoulMate
//
//  Created by JuHyeon Seong on 6/14/25.
//

import UIKit

/// 경로의 출발지, 경유지, 도착지 정보를 간단히 표시하는 테이블 뷰 셀.
class RouteInfoTableViewCell: UITableViewCell {

    @IBOutlet weak var cellImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
    }
}
