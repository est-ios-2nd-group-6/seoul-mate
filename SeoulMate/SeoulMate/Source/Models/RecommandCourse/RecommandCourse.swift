//
//  RecommandCourse.swift
//  SeoulMate
//
//  Created by JuHyeon Seong on 6/9/25.
//

import Foundation
import UIKit

struct RecommandCourse {
//    let contentId: String
//    let contentTypeId: String

    let title: String

//    let createdTime: Date
//    let modifiedTime: Date

    let firstImageUrl: String
    var image: UIImage? = nil

    init(contentId: String, contentTypeId: String, title: String, createdTime: Date, modifiedTime: Date, firstImageUrl: String, image: UIImage? = nil) {
//        self.contentId = contentId
//        self.contentTypeId = contentTypeId
        self.title = title
//        self.createdTime = createdTime
//        self.modifiedTime = modifiedTime
        self.firstImageUrl = firstImageUrl
        self.image = image
    }

    init(courseItem: TourApiListItem) {
//        self.contentId = courseItem.contentid
//        self.contentTypeId = courseItem.contenttypeid
        self.title = courseItem.title
//        self.createdTime = courseItem.createdtime
//        self.modifiedTime = courseItem.modifiedtime
        self.firstImageUrl = courseItem.firstimage
    }
}
