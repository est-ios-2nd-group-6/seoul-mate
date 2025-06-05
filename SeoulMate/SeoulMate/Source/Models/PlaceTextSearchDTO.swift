//
//  PlaceApiResponse.swift
//  planz
//
//  Created by JuHyeon Seong on 6/5/25.
//

/**
 {
   "name": string,
   "id": string,
   "displayName": {
     object (LocalizedText)
   },
   "types": [
     string
   ],
   "primaryType": string,
   "primaryTypeDisplayName": {
     object (LocalizedText)
   },
   "nationalPhoneNumber": string,
   "internationalPhoneNumber": string,
   "formattedAddress": string,
   "shortFormattedAddress": string,
   "postalAddress": {
     object (PostalAddress)
   },
   "addressComponents": [
     {
       object (AddressComponent)
     }
   ],
   "plusCode": {
     object (PlusCode)
   },
   "location": {
     object (LatLng)
   },
   "viewport": {
     object (Viewport)
   },
   "rating": number,
   "googleMapsUri": string,
   "websiteUri": string,
   "reviews": [
     {
       object (Review)
     }
   ],
   "regularOpeningHours": {
     object (OpeningHours)
   },
   "timeZone": {
     object (TimeZone)
   },
   "photos": [
     {
       object (Photo)
     }
   ],
   "adrFormatAddress": string,
   "businessStatus": enum (BusinessStatus),
   "priceLevel": enum (PriceLevel),
   "attributions": [
     {
       object (Attribution)
     }
   ],
   "iconMaskBaseUri": string,
   "iconBackgroundColor": string,
   "currentOpeningHours": {
     object (OpeningHours)
   },
   "currentSecondaryOpeningHours": [
     {
       object (OpeningHours)
     }
   ],
   "regularSecondaryOpeningHours": [
     {
       object (OpeningHours)
     }
   ],
   "editorialSummary": {
     object (LocalizedText)
   },
   "paymentOptions": {
     object (PaymentOptions)
   },
   "parkingOptions": {
     object (ParkingOptions)
   },
   "subDestinations": [
     {
       object (SubDestination)
     }
   ],
   "fuelOptions": {
     object (FuelOptions)
   },
   "evChargeOptions": {
     object (EVChargeOptions)
   },
   "generativeSummary": {
     object (GenerativeSummary)
   },
   "containingPlaces": [
     {
       object (ContainingPlace)
     }
   ],
   "addressDescriptor": {
     object (AddressDescriptor)
   },
   "googleMapsLinks": {
     object (GoogleMapsLinks)
   },
   "priceRange": {
     object (PriceRange)
   },
   "reviewSummary": {
     object (ReviewSummary)
   },
   "evChargeAmenitySummary": {
     object (EvChargeAmenitySummary)
   },
   "neighborhoodSummary": {
     object (NeighborhoodSummary)
   },
   "utcOffsetMinutes": integer,
   "userRatingCount": integer,
   "takeout": boolean,
   "delivery": boolean,
   "dineIn": boolean,
   "curbsidePickup": boolean,
   "reservable": boolean,
   "servesBreakfast": boolean,
   "servesLunch": boolean,
   "servesDinner": boolean,
   "servesBeer": boolean,
   "servesWine": boolean,
   "servesBrunch": boolean,
   "servesVegetarianFood": boolean,
   "outdoorSeating": boolean,
   "liveMusic": boolean,
   "menuForChildren": boolean,
   "servesCocktails": boolean,
   "servesDessert": boolean,
   "servesCoffee": boolean,
   "goodForChildren": boolean,
   "allowsDogs": boolean,
   "restroom": boolean,
   "goodForGroups": boolean,
   "goodForWatchingSports": boolean,
   "accessibilityOptions": {
     object (AccessibilityOptions)
   },
   "pureServiceAreaBusiness": boolean
 }
 */

import Foundation

// MARK: - Welcome
struct PlaceTextSearchDTO: Codable {
    let name, id: String
    let types: [String]
    let nationalPhoneNumber, internationalPhoneNumber, formattedAddress: String
    let addressComponents: [AddressComponent]
    let plusCode: PlusCode
    let location: Location
    let rating: Int
    let googleMapsURI: String
    let regularOpeningHours: OpeningHours
    let businessStatus, priceLevel: String
    let userRatingCount: Int
    let iconMaskBaseURI: String
    let iconBackgroundColor: String
    let displayName, primaryTypeDisplayName: DisplayName
    let takeout, delivery, dineIn, servesBreakfast: Bool
    let servesLunch, servesDinner, servesBeer, servesWine: Bool
    let servesBrunch: Bool
    let currentOpeningHours: OpeningHours
    let primaryType, shortFormattedAddress: String
    let reviews: [Review]
    let photos: [Photo]
    let allowsDogs, restroom: Bool
    let goodForGroups: Bool
    let paymentOptions: PaymentOptions
    let parkingOptions: ParkingOptions
    let accessibilityOptions: AccessibilityOptions
    let addressDescriptor: AddressDescriptor
    let googleMapsLinks: GoogleMapsLinks
    let priceRange: PriceRange
    let timeZone: TimeZone
    let postalAddress: PostalAddress

