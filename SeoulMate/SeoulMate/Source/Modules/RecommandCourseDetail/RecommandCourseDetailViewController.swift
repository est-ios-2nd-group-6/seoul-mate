//
//  RecommandCourseDetailViewController.swift
//  SeoulMate
//
//  Created by JuHyeon Seong on 6/9/25.
//

import UIKit

struct fetchGooglePlaceDataResponoseDto: Codable {
    struct Place: Codable {
        struct Location: Codable {
            let latitude: Double
            let longitude: Double
        }

        struct RegularOpeningHours: Codable {
            let weekdayDescriptions: [String]
        }

        struct Photo: Codable {
            var name: String
        }

        let id: String
        let location: Location
        let regularOpeningHours: RegularOpeningHours?
        var photos: [Photo]?
    }

    let places: [Place]
}

class RecommandCourseDetailViewController: UIViewController {
    @IBOutlet weak var thumbnailImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var courseListTableView: UITableView!

    @IBAction func back(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }

    @IBAction func addToSchedule(_ sender: Any) {
        Task {
            var pois: [POI] = []

            for rcmPlace in places {
                let poi = await fetchGooglePlaceData(
                    name: rcmPlace.name,
                    category: rcmPlace.description
                )

                if let poi {
                    pois.append(poi)
                }

                if !pois.isEmpty {
                    let sheet = AddToScheduleSheetViewController()

                    sheet.pois = pois
                    sheet.delegate = self

                    present(sheet, animated: true)
                }
            }
        }

    }

    var course: RecommandCourse?

    var places: [RecommandCoursePlace] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        self.tabBarController?.tabBar.isHidden = true

        let cell = UINib(nibName: "RecommandCourseItemListTableViewCell", bundle: nil)
        courseListTableView.register(cell, forCellReuseIdentifier: "RecommandCourseItemListTableViewCell")

        titleLabel.text = course?.title

        Task {
            if let url = course?.firstImageUrl {
                let image = await ImageManager.shared.getImage(url)

                thumbnailImageView.image = image
            }

            if let id = course?.contentId {
                let courseSubItems = await TourApiManager.shared.fetchRcmCourseDetail(id) ?? []

                for courseSubItem in courseSubItems {
                    let commonDetailInfo = await TourApiManager.shared.fetchCommonDetailInfo(courseSubItem.subcontentid)

                    var place = RecommandCoursePlace(courseSubItem: courseSubItem)

                    place.description = place.description
                        .replacingOccurrences(of: "&lt;", with: "<")
                        .replacingOccurrences(of: "&gt;", with: ">")
                        .replacing(/<br\s*\/>/, with: "\n")
                        .trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)

                    place.type = PlaceType.init(rawValue: commonDetailInfo?.contenttypeid ?? "12")

                    let image = await ImageManager.shared.getImage(courseSubItem.subdetailimg)

                    place.image = image

                    places.append(place)
                }

                self.courseListTableView.reloadData()
            }
        }
    }
}

