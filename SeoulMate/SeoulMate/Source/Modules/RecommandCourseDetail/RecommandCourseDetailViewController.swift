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


/// 선택된 추천 코스의 상세 정보를 표시하는 뷰 컨트롤러.
///
/// 코스 내 장소 목록을 보여주고, 일괄적으로 일정에 추가하는 기능을 제공.
class RecommandCourseDetailViewController: UIViewController {

    // MARK: - IBOutlet
    @IBOutlet weak var thumbnailImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var courseListTableView: UITableView!

    // MARK: - IBAction
    @IBAction func back(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }

    /// 현재 코스의 모든 장소를 사용자의 기존 일정에 추가.
    ///
    /// 각 장소의 상세 정보를 Google Places API로 추가 조회한 후, `AddToScheduleSheet`을 띄움.
    @IBAction func addToSchedule(_ sender: Any) {
        Task {
            var pois: [POI] = []

            for rcmPlace in places {
                // Google Places API를 통해 장소 이름으로 POI 상세 정보 비동기 조회.
                let poi = await fetchGooglePlaceData(
                    name: rcmPlace.name,
                    category: rcmPlace.description
                )

                if let poi {
                    pois.append(poi)
                }

                // 조회된 POI가 있을 경우, 일정 추가 시트를 표시.
                if !pois.isEmpty {
                    let sheet = AddToScheduleSheetViewController()

                    sheet.pois = pois
                    sheet.delegate = self

                    present(sheet, animated: true)
                }
            }
        }
    }

    // MARK: - Properties

    /// 이전 화면에서 전달받은 추천 코스 정보.
    var course: RecommandCourse?

    /// API를 통해 조회한 코스 내 장소 목록.
    var places: [RecommandCoursePlace] = []

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tabBarController?.tabBar.isHidden = true

        let cell = UINib(nibName: "RecommandCourseItemListTableViewCell", bundle: nil)
        courseListTableView.register(cell, forCellReuseIdentifier: "RecommandCourseItemListTableViewCell")

        titleLabel.text = course?.title

        Task {
            // 코스 썸네일 이미지 비동기 로드.
            if let url = course?.firstImageUrl {
                let image = await ImageManager.shared.getImage(url)
                thumbnailImageView.image = image
            }

            // 코스 ID를 이용해 코스에 포함된 장소 목록(sub items) 비동기 조회.
            if let id = course?.contentId {
                let courseSubItems = await TourApiManager.shared.fetchRcmCourseDetail(id) ?? []

                for courseSubItem in courseSubItems {
                    // 각 장소의 공통 정보(카테고리 등) 추가 조회.
                    let commonDetailInfo = await TourApiManager.shared.fetchCommonDetailInfo(courseSubItem.subcontentid)

                    var place = RecommandCoursePlace(courseSubItem: courseSubItem)

                    // HTML 태그 제거 및 문자열 정리.
                    place.description = place.description
                        .replacingOccurrences(of: "&lt;", with: "<")
                        .replacingOccurrences(of: "&gt;", with: ">")
                        .replacing(/<br\s*\/>/, with: "\n")
                        .trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)

                    place.type = PlaceType.init(rawValue: commonDetailInfo?.contenttypeid ?? "12")

                    // 각 장소 이미지 비동기 로드.
                    let image = await ImageManager.shared.getImage(courseSubItem.subdetailimg)
                    place.image = image

                    places.append(place)
                }

                // 모든 데이터 로드가 완료되면 테이블 뷰 리로드.
                self.courseListTableView.reloadData()
            }
        }
    }
}

// MARK: - Private Methods
extension RecommandCourseDetailViewController {

    /// 다크/라이트 모드 변경 시 테이블 뷰 UI를 갱신.
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            courseListTableView.reloadData()
        }
    }

    /// Google Places API를 호출하여 장소 정보를 조회하고 `POI` 객체로 변환.
    /// - Parameters:
    ///   - name: 검색할 장소 이름.
    ///   - category: 장소의 카테고리 정보.
    /// - Returns: 변환된 `POI` 객체 (실패 시 `nil`).
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

        request.setValue("application/json; charset=UTF-8", forHTTPHeaderField: "Content-Type")
        request.setValue("*/*", forHTTPHeaderField: "Aceept")
        request.setValue("gzip, deflate, br", forHTTPHeaderField: "Aceept-Encoding")
        request.setValue("keep-alive", forHTTPHeaderField: "Connection")

        request.setValue(googleApiKey, forHTTPHeaderField: "X-Goog-Api-Key")
        request.setValue(Bundle.main.bundleIdentifier, forHTTPHeaderField: "X-Ios-Bundle-Identifier")
        request.setValue(fieldMasks.joined(separator: ","), forHTTPHeaderField: "X-Goog-FieldMask")

        do {
            let (data, _) = try await URLSession(configuration: .ephemeral).data(for: request)
            let json = try JSONDecoder().decode(fetchGooglePlaceDataResponoseDto.self, from: data)

            guard let place = json.places.first else { return nil }

            let poi = POI(context: CoreDataManager.shared.context)

            poi.name = name
            poi.category = category
            poi.latitude = place.location.latitude
            poi.longitude = place.location.longitude
            poi.openingHours = place.regularOpeningHours?.weekdayDescriptions.joined(separator: "\n")

            if let photoName = place.photos?.first?.name {
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

// MARK: - UITableViewDataSource
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

        // 셀 UI 스타일 설정
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
            cell.contentWrapperView.backgroundColor = .lightGray.withAlphaComponent(0.1)
            cell.contentWrapperView.layer.borderColor = UIColor.tertiaryLabel.withAlphaComponent(0.1).cgColor
        }
        cell.contentWrapperView.layer.borderWidth = 1
        cell.contentWrapperView.layer.shadowColor = UIColor.black.cgColor
        cell.contentWrapperView.layer.shadowOpacity = 0.2
        cell.contentWrapperView.layer.shadowRadius = 10
        cell.contentWrapperView.layer.shadowOffset = CGSize(width: 0, height: 0)

        cell.wrapperStackView.layer.cornerRadius = 8
        cell.wrapperStackView.clipsToBounds = true

        // 데이터 바인딩
        cell.indexIndicator.text = String(row + 1)
        cell.indexIndicator.layer.cornerRadius = 10
        cell.indexIndicator.clipsToBounds = true

        if let image = subItem.image {
            cell.cellImageView.image = image
        } else {
            // 이미지가 없는 경우, 이미지 뷰를 숨김.
            cell.cellImageView.isHidden = true
            cell.titleLabel.topAnchor.constraint(equalTo: cell.wrapperStackView.topAnchor, constant: 12).isActive = true
        }

        cell.titleLabel.text = subItem.name
        cell.typeLabel.text = subItem.type?.name

        return cell
    }
}

// MARK: - AddToScheduleSheetViewControllerDelegate
extension RecommandCourseDetailViewController: AddToScheduleSheetViewControllerDelegate {
    /// 일정 추가 시트가 닫힌 후 호출되어 사용자에게 알림을 표시.
    func sheetViewControllerDidDismiss(_ viewController: AddToScheduleSheetViewController) {
        self.showInAppNotification(
            message: "일정에 성공적으로 추가했어요!",
            duration: 2
        )
    }
}
