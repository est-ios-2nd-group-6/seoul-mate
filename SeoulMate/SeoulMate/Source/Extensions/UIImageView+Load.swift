//
//  UIImageView+Load.swift
//  SeoulMate
//
//  Created by 윤혜주 on 6/13/25.
//

import Foundation
import UIKit

extension UIImageView {
    /// URL로부터 이미지를 비동기 로드하고 설정합니다.
    ///
    /// - Parameters:
    ///   - url: 이미지를 가져올 `URL` 객체
    ///   - completion: 이미지가 설정된 후 실행할 선택적 클로저
    ///
    /// 이 메서드는 백그라운드 스레드에서 네트워크 요청을 수행하고,
    /// 로드가 완료되면 메인 스레드에서 `self.image`에 할당한 뒤
    /// `completion`을 호출합니다.
    func load(from url: URL, completion: (() -> Void)? = nil) {
        DispatchQueue.global().async {
            if let data = try? Data(contentsOf: url),
               let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    self.image = image
                    completion?()
                }
            } else {
                DispatchQueue.main.async {
                    // 이미지 로드 실패 시에도 completion 호출
                    completion?()
                }
            }
        }
    }
}
