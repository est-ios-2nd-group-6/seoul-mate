//
//  RecommandCourseDetailViewController.swift
//  SeoulMate
//
//  Created by JuHyeon Seong on 6/9/25.
//

import UIKit

struct fetchGooglePlaceNameResponoseDto: Codable {
    struct Place: Codable {
        let name: String
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

            for place in places {
                let name = await fetchGooglePlaceName(textQuery: place.name)

                let poi = POI(context: CoreDataManager.shared.context)
                poi.name = place.name
                poi.placeID = name

                pois.append(poi)
            }

//            let tours = await CoreDataManager.shared.fetchToursAsync()

//            let pois = tours[0].pois?.allObjects as! [POI]

            if !pois.isEmpty {
                let sheet = AddToScheduleSheetViewController()

                sheet.pois = pois
                sheet.delegate = self

                present(sheet, animated: true)
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

    override func viewIsAppearing(_ animated: Bool) {
        super.viewIsAppearing(animated)

        thumbnailImageView.image = UIImage(named: "subdetailimg")
        titleLabel.text = course?.title
    }

}

extension RecommandCourseDetailViewController {
    func fetchGooglePlaceName(textQuery: String) async -> String? {
        let baseUrl: String = "https://places.googleapis.com/v1/places:searchText"

        var queryItems: [URLQueryItem]

        queryItems = [
            URLQueryItem(name: "textQuery", value: textQuery),
            URLQueryItem(name: "languageCode", value: "ko")
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
            "places.name",
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

            let json = try JSONDecoder().decode(fetchGooglePlaceNameResponoseDto.self, from: data)

            return json.places[0].name
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

        let row = indexPath.row

        let subItem = places[indexPath.item]

        cell.contentWrapperView.layer.cornerRadius = 8

        cell.contentWrapperView.layer.borderWidth = 1
        cell.contentWrapperView.layer.borderColor = UIColor.tertiaryLabel.withAlphaComponent(0.1).cgColor
        
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
            cell.cellImageView?.image = image
        } else {
            cell.cellImageView?.removeFromSuperview()
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
