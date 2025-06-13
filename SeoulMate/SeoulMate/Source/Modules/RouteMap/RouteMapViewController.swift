//
//  RouteMapViewController.swift
//  SeoulMate
//
//  Created by JuHyeon Seong on 6/10/25.
//

import UIKit
import NMapsMap

// TODO: 경로를 실시간으로 계속 받아와야 할까 아니면 한번만 받고 저장해둔걸 보여줘야 할까,,
struct TempTour {
    var name: String
    var latitude: Double
    var longitude: Double
}

var dummyData: [TempTour] = [
    TempTour(name: "서울역", latitude: 37.552987, longitude: 126.972591),
    //    TempTour(name: "신림역", latitude: 37.484171739, longitude: 126.929784067),
    //    TempTour(name: "신림역", latitude: 37.484171739, longitude: 126.929784067),
    TempTour(name: "강남역", latitude: 37.496486, longitude: 127.028361),
]

struct RouteData {
    struct Coordinate {
        let latitude: Double
        let longitude: Double
    }

    struct Point {
        let coordinate: Coordinate
        let type: PointType

        var pointColor: UIColor {
            switch self.type {
            case .sp, .s:
                return UIColor(red: 217/255, green: 73/255, blue: 80/255, alpha: 1)

            case .ep, .e:
                return UIColor(red: 79/255, green: 188/255, blue: 99/255, alpha: 1)

            case .b1, .b2, .b3, .pp, .pp1, .pp2, .pp3, .pp4, .pp5:
                return UIColor(red: 150/255, green: 155/255, blue: 165/255, alpha: 1)

            case .n, .gp:
                return UIColor(red: 150/255, green: 155/255, blue: 165/255, alpha: 1)
            }
        }

        var captionText: String? {
            switch self.type {
            case .sp, .s:
                return "출발"
            case .ep, .e:
                return "도착"
            case .b1, .b2, .b3, .pp, .pp1, .pp2, .pp3, .pp4, .pp5:
                return "경유"
            case .n, .gp:
                return nil
            }
        }

        init(latitude: Double, longitude: Double, type: PointType) {
            self.coordinate = Coordinate(latitude: latitude, longitude: longitude)
            self.type = type
        }
    }

    struct Path {
        enum TravelMode {
            case drive
            case transit
            case walk
        }

        let polyline: [Coordinate]
        let travelMode: RouteOption? = nil
        let traffic: Int? = nil

        var lineColor: UIColor? {
            switch travelMode {
            case .transit:
                return UIColor(red: 86/255, green: 169/255, blue: 73/255, alpha: 1)
            case .drive, .walk, nil:
                // drive -> traffic에 따른 분기 필요
                return UIColor(red: 54/255, green: 81/255, blue: 251/255, alpha: 1)
            }
        }
    }

    var totalDistance: Int = 0
    var totalTime: Int = 0

    var points: [Point] = []
    var paths: [Path] = []
}

class RouteMapViewController: UIViewController {
    // cameraUpdateWithFitBounds(_:)
    @IBOutlet weak var naverMapView: NMFNaverMapView!

    @IBOutlet weak var routeInfoWrapperView: UIView!

    @IBOutlet weak var interStackView: UIStackView!
    @IBOutlet weak var interToEndArrow: UIImageView!

    @IBOutlet weak var segmentIndicator: UIView!

    @IBOutlet weak var routeOptionCollectionView: UICollectionView!

    @IBAction func route(_ sender: Any) {
        if let btn = sender as? UIButton {

            indicatorConstraint.forEach {
                if btn == ($0.secondItem as? UIButton) {
                    $0.priority = .defaultHigh
                } else {
                    $0.priority = .defaultLow
                }
            }

            UIView.animate(withDuration: 0.3) { [weak self] in
                self?.view.layoutIfNeeded()
            }

            switch btn.tag {
            case 1:
                selectedRouteOption = .drive(searchOption: .recommand)
            case 2:
                selectedRouteOption = .transit
            case 3:
                selectedRouteOption = .walk(searchOption: .recommand)
            default:
                return
            }

//            Task {
//                await calcRoute(type: selectedRouteOption, startPoint: startPoint, endPoint: endPoint)
//            }
        }
    }

