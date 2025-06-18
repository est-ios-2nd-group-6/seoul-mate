//
//  RouteMapViewController.swift
//  SeoulMate
//
//  Created by JuHyeon Seong on 6/10/25.
//

import UIKit
import NMapsMap

typealias TransitDetailInfo = RouteData.Path.TransitDetailInfo

struct RouteLocation: Codable {
    let name: String?
    let latitude, longitude: Double
}

/// 지도에 표시할 경로와 관련된 모든 데이터를 담는 모델.
struct RouteData {
    /// 위경도 좌표.
    struct Coordinate {
        let latitude: Double
        let longitude: Double
    }

    /// 출발, 도착, 경유지 등 지도에 표시될 특정 지점.
    struct Point {
        let coordinate: Coordinate
        let type: PointType

        /// 지점 유형에 따라 마커 색상을 반환.
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

        /// 지점 유형에 따라 마커의 캡션 텍스트를 반환.
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

    /// 지도에 그려질 단일 경로 구간.
    struct Path {
        /// TMap API에서 제공하는 교통량 정보.
        enum Traffic: Int {
            case unknown = 0
            case smooth = 1
            case slow = 2
            case verySlow = 4
        }

        /// Google Routes API의 대중교통 상세 정보를 담는 모델.
        struct TransitDetailInfo {
            /// 대중교통(지하철, 버스) 정보.
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

            /// 테이블 뷰 셀에 표시될 상세 설명 텍스트.
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

            /// Google Routes API의 `Step` 데이터로부터 초기화.
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

                // "s" 접미사 제거 및 정수 변환
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

        /// 이동 수단 및 교통 상황에 따라 경로 선 색상을 결정.
        var lineColor: UIColor? {
            switch travelMode {
            case .transit:
                return detail?.vehicle?.color
            case .walk, nil:
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
    }

    var searchOption: SearchOption? = nil

    var totalDistance: Int = 0
    var totalTime: Int = 0

    var points: [Point] = []
    var paths: [Path] = []
}

/// 지도 위에 사용자 일정의 경로를 표시하고, 교통수단별 상세 정보를 제공하는 뷰 컨트롤러.
///
/// TMap API(자동차, 도보)와 Google Routes API(대중교통)를 사용하여 경로를 계산하고 Naver Map SDK를 통해 시각화.
class RouteMapViewController: UIViewController {
    // MARK: - Outlets
    @IBOutlet weak var naverMapView: NMFNaverMapView!

    @IBOutlet weak var routeInfoStackView: UIStackView!

    @IBOutlet weak var routeInfoStartPointLabel: UILabel!
    @IBOutlet weak var routeInfoEndPointLabel: UILabel!

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

    // MARK: - Properties

    /// 이전 화면에서 전달받은 여행 장소(POI) 배열.
    var pois: [POI] = []

    let locationManager: CLLocationManager = CLLocationManager()

    var isFetchedLocationList: Bool = false

    var transitDetailWrapperViewHeight: Int = 300

    /// API 호출 결과를 캐싱하여 불필요한 네트워크 요청을 방지하기 위한 딕셔너리.
    /// - Key: `RouteOption` (교통수단)
    /// - Value: 해당 교통수단으로 계산된 `RouteData` 배열
    var routeCache: [RouteOption: [RouteData]] = [:]

    /// 현재 선택된 교통수단. `didSet`을 통해 UI 및 경로 데이터가 업데이트됨.
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

                if intermediates != nil {
                    interStackView.isHidden = false
                    interToEndArrow.isHidden = false
                }
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

    /// 현재 선택된 경로 검색 옵션(추천, 최단거리 등). `didSet`을 통해 지도 오버레이가 다시 그려짐.
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

    /// 지도에 그려질 여러 구간의 경로를 관리하는 객체.
    let multipartPath = NMFMultipartPath()

    /// 지도에 표시된 마커들을 관리하는 배열.
    var markerReference: [NMFMarker] = []

    var startPoint: RouteLocation? {
            guard let first = pois.first else {
                return nil
            }

            return RouteLocation(name: first.name, latitude: first.latitude, longitude: first.longitude)
        }

        var endPoint: RouteLocation? {
            guard let last = pois.last else {
                return nil
            }

            return RouteLocation(name: last.name, latitude: last.latitude, longitude: last.longitude)
        }

        var intermediates: [RouteLocation]? {
            if pois.count > 2 {
                let count = pois.count

                return pois[1 ..< count-1].map { RouteLocation(name: $0.name, latitude: $0.latitude, longitude: $0.longitude) }
            }

            return nil
        }

    var isMapFullscreend: Bool = false

