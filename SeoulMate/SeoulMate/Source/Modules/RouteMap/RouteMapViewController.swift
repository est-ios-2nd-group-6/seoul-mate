//
//  RouteMapViewController.swift
//  SeoulMate
//
//  Created by JuHyeon Seong on 6/10/25.
//

import UIKit
import NMapsMap

// TODO: 1. TravelMode == .transit 일때, 경로 정보 안내

// TODO: drive, walk 시 대체경로 회색으로 표시
// TODO: TableView 순서 변경
// TODO: TravelMode == .transit 일때, 지하철 호선에 따른 색상 변경

typealias TransitDetailInfo = RouteData.Path.TransitDetailInfo

struct TempTour {
    var name: String
    var latitude: Double
    var longitude: Double
}

var dummyData: [TempTour] = [
    TempTour(name: "신림역", latitude: 37.484171739, longitude: 126.929784067),
    TempTour(name: "서울역", latitude: 37.552987, longitude: 126.972591),
    TempTour(name: "사당역", latitude: 37.476559992, longitude: 126.981638570),
    TempTour(name: "강남역", latitude: 37.496486, longitude: 127.028361),
    TempTour(name: "옥수역", latitude: 37.468502, longitude: 126.906699),
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
            case .sp, .s, .startLocation:
                return .mapPointGreen

            case .ep, .e, .endLocation:
                return .mapPointRed

            case .b1, .b2, .b3, .pp, .pp1, .pp2, .pp3, .pp4, .pp5:
                return .mapPointGray

            case .n, .gp:
                return .mapPointGray
            }
        }

        var captionText: String? {
            switch self.type {
            case .sp, .s, .startLocation:
                return "출발"
            case .ep, .e, .endLocation:
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
        enum Traffic: Int {
            case unknown = 0
            case smooth = 1
            case slow = 2
            case verySlow = 4
        }

        struct TransitDetailInfo {
            struct Vehicle {
                let name: String
                let color: UIColor
                let type: String

                init(transitLine: TransitLine) {
                    self.name = transitLine.nameShort
                    self.color = UIColor(hexString: transitLine.color) ?? .mapLineBasic
                    self.type = transitLine.vehicle.type
                }
            }

            var departureName: String?
            var arrivalName: String?

            let vehicle: Vehicle?
            let stopCount: Int?
            var distance: Int
            var duration: Int
            var instructions: [String]? = nil

            var descriptionText: String? {
                var text = ""

                if vehicle?.type == "SUBWAY" {
                    guard let name = vehicle?.name else { return nil }

                    text = "\(name)\n약 \(Int(round(Double(duration / 60))))분"

                    if let stopCount {
                        text += " (\(stopCount)개 역 이동)"
                    }
                } else if vehicle?.type == "BUS" {
                    guard let name = vehicle?.name else { return nil }

                    text = "\(name)\n약 \(Int(round(Double(duration / 60))))분"

                    if let stopCount {
                        text += " (정류장 \(stopCount)개)"
                    }
                } else {
					text = "도보\n"
                    text += "\(Int(round(Double(duration / 60))))분, \(distance) 미터\n"

                    if let instructions {
                        text += instructions.joined(separator: "\n")
                    }
                }

                return text
            }

            init?(step: Step) {
                let transitDetails = step.transitDetails

                let transitLine = transitDetails?.transitLine
                let stopDetails = transitDetails?.stopDetails

                self.departureName = stopDetails?.departureStop.name
                self.arrivalName = stopDetails?.arrivalStop.name

                if let transitLine {
                    self.vehicle = .init(transitLine: transitLine)
                } else {
                    self.vehicle = nil
                }

                self.stopCount = transitDetails?.stopCount
                self.distance = step.distanceMeters ?? 0

                self.instructions = []

                if let instruction = step.navigationInstruction.instructions {
                    self.instructions?.append(instruction)
                }

                if let duration: Int = Int(step.staticDuration.replacing(/[a-zA-Z]/, with: "")) {
                    self.duration = duration
                } else {
                    self.duration = 0
                }
            }
        }

        var polyline: [Coordinate]
        var travelMode: RouteOption? = nil
        var traffic: Traffic? = nil
        var detail: TransitDetailInfo? = nil

        var lineColor: UIColor? {
            switch travelMode {
            case .transit:
                return detail?.vehicle?.color
            case .walk, nil:
                // drive -> traffic에 따른 분기 필요
                return .mapLineBasic
            case .drive:
                switch traffic {
                case nil, .unknown, .smooth:
                    return .mapLineGreen
                case .slow:
                    return .mapLineOrange
                case .verySlow:
                    return .mapPointRed
                }
            }
        }

        init(polyline: [Coordinate], travelMode: RouteOption? = nil, traffic: Traffic? = nil, detail: TransitDetailInfo? = nil) {
            self.polyline = polyline
            self.travelMode = travelMode
            self.traffic = traffic
            self.detail = detail
        }

        //        init(step: Step) {
        //            var polyline: [RouteData.Coordinate] = []
        //
        //
        //
        //            for coordinate in step.polyline.geoJSONLinestring.coordinates {
        //                let latitude: Double = coordinate[1]
        //                let longitude: Double = coordinate[0]
        //
        //                polyline.append(.init(latitude: latitude, longitude: longitude))
        //            }
        //
        //            self.polyline = polyline
        //            self.travelMode = RouteOption(rawValue: step.travelMode)
        //        }

    }

    var searchOption: SearchOption? = nil

    var totalDistance: Int = 0
    var totalTime: Int = 0

    var points: [Point] = []
    var paths: [Path] = []
}

