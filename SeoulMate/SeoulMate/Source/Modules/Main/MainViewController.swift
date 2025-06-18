//
//  MainViewController.swift
//  SeoulMate
//
//  Created by JuHyeon Seong on 6/18/25.
//

import UIKit

/// 앱의 메인 화면을 구성하는 탭 바 컨트롤러.
class MainViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // 앱 실행 시 '홈' 을 기본 탭으로 설정
        self.selectedIndex = 1
    }
}