    var indicatorConstraint: [NSLayoutConstraint] = []

    let overlayImage = NMFOverlayImage(name: "route_path_arrow")

    let seoulBoudns = NMGLatLngBounds(
        southWestLat: 37.413294,
        southWestLng: 126.734086,
        northEastLat: 37.715133,
        northEastLng: 127.269311
    )

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

    @IBAction func back(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }

    // MARK: - Methods
    override func viewDidLoad() {
        super.viewDidLoad()

        locationManager.delegate = self

        checkUserDeviceLocationServiceAuthorization()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.tabBarController?.tabBar.isHidden = true
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        self.tabBarController?.tabBar.isHidden = false
    }


    /// 경로 정보 테이블 뷰를 표시.
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

    /// 경로 정보 요약 스택 뷰를 표시.
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

// MARK: - Extension : UI & Map Setup
extension RouteMapViewController {
    func setup() {
        setupLayout()
        setupMapView()
        setupTableViews()
        updateIntermediatesInfo()
        moveCameraToFitBounds()

        // 초기 경로를 '자동차'로 설정.
        selectedRouteOption = .drive
    }

    func checkUserDeviceLocationServiceAuthorization() {
        guard CLLocationManager.locationServicesEnabled() else {
            // 시스템 설정으로 유도하는 커스텀 얼럿
            showRequestLocationServiceAlert()

            return
        }

        let authorizationStatus: CLAuthorizationStatus

        // 앱의 권한 상태 가져오는 코드 (iOS 버전에 따라 분기처리)
        authorizationStatus = locationManager.authorizationStatus

        // 권한 상태값에 따라 분기처리를 수행하는 메서드 실행
        checkUserCurrentLocationAuthorization(authorizationStatus)
    }

    func checkUserCurrentLocationAuthorization(_ status: CLAuthorizationStatus) {
        switch status {
        case .notDetermined:
            // 사용자가 권한에 대한 설정을 선택하지 않은 상태
            // 권한 요청을 보내기 전에 desiredAccuracy 설정 필요
            locationManager.desiredAccuracy = kCLLocationAccuracyBest

            // 권한 요청을 보낸다.
            locationManager.requestWhenInUseAuthorization()

        case .denied, .restricted:
            // 사용자가 명시적으로 권한을 거부했거나, 위치 서비스 활성화가 제한된 상태
            showRequestLocationServiceAlert()

        case .authorizedWhenInUse, .authorizedAlways:
            // 앱을 사용중일 때, 위치 서비스를 이용할 수 있는 상태

            if pois.count > 1 {
                setup()
            } else {
                locationManager.requestLocation()
            }

        default:
            print("Default")
        }
    }

    func showRequestLocationServiceAlert() {
        let requestLocationServiceAlert = UIAlertController(title: "위치 정보 이용", message: "위치 서비스를 사용할 수 없습니다.\n디바이스의 '설정 > 개인정보 보호'에서 위치 서비스를 켜주세요.", preferredStyle: .alert)

        let goSetting = UIAlertAction(title: "설정으로 이동", style: .destructive) { _ in
            if let appSetting = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(appSetting)
            }
        }

        let cancel = UIAlertAction(title: "취소", style: .default) { [weak self] _ in
            self?.navigationController?.popViewController(animated: true)
        }

        requestLocationServiceAlert.addAction(cancel)
        requestLocationServiceAlert.addAction(goSetting)

        present(requestLocationServiceAlert, animated: true)
    }

    func setupLayout() {
        routeInfoWrapperView.layer.borderColor = UIColor.gray.withAlphaComponent(0.2).cgColor
        routeInfoWrapperView.layer.borderWidth = 1
        routeInfoWrapperView.layer.cornerRadius = 12
        routeInfoWrapperView.clipsToBounds = true

        routeInfoStartPointLabel.text = startPoint?.name
        routeInfoEndPointLabel.text = endPoint?.name

        segmentIndicator.layer.cornerRadius = segmentIndicator.frame.height / 2
        segmentIndicator.backgroundColor = .main.withAlphaComponent(0.5)

        indicatorConstraint = view.constraints.filter({
            ($0.firstItem as? UIView) == segmentIndicator && $0.firstAttribute == .centerX
        })
    }

    /// 네이버 지도 SDK 관련 설정을 초기화.
    func setupMapView() {
        naverMapView.showLocationButton = true

        naverMapView.mapView.contentInset = UIEdgeInsets(top: 250, left: 0, bottom: 0, right: 0)
        naverMapView.mapView.touchDelegate = self

        // 서울 지역으로 지도 범위 제한
        naverMapView.mapView.extent = NMGLatLngBounds(
            southWestLat: 37.413294,
            southWestLng: 126.734086,
            northEastLat: 37.715133,
            northEastLng: 127.269311
        )

        let locationOverlay = naverMapView.mapView.locationOverlay
        locationOverlay.hidden = false

        naverMapView.mapView.positionMode = .normal
    }