class RouteMapViewController: UIViewController {
    // MARK: - Outlets
    @IBOutlet weak var naverMapView: NMFNaverMapView!

    @IBOutlet weak var routeInfoStackView: UIStackView!
    @IBOutlet weak var routeInfoTableView: UITableView!
    @IBOutlet weak var routeInfoWrapperView: UIView!

    @IBOutlet weak var wrapperViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var tableViewHeightConstraint: NSLayoutConstraint!

    @IBOutlet weak var interStackView: UIStackView!
    @IBOutlet weak var interToEndArrow: UIImageView!

    @IBOutlet weak var segmentIndicator: UIView!

    @IBOutlet weak var routeOptionCollectionView: UICollectionView!

    @IBOutlet weak var transitDetailWrapperView: UIStackView!
    @IBOutlet weak var transitDetailWrapperViewHeightConstraint: NSLayoutConstraint!

    @IBOutlet weak var transitDetailTableView: UITableView!

    // MARK: - Actions
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
            case 1: selectedRouteOption = .drive
            case 2: selectedRouteOption = .transit
            case 3: selectedRouteOption = .walk
            default: return
            }
        }
    }

    // MARK: - Properties
    var pois: [POI] = []

    var transitDetailWrapperViewHeight: Int = 300

    var routeCache: [RouteOption: [RouteData]] = [:]

    var selectedRouteOption: RouteOption? = nil {
        didSet(oldVal) {
            if selectedRouteOption == oldVal {
                return
            }

            if selectedRouteOption == .transit {
                transitDetailWrapperViewHeightConstraint.constant = CGFloat(transitDetailWrapperViewHeight)

                interStackView.isHidden = true
                interToEndArrow.isHidden = true
            } else {
                transitDetailWrapperViewHeightConstraint.constant = 0

                interStackView.isHidden = false
                interToEndArrow.isHidden = false
            }

            UIView.animate(withDuration: 0.3) { [weak self] in
                self?.view.layoutIfNeeded()
            }

            guard let selectedRouteOption else { return }

            if routeCache[selectedRouteOption, default: []].isEmpty {
                Task {
                    if selectedRouteOption == .drive || selectedRouteOption == .walk {
                        for searchOption in selectedRouteOption.searchOptions ?? [] {
                            await calcRoute(type: selectedRouteOption, searchOption: searchOption, startPoint: startPoint, endPoint: endPoint, intermediates: intermediates)
                        }
                    } else {
                        await calcRoute(type: selectedRouteOption, startPoint: startPoint, endPoint: endPoint)
                    }

                    self.routeOptionCollectionView.reloadData()

                    selectedSearchOption = 0
                }
            } else {
                self.routeOptionCollectionView.reloadData()

                selectedSearchOption = 0
            }
        }
    }

    var selectedSearchOption: Int = 0 {
        didSet {
            guard let selectedRouteOption else { return }

            if let routeData = routeCache[selectedRouteOption]?[selectedSearchOption] {
                drawMapOverlays(routeData: routeData)
            }

            if selectedRouteOption == .transit {
                self.transitDetailTableView.reloadData()
            }
        }
    }

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

    var isMapFullscreend: Bool = false

    var indicatorConstraint: [NSLayoutConstraint] = []

    // MARK: - Methods
    override func viewDidLoad() {
        super.viewDidLoad()

        // FIXME: 임시
        self.overrideUserInterfaceStyle = .light

        setupLayout()
        setupMapView()
        setupTableViews()
        updateIntermediatesInfo()

        moveCameraToFitBounds()

        selectedRouteOption = .drive
    }

    override func viewIsAppearing(_ animated: Bool) {
        super.viewIsAppearing(animated)
    }

    @objc func showRouteInfoTableView() {
        UIView.animate(withDuration: 0.3) { [weak self] in
            guard let self else { return }

            self.routeInfoTableView.isHidden = false
            self.routeInfoStackView.isHidden = true

            self.wrapperViewHeightConstraint.constant = routeInfoTableView.contentSize.height + 8
            self.tableViewHeightConstraint.constant = routeInfoTableView.contentSize.height

            self.view.layoutIfNeeded()
        }
    }

    @objc func showRouteInfoStackView() {
        UIView.animate(withDuration: 0.3) { [weak self] in
            guard let self else { return }

            self.routeInfoTableView.isHidden = true
            self.routeInfoStackView.isHidden = false

            self.wrapperViewHeightConstraint.constant = 50
            self.tableViewHeightConstraint.constant = 0 // TableView가 숨겨질 때 높이도 0으로 설정

            self.view.layoutIfNeeded()
        }
    }
}

