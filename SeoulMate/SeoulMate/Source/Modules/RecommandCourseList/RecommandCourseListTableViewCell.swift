//
//  RecommandCourseListTableViewCell.swift
//  SeoulMate
//
//  Created by JuHyeon Seong on 6/9/25.
//

import UIKit

/// 추천 코스 목록의 각 항목을 표시하는 테이블 뷰 셀.
class RecommandCourseListTableViewCell: UITableViewCell {

    /// 코스 썸네일 이미지 뷰.
    @IBOutlet weak var listImageView: UIImageView!

    /// 코스 제목 레이블.
    @IBOutlet weak var titleLabel: UILabel!
}