    /// 테이블 뷰 및 제스처 관련 설정을 초기화.
    func setupTableViews() {
        transitDetailTableView.register(
            TransitDetailTableViewCell.nib,
            forCellReuseIdentifier: TransitDetailTableViewCell.identifier
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

        routeInfoTableView.reloadData()
    }

    /// 경유지 개수에 따라 UI를 업데이트.
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

    /// 특정 위치로 카메라를 이동.
    func moveCamera(location: Location) {
        let scrollTo = NMGLatLng(lat: location.latitude, lng: location.longitude)

        let cameraUpdate = NMFCameraUpdate(scrollTo: scrollTo)
        cameraUpdate.animation = .easeIn

        naverMapView.mapView.moveCamera(cameraUpdate)
    }

    /// 모든 경로 포인트를 포함하도록 카메라 시점을 조절.
    func moveCameraToFitBounds() {
        var bounds: NMGLatLngBounds = seoulBoudns

        if let startPoint, let endPoint {
            let boundPoints = [startPoint, endPoint]

            if let southWestLat = boundPoints.min(by: { $0.latitude < $1.latitude })?.latitude,
               let southWestLng = boundPoints.min(by: { $0.longitude < $1.longitude })?.longitude,
               let northEastLat = boundPoints.max(by: { $0.latitude < $1.latitude })?.latitude,
               let northEastLng = boundPoints.max(by: { $0.longitude < $1.longitude })?.longitude {

                bounds = NMGLatLngBounds(
                    southWestLat: southWestLat,
                    southWestLng: southWestLng,
                    northEastLat: northEastLat,
                    northEastLng: northEastLng
                )

            }
        }

        let cameraUpdate = NMFCameraUpdate(fit: bounds, paddingInsets: UIEdgeInsets(top: 250, left: 50, bottom: 50, right: 50))

        cameraUpdate.animation = .easeIn
        naverMapView.mapView.moveCamera(cameraUpdate)
    }

    /// 교통수단 타입에 따라 적절한 API를 호출하여 경로를 계산.
    func calcRoute(type: RouteOption, searchOption: SearchOption? = nil, startPoint: RouteLocation?, endPoint: RouteLocation?, intermediates: [RouteLocation]? = nil) async {
        guard let startPoint, let endPoint else {
            print("Parameter error")
            return
        }

        if let datas = routeCache[type], let _ = datas.first(where: { $0.searchOption == searchOption }) {
            drawMapOverlays(routeData: routeCache[type]!.first(where: { $0.searchOption == searchOption })!)
            return
        }

        switch type {
        case .drive, .walk:
            await calcRouteByTMap(type: type, searchOption: searchOption, startPoint: startPoint, endPoint: endPoint, intermediates: intermediates)
        case .transit:
            await calcRouteTransitByGoogle(startPoint: startPoint, endPoint: endPoint)
        }
    }

    /// Google Routes API를 통해 대중교통 경로를 계산하고 `routeCache`에 저장.
    func calcRouteTransitByGoogle(startPoint: RouteLocation, endPoint: RouteLocation) async {
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

            routeData.points.append(.init(latitude: startLocation.latitude, longitude: startLocation.longitude, type: .startLocation))

            let endLocation = leg.endLocation.latLng

            routeData.points.append(.init(latitude: endLocation.latitude, longitude: endLocation.longitude, type: .endLocation))

            // 연속된 도보 구간을 하나로 누적하기 위한 객체
            var acc: RouteData.Path? = nil

            for (index, step) in steps.enumerated() {
                if step.distanceMeters == nil && step.staticDuration == "0s" {
                    continue
                }
                var polyline: [RouteData.Coordinate] = []
                for coordinate in step.polyline.geoJSONLinestring.coordinates {
                    polyline.append(.init(latitude: coordinate[1], longitude: coordinate[0]))
                }

                // 대중교통 구간 처리
                if step.travelMode == "TRANSIT" {
                    if acc != nil {
                        routeData.paths.append(acc!)
                        acc = nil
                    }

                    let path = RouteData.Path(polyline: polyline, travelMode: RouteOption(rawValue: step.travelMode), detail: TransitDetailInfo(step: step))

                    routeData.paths.append(path)

                    // 도보 구간 처리
                } else if step.travelMode == "WALK" {
                    if acc != nil {

                        // 기존 도보 구간에 현재 도보 구간 정보 누적
                        acc?.detail?.distance += step.distanceMeters ?? 0

                        if let duration = Int(step.staticDuration.replacing(/[a-zA-Z]/, with: "")) {
                            acc?.detail?.duration += duration
                        }

                        if let instructions = step.navigationInstruction.instructions {
                            acc?.detail?.instructions?.append(instructions)
                        }

                        acc?.polyline.append(contentsOf: polyline)
                    } else {

                        // 새로운 도보 구간 시작
                        acc = RouteData.Path(polyline: polyline, travelMode: RouteOption(rawValue: step.travelMode), detail: TransitDetailInfo(step: step))

                        if index == 0, let departureName = pois.first?.name {
                            acc?.detail?.departureName = departureName
                        }

                        // 마지막 스텝이 도보일 경우, 누적된 정보를 경로에 추가
                        if index == steps.count - 1, let arrivalName = pois.last?.name {
                            acc?.detail?.arrivalName = arrivalName
                            routeData.paths.append(acc!)
                        }
                    }
                }
            }

            routeCache[.transit, default: []].append(routeData)
        }
    }