// MARK: - Extension
extension RouteMapViewController {
    func setupLayout() {
        naverMapView.showLocationButton = false

        routeInfoWrapperView.layer.borderColor = UIColor.gray.withAlphaComponent(0.2).cgColor
        routeInfoWrapperView.layer.borderWidth = 1
        routeInfoWrapperView.layer.cornerRadius = 12
        routeInfoWrapperView.clipsToBounds = true

        segmentIndicator.layer.cornerRadius = segmentIndicator.frame.height / 2
        segmentIndicator.backgroundColor = .main.withAlphaComponent(0.5)

        indicatorConstraint = view.constraints.filter({
            ($0.firstItem as? UIView) == segmentIndicator && $0.firstAttribute == .centerX
        })
    }

    func setupMapView() {
        naverMapView.mapView.touchDelegate = self
        naverMapView.mapView.extent = NMGLatLngBounds(
            southWestLat: 37.413294,
            southWestLng: 126.734086,
            northEastLat: 37.715133,
            northEastLng: 127.269311
        )
    }

    func setupTableViews() {
        transitDetailTableView.register(
            TransitDetailTableViewCell.nib,
            forCellReuseIdentifier: TransitDetailTableViewCell.identifier
        )

        transitDetailTableView.register(
            TransitDetailSegueTableViewCell.nib,
            forCellReuseIdentifier: TransitDetailSegueTableViewCell.identifier
        )

        transitDetailTableView.showsVerticalScrollIndicator = false
        transitDetailTableView.showsHorizontalScrollIndicator = false

        let showInfoTableTapGesture = UITapGestureRecognizer(
            target: self,
            action: #selector(showRouteInfoTableView)
        )
        routeInfoStackView.addGestureRecognizer(showInfoTableTapGesture)

        let showInfoStackTapGesture = UITapGestureRecognizer(
            target: self,
            action: #selector(showRouteInfoStackView)
        )
        routeInfoTableView.addGestureRecognizer(showInfoStackTapGesture)
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
        //        cameraUpdateWithFitBounds
        let scrollTo = NMGLatLng(lat: location.latitude, lng: location.longitude)
        let cameraUpdate = NMFCameraUpdate(scrollTo: scrollTo)
        cameraUpdate.animation = .easeIn
        naverMapView.mapView.moveCamera(cameraUpdate)
    }

