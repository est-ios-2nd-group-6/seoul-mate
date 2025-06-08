//
//  TourApiAreaBasedListResponseDto.swift
//  SeoulMate
//
//  Created by JuHyeon Seong on 6/8/25.
//

import Foundation

// MARK: - Response
struct Response: Codable {
    let header: Header
    let body: Body
}

// MARK: - Header
struct Header: Codable {
    let resultCode, resultMsg: String
}

// MARK: - Body
struct Body: Codable {
    let items: Items
    let numOfRows, pageNo, totalCount: Int
}

// MARK: - Items
struct Items: Codable {
    let item: [Item]
}

// MARK: - TourApiAreaBasedListResponseDto
struct TourApiAreaBasedListResponseDto: Codable {
    let responseTime, resultCode, resultMsg: String?
    let response: Response
}

// MARK: - TourAPIDetailInfoResponseDto
struct TourAPIDetailInfoResponseDto: Codable {
    let responseTime, resultCode, resultMsg: String?
    let response: Response
}


// MARK: - Item
struct Item: Codable {
    let addr1, addr2, areacode: String?
    let cat1: Cat1?
    let cat2: Cat2?
    let cat3: Cat3?
    let contentid, contenttypeid, createdtime: String?
    let firstimage, firstimage2: String?
    let cpyrhtDivCD: CpyrhtDivCD?
    let mapx, mapy, mlevel, modifiedtime: String?
    let sigungucode, tel, title, zipcode: String?
    let lDongRegnCD, lDongSignguCD: String?
    let lclsSystm1: Cat1?
    let lclsSystm2: Cat2?
    let lclsSystm3: Cat3?

    // DeailtInfo
    let subnum, subcontentid: String?
    let subname, subdetailoverview: String?
    let subdetailimg: String?
    let subdetailalt: String?

    enum CodingKeys: String, CodingKey {
        case addr1, addr2, areacode, cat1, cat2, cat3, contentid, contenttypeid, createdtime, firstimage, firstimage2
        case cpyrhtDivCD = "cpyrhtDivCd"
        case mapx, mapy, mlevel, modifiedtime, sigungucode, tel, title, zipcode
        case lDongRegnCD = "lDongRegnCd"
        case lDongSignguCD = "lDongSignguCd"
        case lclsSystm1, lclsSystm2, lclsSystm3
        case subnum, subcontentid, subname, subdetailoverview, subdetailimg, subdetailalt
    }
}

enum Cat1: String, Codable {
    case c01 = "C01"
}

enum Cat2: String, Codable {
    case c0112 = "C0112"
    case c0113 = "C0113"
    case c0114 = "C0114"
    case c0115 = "C0115"
    case c0117 = "C0117"
}

enum Cat3: String, Codable {
    case c01120001 = "C01120001"
    case c01130001 = "C01130001"
    case c01140001 = "C01140001"
    case c01150001 = "C01150001"
    case c01170001 = "C01170001"
}

enum CpyrhtDivCD: String, Codable {
    case empty = ""
    case type3 = "Type3"
}