extension RecommandCourseDetailViewController {
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            courseListTableView.reloadData()
        }
    }

    func fetchGooglePlaceData(name: String, category: String) async -> POI? {
        let baseUrl: String = "https://places.googleapis.com/v1/places:searchText"

        var queryItems: [URLQueryItem]

        queryItems = [
            URLQueryItem(name: "textQuery", value: name),
            URLQueryItem(name: "languageCode", value: "ko"),
            URLQueryItem(name: "pageSize", value: "1"),
        ]

        guard var url = URL(string: baseUrl) else {
            return nil
        }

        url.append(queryItems: queryItems)

        var request = URLRequest(url: url)

        guard let googleApiKey = Bundle.main.googleApiKey else {
            return nil
        }

        let fieldMasks: [String] = [
            "places.id",
            "places.location",
            "places.regularOpeningHours",
            "places.photos",
        ]

        request.httpMethod = "POST"

        request.addValue("application/json; charset=UTF-8", forHTTPHeaderField: "Content-Type")
        request.addValue("*/*", forHTTPHeaderField: "Aceept")
        request.addValue("gzip, deflate, br", forHTTPHeaderField: "Aceept-Encoding")
        request.addValue("keep-alive", forHTTPHeaderField: "Connection")

        request.setValue(googleApiKey, forHTTPHeaderField: "X-Goog-Api-Key")
        request.setValue(Bundle.main.bundleIdentifier, forHTTPHeaderField: "X-Ios-Bundle-Identifier")
        request.setValue(fieldMasks.joined(separator: ","), forHTTPHeaderField: "X-Goog-FieldMask")

        do {
            let session = URLSession(configuration: .ephemeral)

            let (data, urlResponse) = try await session.data(for: request)

            guard let httpResponse = urlResponse as? HTTPURLResponse else {
                return nil
            }

            guard 200...299 ~= httpResponse.statusCode else {
                return nil
            }

            let json = try JSONDecoder().decode(fetchGooglePlaceDataResponoseDto.self, from: data)

            let poi = POI(context: CoreDataManager.shared.context)

            let place = json.places[0]

            poi.name = name
            poi.category = category
            poi.latitude = place.location.latitude
            poi.longitude = place.location.longitude

            poi.openingHours = place.regularOpeningHours?.weekdayDescriptions.joined(separator: "\n")

            if let photoName = place.photos?[0].name {
                let imageURL = "https://places.googleapis.com/v1/\(photoName)/media?key=\(googleApiKey)"

                poi.imageURL = imageURL
            }

            poi.placeID = place.id

            return poi
        } catch {
            print("Fetcing is Failed!!", error, separator: "\n")

            return nil
        }
    }
}

extension RecommandCourseDetailViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return places.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "RecommandCourseItemListTableViewCell", for: indexPath) as? RecommandCourseItemListTableViewCell else {
            return UITableViewCell()
        }

        cell.cellImageView.isHidden = false

        let row = indexPath.row

        let subItem = places[indexPath.item]

        cell.contentWrapperView.layer.cornerRadius = 8

        if traitCollection.userInterfaceStyle == .light {
            cell.contentWrapperView.backgroundColor = .systemBackground
        } else {
            cell.contentWrapperView.backgroundColor = .lightGray.withAlphaComponent(0.1)
        }

        cell.contentWrapperView.layer.borderWidth = 1

        if traitCollection.userInterfaceStyle == .light {
            cell.contentWrapperView.layer.borderColor = UIColor.black.withAlphaComponent(0.1).cgColor
        } else {
            cell.contentWrapperView.layer.borderColor = UIColor.tertiaryLabel.withAlphaComponent(0.1).cgColor
        }

        cell.contentWrapperView.layer.shadowColor = UIColor.black.cgColor
        cell.contentWrapperView.layer.shadowOpacity = 0.2
        cell.contentWrapperView.layer.shadowRadius = 10
        cell.contentWrapperView.layer.shadowOffset = CGSize(width: 0, height: 0)

        cell.wrapperStackView.layer.cornerRadius = 8
        cell.wrapperStackView.clipsToBounds = true

        cell.indexIndicator.text = String(row + 1)
        cell.indexIndicator.layer.cornerRadius = 10
        cell.indexIndicator.clipsToBounds = true

        if let image = subItem.image {
            cell.cellImageView.image = image
        } else {
            cell.cellImageView.isHidden = true
            cell.titleLabel.topAnchor.constraint(equalTo: cell.wrapperStackView.topAnchor, constant: 12).isActive = true
        }

        cell.titleLabel.text = subItem.name

        cell.typeLabel.text = subItem.type?.name

        return cell
    }
}

extension RecommandCourseDetailViewController: AddToScheduleSheetViewControllerDelegate {
    func sheetViewControllerDidDismiss(_ viewController: AddToScheduleSheetViewController) {
        self.showInAppNotification(
            message: "일정에 성공적으로 추가했어요!",
            duration: 2
        )
    }
}