    func moveCameraToFitBounds() {
        if let southWestLat = dummyData.min(by: { $0.latitude < $1.latitude })?.latitude,
           let southWestLng = dummyData.min(by: { $0.longitude < $1.longitude })?.longitude,
           let northEastLat = dummyData.max(by: { $0.latitude < $1.latitude })?.latitude,
           let northEastLng = dummyData.max(by: { $0.longitude < $1.longitude })?.longitude {
            let bounds = NMGLatLngBounds(southWestLat: southWestLat, southWestLng: southWestLng, northEastLat: northEastLat, northEastLng: northEastLng)

            let cameraUpdate = NMFCameraUpdate(fit: bounds, paddingInsets: UIEdgeInsets(top: 200, left: 50, bottom: 50, right: 50))
            cameraUpdate.animation = .easeIn

            naverMapView.mapView.moveCamera(cameraUpdate)
        }
    }

    func calcRoute(type: RouteOption, searchOption: SearchOption? = nil, startPoint: Location?, endPoint: Location?, intermediates: [Location]? = nil) async {

        guard let startPoint, let endPoint else {
            print("Parameter error")

            return
        }

        if let datas = routeCache[type], let routeData = datas.first(where: { $0.searchOption == searchOption }) {
            drawMapOverlays(routeData: routeData)

            return
        }

        switch type {
        case .drive, .walk:
            await calcRouteByTMap(type: type, searchOption: searchOption, startPoint: startPoint, endPoint: endPoint, intermediates: intermediates)
        case .transit:
            await calcRouteTransitByGoogle(startPoint: startPoint, endPoint: endPoint)
        }
    }

    func calcRouteTransitByGoogle(startPoint: Location, endPoint: Location) async {
        // TODO: computeAlternativeRoutes true 시 경로 오류
        let response: GoogleRoutesApiResponseDto? = await RouteApiManager.shared.calcRouteTransitByGoogle(startPoint: startPoint, endPoint: endPoint)

        guard let response else { return }

        var routeData = RouteData()

        for route in response.routes {
            let leg = route.legs[0]
            let steps = leg.steps

            routeData.totalDistance = route.distanceMeters

            let duration: String = route.duration.replacing(/[a-zA-Z]/, with: "")

            if let totalTime = Int(duration) {
                routeData.totalTime = totalTime
            }

            let startLocation = leg.startLocation.latLng

            let startPoint = RouteData.Point(
                latitude: startLocation.latitude,
                longitude: startLocation.longitude,
                type: .startLocation
            )

            routeData.points.append(startPoint)

            let endLocation = leg.endLocation.latLng

            let endPoint = RouteData.Point(
                latitude: endLocation.latitude,
                longitude: endLocation.longitude,
                type: .endLocation
            )

            routeData.points.append(endPoint)

            var acc: RouteData.Path? = nil

            for (index, step) in steps.enumerated() {
                if step.distanceMeters == nil && step.staticDuration == "0s" {
                    continue
                }

                var polyline: [RouteData.Coordinate] = []

                for coordinate in step.polyline.geoJSONLinestring.coordinates {
                    let latitude: Double = coordinate[1]
                    let longitude: Double = coordinate[0]

                    polyline.append(.init(latitude: latitude, longitude: longitude))
                }

                if step.travelMode == "TRANSIT" {
                    if acc != nil {
                        routeData.paths.append(acc!)

                        acc = nil
                    }

                    let path = RouteData.Path(
                        polyline: polyline,
                        travelMode: RouteOption(rawValue: step.travelMode),
                        detail: TransitDetailInfo(step: step)
                    )

                    routeData.paths.append(path)

                } else if step.travelMode == "WALK" {
                    if acc != nil {
                        acc?.detail?.distance += step.distanceMeters ?? 0

                        if let duration = Int(step.staticDuration.replacing(/[a-zA-Z]/, with: "")) {
                            acc?.detail?.duration = duration
                        } else {
                            acc?.detail?.duration = 0
                        }

                        if let instructions = step.navigationInstruction.instructions {
                            acc?.detail?.instructions?.append(instructions)
                        }

                        acc?.polyline.append(contentsOf: polyline)
                    } else {
                        acc = RouteData.Path(
                            polyline: polyline,
                            travelMode: RouteOption(rawValue: step.travelMode),
                            detail: TransitDetailInfo(step: step))

                        if index == 0, let departureName = dummyData.first?.name {
                            acc?.detail?.departureName = departureName
                        }

                        if index == steps.count - 1, let arrivalName = dummyData.last?.name {
                            acc?.detail?.arrivalName = arrivalName

                            routeData.paths.append(acc!)
                        }
                    }
                }
            }

            routeCache[.transit, default: []].append(routeData)
        }
    }

