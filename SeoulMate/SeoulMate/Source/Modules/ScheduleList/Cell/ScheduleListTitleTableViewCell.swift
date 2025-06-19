//
//  ScheduleListTitleTableViewCell.swift
//  SeoulMate
//
//  Created by 윤혜주 on 6/9/25.
//

import UIKit

/// 서울메이트 앱의 일정 섹션 제목을 표시하는 테이블 뷰 셀입니다.
///
/// Interface Builder를 통해 연결된 `titleLabel`을 사용하여 섹션 제목을 보여줍니다.
class ScheduleListTitleTableViewCell: UITableViewCell {
    /// 일정 섹션의 제목을 표시하는 레이블입니다.
    @IBOutlet weak var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    /// 셀이 선택 상태로 변경될 때 호출됩니다.
     ///
     /// - Parameters:
     ///   - selected: 셀이 선택되었으면 `true`, 그렇지 않으면 `false`.
     ///   - animated: 애니메이션 적용 여부를 나타내는 `true` 또는 `false`.
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