    /// TMap API를 통해 자동차/도보 경로를 계산하고 `routeCache`에 저장.
    func calcRouteByTMap(type: RouteOption, searchOption: SearchOption? = nil, startPoint: RouteLocation, endPoint: RouteLocation, intermediates: [RouteLocation]? = nil) async {
        let response: TMapRoutesApiResponseDto? = await RouteApiManager.shared.calcRouteByTMap(type: type, searchOption: searchOption, startPoint: startPoint, endPoint: endPoint, intermediates: intermediates)

        var routeData = RouteData()
        routeData.searchOption = searchOption

        if let features = response?.features {
            for feature in features {
                if feature.properties.index == nil { continue }

                // 경로 지점 정보 처리
                if feature.geometry.type == .point {
                    guard case let .double(longitude) = feature.geometry.coordinates[0],
                          case let .double(latitude) = feature.geometry.coordinates[1],
                          let pointType = feature.properties.pointType else {
                        continue
                    }

                    routeData.points.append(.init(latitude: latitude, longitude: longitude, type: pointType))

                    if let totalDistance = feature.properties.totalDistance {
                        routeData.totalDistance = totalDistance
                    }

                    if let totalTime = feature.properties.totalTime {
                        routeData.totalTime = totalTime
                    }

                    // 경로 선 정보 처리
                } else if feature.geometry.type == .lineString {
                    let coordinates = feature.geometry.coordinates

                    // 교통량 정보가 있는 경우, 각 구간을 색상이 다른 경로로 분리하여 저장
                    if let traffics = feature.geometry.traffic, !traffics.isEmpty {

                        for traffic in traffics {

                            let (startIndex, endIndex, trafficValue) = (traffic[0], traffic[1], traffic[2])

                            let polyline: [RouteData.Coordinate] = coordinates[startIndex...endIndex].compactMap {

                                guard case let .doubleArray(latLng) = $0 else { return nil }

                                return .init(latitude: latLng[1], longitude: latLng[0])
                            }

                            routeData.paths.append(.init(polyline: polyline, travelMode: type, traffic: .init(rawValue: trafficValue)))
                        }
                    } else {
                        // 교통량 정보가 없는 경우, 전체를 단일 경로로 저장
                        let polyline: [RouteData.Coordinate] = coordinates.compactMap {

                            guard case let .doubleArray(latLng) = $0 else { return nil }

                            return .init(latitude: latLng[1], longitude: latLng[0])
                        }

                        routeData.paths.append(.init(polyline: polyline, travelMode: type))
                    }
                }
            }
        }

        routeCache[type, default: []].append(routeData)
    }

    /// 지도에 그려진 마커와 경로를 모두 제거.
    func resetMapComponents() {
        multipartPath.mapView = nil

        for markerReference in self.markerReference {
            markerReference.mapView = nil
        }

        markerReference.removeAll()
    }

    /// `RouteData`를 기반으로 지도 위에 마커와 경로를 그림.
    func drawMapOverlays(routeData: RouteData) {
        resetMapComponents()

        drawPoints(points: routeData.points)
        drawPath(paths: routeData.paths)

        moveCameraToFitBounds()
    }

    /// 경로 지점들을 지도에 마커로 표시.
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

