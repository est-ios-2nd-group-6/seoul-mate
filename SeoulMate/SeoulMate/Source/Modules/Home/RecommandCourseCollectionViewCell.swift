//
//  RecommandCourseCollectionViewCell.swift
//  SeoulMate
//
//  Created by JuHyeon Seong on 6/11/25.
//

import UIKit

/// 홈 화면의 추천 코스 목록을 구성하는 컬렉션 뷰 셀.
class RecommandCourseCollectionViewCell: UICollectionViewCell {

    /// 셀의 전체적인 외관을 감싸는 뷰. (스타일링 목적)
    @IBOutlet weak var wrapperView: UIView!

    /// 코스 썸네일 이미지 뷰.
    @IBOutlet weak var thumbnailImageView: UIImageView!

    /// 코스 제목 레이블.
    @IBOutlet weak var titleLabel: UILabel!
}
