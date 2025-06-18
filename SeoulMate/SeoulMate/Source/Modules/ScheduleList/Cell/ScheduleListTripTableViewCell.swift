//
//  ScheduleListTableViewCell.swift
//  SeoulMate
//
//  Created by 윤혜주 on 6/9/25.
//

import UIKit

/// 서울메이트 앱의 여행 일정(투어) 항목을 표시하는 테이블 뷰 셀입니다.
///
/// 투어의 대표 이미지, 이름, 날짜 범위, 장소 개수 등을 보여줍니다.
class ScheduleListTripTableViewCell: UITableViewCell {
    /// 투어 대표 이미지를 표시하는 이미지 뷰입니다. 둥근 모서리로 표시됩니다.
    @IBOutlet weak var tripImageView: UIImageView!

    /// 투어 이름을 표시하는 레이블입니다.
    @IBOutlet weak var tripNameLabel: UILabel!

    /// 투어 시작일과 종료일을 표시하는 레이블입니다.
    @IBOutlet weak var tripDateLabel: UILabel!

    /// 투어에 포함된 장소 개수를 표시하는 레이블입니다.
    @IBOutlet weak var placeCountLabel: UILabel!

    /// 셀이 nib 또는 스토리보드에서 로드된 후 호출됩니다.
    ///
    /// 이 메서드에서 `tripImageView`를 원형으로 만들고, 클립 및 콘텐츠 모드를 설정합니다.
    override func awakeFromNib() {
        super.awakeFromNib()

        // 이미지 뷰를 둥근 모서리로 설정
        tripImageView.layer.cornerRadius = tripImageView.frame.height / 2
        tripImageView.clipsToBounds = true
        tripImageView.contentMode = .scaleAspectFill
    }

    /// 셀이 선택 상태로 변경될 때 호출됩니다.
    ///
    /// - Parameters:
    ///   - selected: 셀이 선택되었으면 `true`, 그렇지 않으면 `false`.
    ///   - animated: 상태 변경 애니메이션 적용 여부.
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