    enum CodingKeys: String, CodingKey {
        case name, id, types, nationalPhoneNumber, internationalPhoneNumber, formattedAddress, addressComponents, plusCode, location, rating
        case googleMapsURI = "googleMapsUri"
        case regularOpeningHours, businessStatus, priceLevel, userRatingCount
        case iconMaskBaseURI = "iconMaskBaseUri"
        case iconBackgroundColor, displayName, primaryTypeDisplayName, takeout, delivery, dineIn, servesBreakfast, servesLunch, servesDinner, servesBeer, servesWine, servesBrunch, currentOpeningHours, primaryType, shortFormattedAddress, reviews, photos, allowsDogs, restroom, goodForGroups, paymentOptions, parkingOptions, accessibilityOptions, addressDescriptor, googleMapsLinks, priceRange, timeZone, postalAddress
    }
}

// MARK: - AccessibilityOptions
struct AccessibilityOptions: Codable {
    let wheelchairAccessibleParking, wheelchairAccessibleEntrance, wheelchairAccessibleSeating: Bool
}

// MARK: - AddressComponent
struct AddressComponent: Codable {
    let longText, shortText: String
    let types: [String]
    let languageCode: LanguageCode
}

enum LanguageCode: String, Codable {
    case ko = "ko"
    case koKR = "ko-KR"
}

// MARK: - AddressDescriptor
struct AddressDescriptor: Codable {
    let landmarks: [Landmark]
    let areas: [Area]
}

// MARK: - Area
struct Area: Codable {
    let name, placeID: String
    let displayName: DisplayName
    let containment: String

    enum CodingKeys: String, CodingKey {
        case name
        case placeID = "placeId"
        case displayName, containment
    }
}

// MARK: - DisplayName
struct DisplayName: Codable {
    let text: String
    let languageCode: LanguageCode
}

// MARK: - Landmark
struct Landmark: Codable {
    let name, placeID: String
    let displayName: DisplayName
    let types: [String]
    let straightLineDistanceMeters: Double

    enum CodingKeys: String, CodingKey {
        case name
        case placeID = "placeId"
        case displayName, types, straightLineDistanceMeters
    }
}

// MARK: - OpeningHours
struct OpeningHours: Codable {
    let openNow: Bool
    let periods: [Period]
    let weekdayDescriptions: [String]
    let nextCloseTime: Date
}

// MARK: - Period
struct Period: Codable {
    let periodOpen, close: Close

    enum CodingKeys: String, CodingKey {
        case periodOpen = "open"
        case close
    }
}

// MARK: - Close
struct Close: Codable {
    let day, hour, minute: Int
    let date: DateClass?
}

// MARK: - DateClass
struct DateClass: Codable {
    let year, month, day: Int
}

// MARK: - GoogleMapsLinks
struct GoogleMapsLinks: Codable {
    let directionsURI, placeURI, writeAReviewURI, reviewsURI: String
    let photosURI: String

    enum CodingKeys: String, CodingKey {
        case directionsURI = "directionsUri"
        case placeURI = "placeUri"
        case writeAReviewURI = "writeAReviewUri"
        case reviewsURI = "reviewsUri"
        case photosURI = "photosUri"
    }
}

// MARK: - Location
struct Location: Codable {
    let latitude, longitude: Double
}

// MARK: - ParkingOptions
struct ParkingOptions: Codable {
    let freeParkingLot, freeStreetParking: Bool
}

// MARK: - PaymentOptions
struct PaymentOptions: Codable {
    let acceptsCreditCards, acceptsCashOnly: Bool
}

// MARK: - Photo
struct Photo: Codable {
    let name: String
    let widthPx, heightPx: Int
    let authorAttributions: [AuthorAttribution]
    let flagContentURI, googleMapsURI: String

    enum CodingKeys: String, CodingKey {
        case name, widthPx, heightPx, authorAttributions
        case flagContentURI = "flagContentUri"
        case googleMapsURI = "googleMapsUri"
    }
}

// MARK: - AuthorAttribution
struct AuthorAttribution: Codable {
    let displayName: String
    let uri, photoURI: String

    enum CodingKeys: String, CodingKey {
        case displayName, uri
        case photoURI = "photoUri"
    }
}

// MARK: - PlusCode
struct PlusCode: Codable {
    let globalCode, compoundCode: String
}

// MARK: - PostalAddress
struct PostalAddress: Codable {
    let regionCode: String
    let languageCode: LanguageCode
    let administrativeArea: String
    let addressLines: [String]
}

// MARK: - PriceRange
struct PriceRange: Codable {
    let startPrice, endPrice: Price
}

// MARK: - Price
struct Price: Codable {
    let currencyCode, units: String
}

// MARK: - Review
struct Review: Codable {
    let name, relativePublishTimeDescription: String
    let rating: Int
    let text, originalText: DisplayName
    let authorAttribution: AuthorAttribution
    let publishTime: String
    let flagContentURI, googleMapsURI: String

    enum CodingKeys: String, CodingKey {
        case name, relativePublishTimeDescription, rating, text, originalText, authorAttribution, publishTime
        case flagContentURI = "flagContentUri"
        case googleMapsURI = "googleMapsUri"
    }
}

// MARK: - TimeZone
struct TimeZone: Codable {
    let id: String
}

