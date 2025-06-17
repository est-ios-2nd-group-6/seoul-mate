//
//  RecommandCoursePlace.swift
//  SeoulMate
//
//  Created by JuHyeon Seong on 6/9/25.
//

import Foundation
import UIKit

enum PlaceType: String {
	case sightseeing = "12"
    case culture = "14"
    case festival = "15"
    case course = "25"
    case leports = "28"
    case accommodation = "32"
    case shopping = "38"
    case restaurant = "39"

    var name: String {
        switch self {
        case .sightseeing:
            return "관광지"
        case .culture:
            return "문화시설"
        case .festival:
            return "축제/공연/행사"
        case .course:
            return "여행 코스"
        case .leports:
            return "레포츠"
        case .accommodation:
            return "숙박"
        case .shopping:
            return "쇼핑"
        case .restaurant:
            return "음식점"
        }
    }
}

struct RecommandCoursePlace {
    let id: String
    let subnum: String
    let subContentId: String
    let typeId: String

    let name: String
    var description: String

    let imageUrl: String
    var image: UIImage? = nil

    var type: PlaceType?

    init(id: String, typeId: String, subnum: String, subContentId: String, name: String, description: String, imageUrl: String, image: UIImage? = nil) {
        self.id = id
        self.subnum = subnum
        self.subContentId = subContentId
        self.typeId = typeId
        self.name = name
        self.description = description
        self.imageUrl = imageUrl
        self.image = image
    }

    init(courseSubItem: TourAPIDetailInfoItem) {
        self.id = courseSubItem.contentid
        self.subnum = courseSubItem.subnum
        self.subContentId = courseSubItem.subcontentid
        self.typeId = courseSubItem.contenttypeid
        self.name = courseSubItem.subname
        self.description = courseSubItem.subdetailoverview
        self.imageUrl = courseSubItem.subdetailimg
    }
}