    /// 여러 구간으로 나뉜 경로를 `NMFMultipartPath`를 사용하여 색상과 함께 지도에 표시.
    func drawPath(paths: [RouteData.Path]) {
        var lineParts: [NMGLineString<AnyObject>] = []
        var colorParts: [NMFPathColor] = []

        for path in paths {
            let points = path.polyline.map { NMGLatLng(lat: $0.latitude, lng: $0.longitude) }

            lineParts.append(NMGLineString<AnyObject>(points: points))

            if let color = path.lineColor {
                colorParts.append(NMFPathColor(color: color))
            }
        }

        multipartPath.width = 8

        multipartPath.patternIcon = overlayImage
        multipartPath.patternInterval = 16

        multipartPath.lineParts = lineParts
        multipartPath.colorParts = colorParts

        multipartPath.mapView = naverMapView.mapView
    }
}

// MARK: - Extension : UITableViewDataSource
extension RouteMapViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == routeInfoTableView {
            return pois.count
        } else if tableView == transitDetailTableView {
            return routeCache[.transit]?[selectedSearchOption].paths.count ?? 0
        } else {
            return 0
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // 경로 정보 테이블 뷰 (장소 목록)
        if tableView == routeInfoTableView {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "RouteInfoTableViewCell", for: indexPath) as? RouteInfoTableViewCell else { return UITableViewCell() }

            let index = indexPath.row
            let routeInfo = pois[index]
            var image: UIImage? = UIImage(systemName: "target")?.withRenderingMode(.alwaysOriginal)

            // 인덱스에 따라 출발, 도착, 경유지 아이콘 색상 설정
            if index == 0 {
                image = image?.withTintColor(.mapPointGreen)
            } else if index == pois.count - 1 {
                image = image?.withTintColor(.mapPointRed)
            } else {
                image = image?.withTintColor(.mapPointGray)
            }

            cell.cellImageView.image = image
            cell.titleLabel.text = routeInfo.name

            return cell

            // 대중교통 상세 경로 테이블 뷰
        } else if tableView == transitDetailTableView {
            guard let selectedRouteOption, selectedRouteOption == .transit else {
                return UITableViewCell()
            }
            let path = routeCache[selectedRouteOption]?[selectedSearchOption].paths[indexPath.row]
            guard let cell = tableView.dequeueReusableCell(withIdentifier: TransitDetailTableViewCell.identifier, for: indexPath) as? TransitDetailTableViewCell else { return UITableViewCell() }

            // 출발지/도착지 이름이 있는 경우에만 해당 스택 뷰 표시
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

        // 현재 선택된 옵션에 해당하는 데이터 찾기
        let option = selectedRouteOption.searchOptions?[index]
        guard let data = routeCache[selectedRouteOption]?.first(where: { $0.searchOption == option }) else { return UICollectionViewCell() }

        // 선택된 셀에 테두리 강조 효과 적용
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

// MARK: - Extension : UICollectionViewDelegate
extension RouteMapViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedSearchOption = indexPath.item

        collectionView.scrollToItem(at: indexPath, at: .left, animated: true)

        collectionView.reloadData()
    }
}

// MARK: - Extension : NMFMapViewTouchDelegate
extension RouteMapViewController: NMFMapViewTouchDelegate {
    /// 지도 터치 시 전체화면 모드를 토글.
    func mapView(_ mapView: NMFMapView, didTapMap latlng: NMGLatLng, point: CGPoint) {
        isMapFullscreend.toggle()

        // 대중교통이 아닐 때, 또는 전체화면 모드일 때는 상세 정보 뷰를 숨김.
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

extension RouteMapViewController: CLLocationManagerDelegate {

    /// 위치 서비스 권한 상태가 변경될 때 호출.
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedWhenInUse: // 위치 서비스를 사용 가능한 상태
            print("위치 서비스 사용 가능")
            locationManager.requestLocation()
            break
        case .restricted, .denied: // 위치 서비스를 사용 가능하지 않은 상태
            print("위치 서비스 사용 불가")
            break
        case .notDetermined: // 권한 설정이 되어 있지 않은 상태
            print("권한 설정 필요")
            locationManager.requestWhenInUseAuthorization() // 권한 요청
            break
        default:
            break
        }
    }

    /// 위치 정보가 업데이트될 때 호출.
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let coordinate = locations.last?.coordinate {
            // 위치 기반 코스 목록이 아직 호출되지 않았을 경우에만 API 호출 실행.
            if isFetchedLocationList { return }

            isFetchedLocationList = true

            if pois.count == 1 {
                let currentLocation = POI(context: CoreDataManager.shared.context)

                currentLocation.name = "현재 위치"
                currentLocation.latitude = coordinate.latitude
                currentLocation.longitude = coordinate.longitude

                pois.insert(currentLocation, at: 0)
                
                setup()
            }
        }
    }

    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location manager failed with error: \(error.localizedDescription)")
    }
}