    func calcRouteByTMap(type: RouteOption, searchOption: SearchOption? = nil, startPoint: Location, endPoint: Location, intermediates: [Location]? = nil) async {
        let response: TMapRoutesApiResponseDto? = await RouteApiManager.shared.calcRouteByTMap(type: type, searchOption: searchOption, startPoint: startPoint, endPoint: endPoint, intermediates: intermediates)

        var routeData = RouteData()
        routeData.searchOption = searchOption

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
                    let coordinates = feature.geometry.coordinates

                    if let traffics = feature.geometry.traffic, !traffics.isEmpty {
                        for traffic in traffics {
                            let startIndex = traffic[0]
                            let endIndex = traffic[1]
                            let trafficValue = traffic[2]

                            let polyline: [RouteData.Coordinate] = coordinates[startIndex...endIndex].compactMap { coordinate in
                                guard case let .doubleArray(latLng) = coordinate else {
                                    return nil
                                }

                                return RouteData.Coordinate(latitude: latLng[1], longitude: latLng[0])
                            }

                            let path: RouteData.Path = .init(
                                polyline: polyline,
                                travelMode: type,
                                traffic: RouteData.Path.Traffic(
                                    rawValue: trafficValue
                                )
                            )

                            routeData.paths.append(path)
                        }
                    } else {
                        let polyline: [RouteData.Coordinate] = coordinates.compactMap { coordinate in
                            guard case let .doubleArray(latLng) = coordinate else {
                                return nil
                            }

                            return RouteData.Coordinate(latitude: latLng[1], longitude: latLng[0])
                        }

                        let path: RouteData.Path = .init(polyline: polyline, travelMode: type)
                        routeData.paths.append(path)
                    }
                }
            }
        }

        routeCache[type, default: []].append(routeData)
    }

    func resetMapComponents() {
        multipartPath.mapView = nil

        for markerReference in self.markerReference {
            markerReference.mapView = nil
        }

        markerReference.removeAll()
    }

    func drawMapOverlays(routeData: RouteData) {
        resetMapComponents()

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

// MARK: - Extension : UITableViewDataSource
extension RouteMapViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == routeInfoTableView {
            return dummyData.count
        } else if tableView == transitDetailTableView {
            return routeCache[.transit]?[selectedSearchOption].paths.count ?? 0
        } else {
            return 0
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == routeInfoTableView {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "RouteInfoTableViewCell", for: indexPath) as? RouteInfoTableViewCell else { return UITableViewCell() }

            let index = indexPath.row
            let routeInfo = dummyData[index]

            var image: UIImage? = UIImage(systemName: "target")?.withRenderingMode(.alwaysOriginal)

            if index == 0 {
                image = image?.withTintColor(.mapPointGreen)
            } else if index == dummyData.count - 1 {
                image = image?.withTintColor(.mapPointRed)
            } else {
                image = image?.withTintColor(.mapPointGray)
            }

            cell.cellImageView.image = image

            cell.titleLabel.text = routeInfo.name

            return cell
        } else if tableView == transitDetailTableView {
            guard let selectedRouteOption, selectedRouteOption == .transit else {
                return UITableViewCell()
            }

            let path = routeCache[selectedRouteOption]?[selectedSearchOption].paths[indexPath.row]

            print(path?.detail?.departureName)
            print(path?.detail?.arrivalName)
            print("--------------")

            guard let cell = tableView.dequeueReusableCell(withIdentifier: TransitDetailTableViewCell.identifier, for: indexPath) as? TransitDetailTableViewCell else { return UITableViewCell() }

            if let departureName = path?.detail?.departureName {
                cell.departureTitleLabel.text = departureName
                cell.departureStackView.isHidden = false
            } else {
                cell.departureStackView.isHidden = true
            }

            cell.segueLineView.backgroundColor = path?.lineColor

            cell.descriptionLabel.text = path?.detail?.descriptionText

            if let arrivalName = path?.detail?.arrivalName {
                cell.arrivalTitleLabel.text = arrivalName
                cell.arrivalStackView.isHidden = false
            } else {
                cell.arrivalStackView.isHidden = true
            }

            return cell
        } else {
            return UITableViewCell()
        }
    }
}

