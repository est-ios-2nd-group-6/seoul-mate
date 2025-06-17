//
//  CoreData+PlaceTextSearchDTO.swift
//  SeoulMate
//
//  Created by 윤혜주 on 6/16/25.
//

import Foundation
import CoreData

extension CoreDataManager {
    func savePlaceDTO(for tour: Tour, placeDTOs: [PlaceTextSearchDTO]) {
        context.perform {
            let schedule = Schedule(context: self.context)
            schedule.id = UUID()
            schedule.date = tour.startDate
            schedule.tour = tour
            tour.addToDays(schedule)

            for dto in placeDTOs {
                let poi = POI(context: self.context)
                poi.id = UUID()
                poi.name = dto.displayName.text
                poi.placeID = dto.id
                poi.latitude = dto.location.latitude
                poi.longitude = dto.location.longitude
                poi.category = dto.primaryType.isEmpty ? (dto.types.first ?? "") : dto.primaryType
                poi.openingHours = dto.regularOpeningHours.weekdayDescriptions.joined(separator: "\n")
                if let firstPhoto = dto.photos.first {
                    poi.imageURL = firstPhoto.googleMapsURI
                }

                poi.schedule = schedule
                poi.tour = tour
            }
            self.saveContext()
        }
    }
}
