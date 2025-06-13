//
//  TourApiDetailCommonResponseDTO.swift
//  SeoulMate
//
//  Created by JuHyeon Seong on 6/10/25.
//

import Foundation

struct TourApiCommonDetailInfoItem: Codable {
    let contentid, contenttypeid, title, createdtime: String
    let modifiedtime, tel, telname, homepage: String
    let firstimage, firstimage2, cpyrhtDivCD, areacode: String
    let sigungucode, lDongRegnCD, lDongSignguCD, lclsSystm1: String
    let lclsSystm2, lclsSystm3, cat1, cat2: String
    let cat3, addr1, addr2, zipcode: String
    let mapx, mapy, mlevel, overview: String

    enum CodingKeys: String, CodingKey {
        case contentid, contenttypeid, title, createdtime, modifiedtime, tel, telname, homepage, firstimage, firstimage2
        case cpyrhtDivCD = "cpyrhtDivCd"
        case areacode, sigungucode
        case lDongRegnCD = "lDongRegnCd"
        case lDongSignguCD = "lDongSignguCd"
        case lclsSystm1, lclsSystm2, lclsSystm3, cat1, cat2, cat3, addr1, addr2, zipcode, mapx, mapy, mlevel, overview
    }
}

struct TourApiDetailCommonResponseDto: Codable {
    struct Response: Codable {
        let header: Header
        let body: Body
    }

    struct Body: Codable {
        let items: Items
        let numOfRows, pageNo, totalCount: Int
    }

    struct Items: Codable {
        let item: [TourApiCommonDetailInfoItem]
    }

    let responseTime, resultCode, resultMsg: String?
    let response: Response
}
