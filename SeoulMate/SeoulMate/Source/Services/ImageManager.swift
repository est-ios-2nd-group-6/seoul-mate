//
//  ImageManager.swift
//  SeoulMate
//
//  Created by JuHyeon Seong on 6/9/25.
//

import Foundation
import UIKit

/// URL로부터 이미지를 비동기적으로 로드하는 싱글톤 클래스.
class ImageManager {
    static let shared = ImageManager()

    private init() { }

    /// URL로부터 `UIImage`를 비동기적으로 가져옴.
    /// - Parameter url: 이미지를 가져올 `URL` 객체.
    /// - Returns: 다운로드된 `UIImage` 객체. 실패 시 `nil` 반환.
    func getImage(_ url: URL) async -> UIImage? {
        var image: UIImage? = nil

        do {
            let (data, _) = try await URLSession.shared.data(from: url)

            image = UIImage(data: data)

            if image == nil {
                print("Generating UIImage from data is Failed!!")

                return nil
            }

            return image
        } catch {
            print(error)

            return nil
        }
    }

    /// URL 문자열로부터 `UIImage`를 비동기적으로 가져오는 편의 메서드.
    /// - Parameter url: 이미지를 가져올 URL `String`.
    /// - Returns: 다운로드된 `UIImage` 객체. 실패 시 `nil` 반환.
    func getImage(_ url: String) async -> UIImage? {
        let _url = URL(string: url)

        if let _url {
            return await getImage(_url)
        }

        return nil
    }

    /// 여러 URL로부터 `UIImage` 배열을 비동기적으로 가져옴.
    /// - Parameter urls: 이미지를 가져올 `URL` 객체 배열.
    /// - Returns: 다운로드된 `UIImage` 옵셔널 객체의 배열.
    func getImages(_ urls: [URL]) async -> [UIImage?] {
        var images: [UIImage?] = []

        for url in urls {
            let image = await getImage(url)

            images.append(image)
        }

        return images
    }

    /// 여러 URL 문자열로부터 `UIImage` 배열을 비동기적으로 가져옴.
    /// - Parameter urls: 이미지를 가져올 URL `String` 배열.
    /// - Returns: 다운로드된 `UIImage` 옵셔널 객체의 배열.
    func getImages(_ urls: [String]) async -> [UIImage?] {
        var _urls: [URL] = []

        for url in urls {
            let url = URL(string: url)

            if let url {
                _urls.append(url)
            }
        }

        return await getImages(_urls)
    }
}
