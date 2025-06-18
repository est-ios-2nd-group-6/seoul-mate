//
//  RecommandCourseItemListTableViewCell.swift
//  SeoulMate
//
//  Created by JuHyeon Seong on 6/10/25.
//

import UIKit

/// 추천 코스 상세 화면에서 각 장소 항목을 표시하기 위한 테이블 뷰 셀.
class RecommandCourseItemListTableViewCell: UITableViewCell {

    // MARK: - IBOutlet

    /// 코스 내 장소의 순번을 나타내는 레이블.
    @IBOutlet weak var indexIndicator: UILabel!

    /// 셀의 콘텐츠를 감싸는 Wrapper View
    @IBOutlet weak var contentWrapperView: UIView!

    /// 셀의 모든 UI 요소를 포함하는 Stack View
    @IBOutlet weak var wrapperStackView: UIStackView!

    /// 장소 thumbnail 표시 Image View
    @IBOutlet weak var cellImageView: UIImageView!

    /// 장소의 이름을 표시하는 label.
    @IBOutlet weak var titleLabel: UILabel!

    /// 장소의 유형(예: 관광지, 음식점)을 표시하는 label.
    @IBOutlet weak var typeLabel: UILabel!
}