    var routeCache: [RouteOption: RouteData] = [:]

    var selectedRouteOption = RouteOption.drive(searchOption: .recommand)

    let multipartPath = NMFMultipartPath()

    var markerReference: [NMFMarker] = []

    var startPoint: Location? {
        guard let first = dummyData.first else {
            return nil
        }

        return Location(latitude: first.latitude, longitude: first.longitude)
    }

    var endPoint: Location? {
        guard let last = dummyData.last else {
            return nil
        }

        return Location(latitude: last.latitude, longitude: last.longitude)
    }

    var intermediates: [Location]? {
        if dummyData.count > 2 {
            let count = dummyData.count

            return dummyData[1..<count-1].map { Location(latitude: $0.latitude, longitude: $0.longitude) }
        }

        return nil
    }

    var collectionViewLayout: UICollectionViewCompositionalLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.4),
                                              heightDimension: .fractionalHeight(1))

        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                               heightDimension: .fractionalHeight(1))

        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, repeatingSubitem: item, count: 3)

        let section = NSCollectionLayoutSection(group: group)

        let configuration = UICollectionViewCompositionalLayoutConfiguration()
        configuration.scrollDirection = .horizontal

        let layout = UICollectionViewCompositionalLayout(section: section, configuration: configuration)

        return layout
    }

    var indicatorConstraint: [NSLayoutConstraint] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        setupLayout()

        if let startPoint, let endPoint {
            moveCamera(location: startPoint)

            Task {
                await calcRoute(type: .drive(searchOption: .recommand), startPoint: startPoint, endPoint: endPoint, intermediates: intermediates)
                await calcRoute(type: .drive(searchOption: .fastest), startPoint: startPoint, endPoint: endPoint, intermediates: intermediates)
                await calcRoute(type: .drive(searchOption: .shortest), startPoint: startPoint, endPoint: endPoint, intermediates: intermediates)

                if let points = routeCache[.drive(searchOption: .recommand)]?.points {
                    drawPoints(points: points)
                }

                if let paths = routeCache[.drive(searchOption: .recommand)]?.paths {
                    drawPath(paths: paths)
                }

                routeOptionCollectionView.reloadData()
            }
        } else {
            // TODO: 좌표 생성 못했을때 오류 처리
        }
    }

    override func viewIsAppearing(_ animated: Bool) {
        super.viewIsAppearing(animated)

        updateIntermediatesInfo()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
}

extension RouteMapViewController {
    func setupLayout() {
        naverMapView.showLocationButton = false

        routeInfoWrapperView.layer.borderColor = UIColor.gray.withAlphaComponent(0.2).cgColor
        routeInfoWrapperView.layer.borderWidth = 1
        routeInfoWrapperView.layer.cornerRadius = 12
        routeInfoWrapperView.clipsToBounds = true

        collectionViewLayout.configuration.scrollDirection = .horizontal
        routeOptionCollectionView.collectionViewLayout = collectionViewLayout

        routeOptionCollectionView.showsVerticalScrollIndicator = false
        routeOptionCollectionView.showsHorizontalScrollIndicator = false

        segmentIndicator.layer.cornerRadius = segmentIndicator.frame.height / 2
        segmentIndicator.backgroundColor = .main.withAlphaComponent(0.5)

        indicatorConstraint = view.constraints.filter({
            ($0.firstItem as? UIView) == segmentIndicator && $0.firstAttribute == .centerX
        })
    }

    func updateIntermediatesInfo() {
        interStackView.subviews.forEach { $0.removeFromSuperview() }

        if let intermediates {
            let interImage = UIImage(systemName: "target")?
                .withRenderingMode(.alwaysOriginal)
                .withTintColor(UIColor(red: 150/255, green: 155/255, blue: 165/255, alpha: 1))

            for _ in 0..<intermediates.count {
                let interImageView = UIImageView(image: interImage)

                interImageView.contentMode = .scaleAspectFit
                interImageView.translatesAutoresizingMaskIntoConstraints = false

                interStackView.addArrangedSubview(interImageView)
            }

        } else {
            interStackView.isHidden = true
            interToEndArrow.isHidden = true
        }
    }

