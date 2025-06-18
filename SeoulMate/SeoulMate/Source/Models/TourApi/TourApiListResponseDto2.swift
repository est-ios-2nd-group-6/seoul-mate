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
        var id:String
        var types:[String]
        var displayName:DisplayName
        var primaryTypeDisplayName:PrimaryTypeDisplayName?
        var photos:[Photo]
        var rating:Double?
        var location:Location
        var regularOpeningHours: RegularOpeningHours
    }
    struct Photo: Codable {
        var name: String
        var widthPx: Int
        var heightPx: Int
        var flagContentUri: String
        var googleMapsUri: String
    }
    struct DisplayName: Codable {
        var text: String
        var languageCode: String
    }
    struct PrimaryTypeDisplayName: Codable {
        var text: String
        var languageCode: String
    }
    struct Location: Codable {
        let latitude: Double
        let longitude: Double
    }
    struct RegularOpeningHours: Codable {
        var weekdayDescriptions:[String]
    }
}

struct TourAPIGoogleResponseShort: Codable {
    var id:String
    var formattedAddress:String
    var rating:Double?
    var displayName:DisplayName
    var photos:[Photo]
    var location:Location
    var weekdayDescriptions:[String]?
    struct DisplayName: Codable {
        var text: String
        var languageCode: String
    }
    struct Photo: Codable {
        var name:String
        var widthPx:Int
        var heightPx:Int
    }
    struct Location: Codable {
        let latitude: Double
        let longitude: Double
    }
}

struct TourNearybyAPIGoogleRequest: Codable {
    let includedTypes: [String]
    let maxResultCount: Int
    let locationRestriction: LocationRestriction
    
    struct LocationRestriction: Codable {
        let circle: Circle
    }
    
    struct Circle: Codable {
        let center: Center
        let radius: Int
    }
    
    struct Center: Codable {
        let latitude: Double
        let longitude: Double
    }
    
    init(latitude: Double, longitude: Double) {
        self.includedTypes = ["tourist_attraction","restaurant","locality","museum"]
        self.maxResultCount = 20
        self.locationRestriction = LocationRestriction(
            circle: Circle(
                center: Center(latitude: latitude, longitude: longitude),
                radius: 2000
            )
        )
    }
}

struct TourNearybyAPIGoogleResponse: Codable {
    let places:[Place]
    struct Place: Codable {
        let id:String
        let formattedAddress: String?
        let location: Location
        let types: [String]
        let rating:Double
        let displayName:DisplayName
        let primaryTypeDisplayName:PrimaryTypeDisplayName?
        let photos:[Photo]
        struct DisplayName: Codable {
            var text: String
            var languageCode: String
        }
        struct PrimaryTypeDisplayName: Codable {
            var text: String
            var languageCode: String
        }
        struct Photo: Codable {
            var name:String
            var widthPx:Int
            var heightPx:Int
        }
        struct Location: Codable {
            let latitude: Double
            let longitude: Double
        }
    }
}
