//
//  RecommandCoursePlace.swift
//  SeoulMate
//
//  Created by JuHyeon Seong on 6/9/25.
//

import Foundation
import UIKit

struct RecommandCoursePlace {
    let id: String
    let typeId: String
    let subnum: String
    let subContentId: String

    let name: String
    var description: String

    let imageUrl: String
    var image: UIImage? = nil

    init(id: String, typeId: String, subnum: String, subContentId: String, name: String, description: String, imageUrl: String, image: UIImage? = nil) {
        self.id = id
        self.typeId = typeId
        self.subnum = subnum
        self.subContentId = subContentId
        self.name = name
        self.description = description
        self.imageUrl = imageUrl
        self.image = image
    }

    init(courseSubItem: TourAPIDetailInfoItem) {
        self.id = courseSubItem.contentid
        self.typeId = courseSubItem.contenttypeid
        self.subnum = courseSubItem.subnum
        self.subContentId = courseSubItem.subcontentid
        self.name = courseSubItem.subname
        self.description = courseSubItem.subdetailoverview
        self.imageUrl = courseSubItem.subdetailimg
    }

}