    func moveCamera(location: Location) {
        let scrollTo = NMGLatLng(lat: location.latitude, lng: location.longitude)

        let cameraUpdate = NMFCameraUpdate(scrollTo: scrollTo)
        cameraUpdate.animation = .easeIn

        naverMapView.mapView.moveCamera(cameraUpdate)
    }

    func calcRoute(type: RouteOption, startPoint: Location?, endPoint: Location?, intermediates: [Location]? = nil) async {

        resetMapComponents()

        guard let startPoint, let endPoint else {
            print("Parameter error")

            return
        }

        if let routeData = routeCache[type] {
            drawMapOverlays(routeData: routeData)

			return
        }

        switch type {
        case .drive(nil), .walk(nil):
            break
        case .drive(_), .walk(_):
            await calcRouteTMap(type: type, startPoint: startPoint, endPoint: endPoint, intermediates: intermediates)
        case .transit:
            await calcRouteByTransit(startPoint: startPoint, endPoint: endPoint)
        }
    }

    func calcRouteByTransit(startPoint: Location, endPoint: Location) async {
        var lineParts: [NMGLineString<AnyObject>] = []
        var colorParts: [NMFPathColor] = []

        let response: GoogleRoutesApiResponseDto? = await RouteApiManager.shared.calcRouteByTransit(startPoint: startPoint, endPoint: endPoint)

        guard let steps = response?.routes[0].legs[0].steps else {
            return
        }

        for step in steps {
            var points: [NMGLatLng] = []

            for coordinate in step.polyline.geoJSONLinestring.coordinates {
                let latitude: Double = coordinate[1]
                let longitude: Double = coordinate[0]

                let point = NMGLatLng(lat: latitude, lng: longitude)

                points.append(point)
            }

            let linePart: NMGLineString<AnyObject> = NMGLineString<AnyObject>(points: points)

            lineParts.append(linePart)

            var color: UIColor

            switch step.travelMode {
            case "WALK":
                color = UIColor(red: 54/255, green: 81/255, blue: 251/255, alpha: 1)
            case "TRANSIT":
                color = UIColor(red: 86/255, green: 169/255, blue: 73/255, alpha: 1)
            default:
                color = .lightGray
            }

            let colorPart: NMFPathColor = NMFPathColor(color: color)

            colorParts.append(colorPart)

            print(lineParts.count)
            print(colorParts.count)

            print(step.staticDuration, step.travelMode)
            print(linePart.points.first, linePart.points.last, color)
        }
    }

    func calcRouteTMap(type: RouteOption, startPoint: Location, endPoint: Location, intermediates: [Location]? = nil) async {
        let response: TMapRoutesApiResponseDto? = await RouteApiManager.shared.calcRouteTMap(type: type, startPoint: startPoint, endPoint: endPoint, intermediates: intermediates)

        var routeData = RouteData()

        if let features = response?.features {
            for feature in features {
                if feature.properties.index == nil {
                    continue
                }

                if feature.geometry.type == .point {
                    guard case let .double(longitude) = feature.geometry.coordinates[0],
                          case let .double(latitude) = feature.geometry.coordinates[1] else {
                        continue
                    }

                    guard let pointType = feature.properties.pointType else {
                        continue
                    }

                    let point = RouteData.Point(latitude: latitude, longitude: longitude, type: pointType)
                    routeData.points.append(point)

                    if let totalDistance = feature.properties.totalDistance {
                        routeData.totalDistance = totalDistance
                    }

                    if let totalTime = feature.properties.totalTime {
                        routeData.totalTime = totalTime
                    }

                } else if feature.geometry.type == .lineString {
                    // TOOD: 혼잡도에 따른 라인 색상 변경
                    var polyline: [RouteData.Coordinate] = []

                    for coordinate in feature.geometry.coordinates {
                        guard case let .doubleArray(latLng) = coordinate else {
                            continue
                        }

                        polyline.append(.init(latitude: latLng[1], longitude: latLng[0]))
                    }

                    let path: RouteData.Path = .init(polyline: polyline)
                    routeData.paths.append(path)
                }
            }
        }

        routeCache[type] = routeData
    }

