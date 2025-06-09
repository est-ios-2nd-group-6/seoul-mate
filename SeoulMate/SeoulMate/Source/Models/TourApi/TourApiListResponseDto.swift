//
//  TourApiListResponseDto.swift
//  SeoulMate
//
//  Created by JuHyeon Seong on 6/9/25.
//

import Foundation

struct TourApiListItem: Codable {
    let addr1, addr2, areacode: String
    let cat1: Cat1
    let cat2: Cat2
    let cat3: Cat3
    let contentid, contenttypeid, createdtime: String
    let firstimage, firstimage2: String
    let cpyrhtDivCD: CpyrhtDivCD
    let mapx, mapy, mlevel, modifiedtime: String
    let sigungucode, tel, title, zipcode: String
    let lDongRegnCD, lDongSignguCD: String
    let lclsSystm1: Cat1
    let lclsSystm2: Cat2
    let lclsSystm3: Cat3

    enum CodingKeys: String, CodingKey {
        case addr1, addr2, areacode, cat1, cat2, cat3, contentid, contenttypeid, createdtime, firstimage, firstimage2
        case cpyrhtDivCD = "cpyrhtDivCd"
        case mapx, mapy, mlevel, modifiedtime, sigungucode, tel, title, zipcode
        case lDongRegnCD = "lDongRegnCd"
        case lDongSignguCD = "lDongSignguCd"
        case lclsSystm1, lclsSystm2, lclsSystm3
    }
}

struct TourApiListResponseDto: Codable {
    struct Response: Codable {
        let header: Header
        let body: Body
    }

    struct Body: Codable {
        let numOfRows, pageNo, totalCount: Int
        let items: Items
    }

    struct Items: Codable {
        let item: [TourApiListItem]
    }

    let responseTime, resultCode, resultMsg: String?
    let response: Response
}
