//
//  SettingTableViewCell.swift
//  SeoulMate
//
//  Created by 윤혜주 on 6/16/25.
//

import UIKit


/// `SettingTableViewCell`은 설정 화면의 각 행에 사용되는 커스텀 셀입니다.
/// 설정 항목의 텍스트를 표시합니다.
class SettingTableViewCell: UITableViewCell {

    // MARK: - 아울렛

    /// 설정 항목을 표시하는 레이블
    @IBOutlet weak var itemLabel: UILabel!

    // MARK: - 라이프사이클

    /// 셀이 메모리에 로드된 후 호출됩니다.
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    /// 셀의 선택 상태 변경 시 호출됩니다.
    /// - Parameters:
    ///   - selected: 셀의 선택 여부
    ///   - animated: 애니메이션 여부
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
