//
//  ImageManager.swift
//  SeoulMate
//
//  Created by JuHyeon Seong on 6/9/25.
//

import Foundation
import UIKit

class ImageManager {
    static let shared = ImageManager()

    private init() { }

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

    func getImage(_ url: String) async -> UIImage? {
        let _url = URL(string: url)

        if let _url {
            return await getImage(_url)
        }

        return nil
    }

    func getImages(_ urls: [URL]) async -> [UIImage?] {
        var images: [UIImage?] = []

        for url in urls {
            let image = await getImage(url)

            images.append(image)
        }

        return images
    }

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
