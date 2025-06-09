//
//  TourApiListResponseDto.swift
//  SeoulMate
//
//  Created by JuHyeon Seong on 6/8/25.
//

import Foundation


struct TourAPIDetailInfoItem: Codable {
    let contentid, contenttypeid, subnum, subcontentid: String
    let subname, subdetailoverview: String
    let subdetailimg: String
    let subdetailalt: String
}

struct TourAPIDetailInfoResponseDto: Codable {
    struct Response: Codable {
        let header: Header
        let body: Body
    }

    struct Body: Codable {
        let numOfRows, pageNo, totalCount: Int
        let items: Items
    }

    struct Items: Codable {
        let item: [TourAPIDetailInfoItem]
    }

    let responseTime, resultCode, resultMsg: String?
    let response: Response
}