    func resetMapComponents() {
        multipartPath.mapView = nil

        for markerReference in self.markerReference {
            markerReference.mapView = nil
        }

        markerReference.removeAll()
    }

    func drawMapOverlays(routeData: RouteData) {
        drawPoints(points: routeData.points)
        drawPath(paths: routeData.paths)
    }

    func drawPoints(points: [RouteData.Point]) {
        for point in points {
            if point.type != .n && point.type != .gp {
                let marker = NMFMarker()

                marker.width = 30
                marker.height = 40

                marker.iconImage = NMF_MARKER_IMAGE_BLACK
                marker.iconTintColor = point.pointColor

                if let captionText = point.captionText {
                    marker.captionText = captionText
                }

                marker.position = NMGLatLng(lat: point.coordinate.latitude, lng: point.coordinate.longitude)

                marker.mapView = naverMapView.mapView

                markerReference.append(marker)
            }
        }
    }

    func drawPath(paths: [RouteData.Path]) {
        var lineParts: [NMGLineString<AnyObject>] = []
        var colorParts: [NMFPathColor] = []

        for path in paths {
            let points = path.polyline.map { NMGLatLng(lat: $0.latitude, lng: $0.longitude) }

            let linePart = NMGLineString<AnyObject>(points: points)

            lineParts.append(linePart)

            if let color = path.lineColor {
                let colorPart = NMFPathColor(color: color)

                colorParts.append(colorPart)
            }
        }

        multipartPath.width = 8

        multipartPath.patternIcon = NMFOverlayImage(name: "route_path_arrow")
        multipartPath.patternInterval = 16

        // FIXME: 간헐적인 색상 오류 -> 확인 필요
        multipartPath.lineParts = lineParts
        multipartPath.colorParts = colorParts

        multipartPath.mapView = naverMapView.mapView
    }
}

extension RouteMapViewController: UICollectionViewDataSource {
    var routeOptions: [RouteOption] {
        switch selectedRouteOption {
        case .drive:
            return [.drive(searchOption: .recommand),
                    .drive(searchOption: .fastest),
                    .drive(searchOption: .shortest)]
        case .walk:
            return [.walk(searchOption: .recommand),
                    .walk(searchOption: .preferBoulevard),
                    .walk(searchOption: .avoidStair)]
        default:
            return []
        }
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return routeOptions.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "RouteOptionCollectionViewCell", for: indexPath) as? RouteOptionCollectionViewCell else {
            return UICollectionViewCell()
        }
        let index = indexPath.item

        let option = routeOptions[index]

        let data = routeCache[option]

        if option == selectedRouteOption {
            cell.wrapperView.layer.borderColor = UIColor.label.cgColor
        } else {
            cell.wrapperView.layer.borderColor = UIColor.label.withAlphaComponent(0.3).cgColor
        }

        cell.wrapperView.layer.borderWidth = 1
        cell.wrapperView.layer.cornerRadius = 8

        cell.wrapperView.layer.shadowColor = UIColor.black.cgColor
        cell.wrapperView.layer.shadowOpacity = 0.2
        cell.wrapperView.layer.shadowRadius = 5
        cell.wrapperView.layer.shadowOffset = CGSize(width: 0, height: 0)

        cell.optionLabel.text = option.title

        if let distance = data?.totalDistance {
            cell.totalDistance.text = "\(Int(round(Double(distance / 1000))))km"
        }

        if let totalTime = data?.totalTime {
            let hour = totalTime / 3600
            let minute = (totalTime % 3600) / 60

            cell.estimatedTimeLabel.text = "\(hour > 0 ? String(hour) + "시 " : "")\(minute)분"

            let formatter = DateFormatter()
            formatter.dateFormat = "HH시 mm분"

            let date = Date(timeIntervalSinceNow: TimeInterval(totalTime))

            cell.eTALabel.text = formatter.string(from: date)
        }

        return cell
    }
}

extension RouteMapViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print(#function)
        collectionView.scrollToItem(at: indexPath, at: .left, animated: true)
    }
}
