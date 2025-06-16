//
//  TourApiListResponseDto.swift
//  SeoulMate
//
//  Created by JuHyeon Seong on 6/9/25.
//

import Foundation

struct TourApiListItemHS: Codable {
    let firstimage, firstimage2: String
    let sigungucode, tel, title, zipcode: String

    enum CodingKeys: String, CodingKey {
        case firstimage, firstimage2
        case sigungucode, tel, title, zipcode
    }
}

struct TourApiListResponseDto2: Codable {
    struct Response: Codable {
        let header: Header
        let body: Body
    }

    struct Body: Codable {
        let numOfRows, pageNo, totalCount: Int
        let items: Items
    }

    struct Items: Codable {
        let item: [TourApiListItemHS]
    }

    let responseTime, resultCode, resultMsg: String?
    let response: Response
}

struct TourApiGoogleResponse: Codable {
    let places:[Place]
    
    struct Place: Codable {
        var types:[String]
        var displayName:DisplayName
        var primaryTypeDisplayName:PrimaryTypeDisplayName?
        var photos:[Photo]
        var rating:Double
    }
    struct Photo: Codable {
        var name: String
        var widthPx: Int
        var heightPx: Int
        var authorAttributions:[Author]
        var flagContentUri: String
        var googleMapsUri: String
    }
    struct Author: Codable {
        var displayName: String
        var uri: String
        var photoUri: String
    }
    struct DisplayName: Codable {
        var text: String
        var languageCode: String
    }
    struct PrimaryTypeDisplayName: Codable {
        var text: String
        var languageCode: String
    }
}