// MARK: - Extension : UICollectionViewDataSource
extension RouteMapViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let selectedRouteOption else { return 0 }

        return routeCache[selectedRouteOption]?.count ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "RouteOptionCollectionViewCell", for: indexPath) as? RouteOptionCollectionViewCell else {
            return UICollectionViewCell()
        }

        guard let selectedRouteOption else { return UICollectionViewCell() }

        let index = indexPath.item
        let option = selectedRouteOption.searchOptions?[index]

        guard let data = routeCache[selectedRouteOption]?.first(where: { $0.searchOption == option }) else { return UICollectionViewCell() }

        if index == selectedSearchOption {
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

        cell.optionLabel.text = option?.title ?? "추천 경로 \(index + 1)"

        cell.totalDistance.text = "\(Int(round(Double(data.totalDistance / 1000))))km"

        let hour = data.totalTime / 3600
        let minute = (data.totalTime % 3600) / 60

        cell.estimatedTimeLabel.text = "\(hour > 0 ? String(hour) + "시간 " : "")\(minute)분"

        let formatter = DateFormatter()
        formatter.dateFormat = "HH시 mm분"

        let date = Date(timeIntervalSinceNow: TimeInterval(data.totalTime))

        cell.eTALabel.text = formatter.string(from: date)

        return cell
    }
}

// MARK: - Extension : UICollectionViewDeletagate
extension RouteMapViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedSearchOption = indexPath.item

        collectionView.scrollToItem(at: indexPath, at: .left, animated: true)

        collectionView.reloadData()
    }
}

extension RouteMapViewController: NMFMapViewTouchDelegate {
    func mapView(_ mapView: NMFMapView, didTapMap latlng: NMGLatLng, point: CGPoint) {
        isMapFullscreend.toggle()

        self.transitDetailWrapperViewHeightConstraint.constant = self.isMapFullscreend || self.selectedRouteOption != .transit ? 0 : CGFloat(transitDetailWrapperViewHeight)

        UIView.animate(withDuration: 0.3) { [weak self] in
            guard let self else { return }

            self.view.subviews
                .filter { $0 != self.naverMapView }
                .forEach { view in
                    view.isHidden = self.isMapFullscreend
                }

            self.view.layoutIfNeeded()
        }
    }
}
