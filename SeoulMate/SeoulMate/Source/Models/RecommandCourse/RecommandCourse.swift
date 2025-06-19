//
//  RecommandCourse.swift
//  SeoulMate
//
//  Created by JuHyeon Seong on 6/9/25.
//

import Foundation
import UIKit

struct RecommandCourse {
    let contentId: String
    let title: String
    let firstImageUrl: String
    var image: UIImage? = nil

    init(contentId: String, title: String, firstImageUrl: String, image: UIImage? = nil) {
        self.contentId = contentId
        self.title = title
        self.firstImageUrl = firstImageUrl
        self.image = image
    }

    init(courseItem: TourApiListItem) {
        self.contentId = courseItem.contentid
        self.title = courseItem.title
        self.firstImageUrl = courseItem.firstimage
    }
}
