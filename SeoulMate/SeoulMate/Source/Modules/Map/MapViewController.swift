//
//  MapViewController.swift
//  SeoulMate
//
//  Created by 하재준 on 6/7/25.
//

import UIKit
import NMapsMap
import CoreLocation
import CoreData

class MapViewController: UIViewController {
    
    
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var myMapView: NMFNaverMapView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var upDownButton: UIButton!
    @IBOutlet weak var travelPeriodLabel: UILabel!
    @IBOutlet weak var travleTitleLabel: UILabel!
    @IBOutlet weak var daysLabel: UILabel!
    
    @IBAction func upDownAction(_ sender: Any) {
        
        UIView.animate(withDuration: 0.3) {
            self.myMapView.isHidden.toggle()
            if self.stackView.isHidden {
                self.stackView.isHidden = false
            }
        }
        
        self.myMapView.isHidden ? self.upDownButton.setImage(UIImage(systemName: "chevron.down"), for: .normal) : self.upDownButton.setImage(UIImage(systemName: "chevron.up"), for: .normal)
        
    }
    @IBAction func saveAction(_ sender: Any) {
        CoreDataManager.shared.saveContext()
        tableView.setEditing(false, animated: true)
        cameBackFromSearch = false
        saveButton.isHidden = true
        editButtonVisibility()
    }
    @IBAction func editAction(_ sender: UIButton) {
        
        if tableView.isEditing {
            tableView.setEditing(false, animated: true)
            sender.setTitle("편집", for: .normal)
        } else {
            tableView.setEditing(true, animated: true)
            sender.setTitle("완료", for: .normal)
        }
        CoreDataManager.shared.saveContext()
        tableView.reloadData()
    }
    private var cameBackFromSearch = false
    var isMapViewHidden = false
    var lastMarker: NMFMarker?
    var markersArray: [NMFMarker] = []
    let pathOverlay = NMFPath()
    private var scheduleItemsArray: [[POI]] = []
    
    var sortedDates: [Date] = []
    private var context: NSManagedObjectContext {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            fatalError()
        }
        return appDelegate.persistentContainer.viewContext
    }
    var tour: Tour?
    let latLngOfLastMarker: NMGLatLng? = nil
    let circleColor = UIColor(red: 0.58, green: 0.78, blue: 0.98, alpha: 1.0)
    var opacity: Double = 0
    var radius: Double = 10
    var counter: Int = 0
    var circleTimer: CADisplayLink?
    let locationManager: CLLocationManager = CLLocationManager()
    
    var selectedDays: [String] = []
    
    let colorArray: [UIColor] = [.mapPointGreen, .mapPointGray, .mapPointRed]
    
    private var sortedSchedules: [Schedule] = []
    private var poisByDay: [[POI]] = []
    private var coordsByDay: [[NMGLatLng]] = []
    
    
    var currentTopSection: Int?
    private var isMarkerScroll = false
    var pendingIndexPath: IndexPath?
    var currentTopIndexPath: IndexPath?
    
    var scehduels: [[Schedule]] = []
    
    
    var allSchedules: [Schedule] = []
    var allTours: [Tour] = []
    var allPois: [POI] = []
    
    
    private let fullFormatter: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "ko_KR")
        f.dateFormat = "yyyy.MM.dd"
        return f
    }()
    
    
    private let shortFormatter: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "ko_KR")
        f.dateFormat = "M.d"
        return f
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadTourData()

       
        
        // CoreLocation
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        
        myMapView.mapView.touchDelegate = self
        
        
        tableView.dataSource = self
        tableView.delegate = self
        
        
        
        myMapView.showLocationButton = true
        myMapView.showCompass = true
        myMapView.mapView.positionMode = .direction
        
        
        
        // 현재 위치 표시
        let locationOverlay = myMapView.mapView.locationOverlay
        let coord: NMGLatLng = locationOverlay.location
        locationOverlay.location = coord
        locationOverlay.circleOutlineWidth = 0
        locationOverlay.hidden = false
        locationOverlay.icon = NMFOverlayImage(name: "imgLocationDirection", in: Bundle.naverMapFramework())
        locationOverlay.subIcon = nil
        locationOverlay.circleColor = circleColor
        weak var weakSelf = self
        locationOverlay.touchHandler = { Bool in
            weakSelf?.circleAnimation(true)
            return true
        }
        
        // 지도 제한
        let seoulBounds = NMGLatLngBounds(
            southWestLat: 37.413294,
            southWestLng: 126.734086,
            northEastLat: 37.715133,
            northEastLng: 127.269311
        )
        
        myMapView.mapView.extent = seoulBounds
        myMapView.mapView.moveCamera(NMFCameraUpdate(fit: seoulBounds, padding: 24))
        let polylineOverlay = NMFPolylineOverlay([seoulBounds.southWest,
                                                  NMGLatLng(lat: seoulBounds.southWestLat, lng: seoulBounds.northEastLng),
                                                  seoulBounds.northEast,
                                                  NMGLatLng(lat: seoulBounds.northEastLat, lng: seoulBounds.southWestLng),
                                                  seoulBounds.southWest])
        polylineOverlay?.color = .main
        polylineOverlay?.mapView = myMapView.mapView
        

        let footer = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: self.view.bounds.height / 2))
        
        footer.backgroundColor = .clear
        tableView.tableFooterView = footer
      
        tableView.reloadData()
        let coords = coordsByDay.first ?? []
        makePath(for: 0, with: coords)
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
        
        if cameBackFromSearch {
            saveButton.isHidden = false
            tableView.setEditing(true, animated: true)
            cameBackFromSearch = false
        } else {
            saveButton.isHidden = true
        }
        
        circleTimer = CADisplayLink(target: self, selector: #selector(updateCircle))
        circleTimer?.preferredFramesPerSecond = 20
        
        circleTimer?.add(to: RunLoop.current, forMode: RunLoop.Mode.default)
        circleTimer?.isPaused = true
        
        
        tableView.reloadData()
        
        
    }
    
    func editButtonVisibility() {
        if poisByDay.allSatisfy({ $0.isEmpty }) {
            editButton.isHidden = true
        } else {
            editButton.isHidden = false
        }
    }
    
    
    private func loadTourData() {
        guard let tour = tour else { return }

        let schedules = (tour.days as? Set<Schedule> ?? [])
            .compactMap { $0.date != nil ? $0 : nil }
            .sorted { $0.date! < $1.date! }
        self.sortedSchedules = schedules
        sortedDates = schedules.map { Calendar.current.startOfDay(for: $0.date!) }

        self.poisByDay = schedules.map { schedule in
            return (schedule.pois?.array as? [POI]) ?? []
        }

        self.coordsByDay = poisByDay.map { $0.map { NMGLatLng(lat: $0.latitude, lng: $0.longitude) } }

        updateTravelPeriodLabel()
        updateTravelTitleLabel()
        editButtonVisibility()
        updateDaysLabel(for: 0)

    }
    
    
    func addPOI(_ poi: POI, toDay dayIndex: Int) {
        guard dayIndex >= 0 && dayIndex < poisByDay.count else {
            return
        }
        let schedule = sortedSchedules[dayIndex]
        schedule.addToPois(poi)
        
        poisByDay[dayIndex].append(poi)
        
        tableView.reloadSections(IndexSet(integer: dayIndex), with: .automatic)
        
        let coords = poisByDay[dayIndex]
            .map { NMGLatLng(lat: $0.latitude, lng: $0.longitude) }
        makePath(for: dayIndex, with: coords)
    }
    
    func makePath(for section: Int, with coords: [NMGLatLng]) {
        pathOverlay.mapView = nil
        markersArray.forEach { $0.mapView = nil }
        markersArray.removeAll()
        
        guard !coords.isEmpty else { return }
        
        let points = coords.map { $0 as AnyObject }
        pathOverlay.path = NMGLineString(points: points)
        pathOverlay.width = 8
        pathOverlay.color = .main
        pathOverlay.outlineWidth = 0
        pathOverlay.patternIcon = NMFOverlayImage(name: "route_path_arrow")
        pathOverlay.patternInterval = 10
        if coords.count > 1 {
            pathOverlay.mapView = myMapView.mapView
        }
        
        for (i, coord) in coords.enumerated() {
            let marker = NMFMarker(position: coord)
            marker.mapView = myMapView.mapView
            
            marker.captionText = "\(i + 1)"
            marker.captionTextSize = 14
            marker.captionColor = .main
            
            let color = getColor(at: i, totalCount: coords.count)
            marker.iconImage = NMF_MARKER_IMAGE_BLACK
            marker.iconTintColor = color
            
            marker.touchHandler = { _ in
                let ip = IndexPath(row: i, section: section)
                self.tableView.scrollToRow(at: ip, at: .top, animated: true)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    let update = NMFCameraUpdate(scrollTo: coord)
                    update.animation = .easeIn
                    self.myMapView.mapView.moveCamera(update)
                }
                return true
            }
            
            markersArray.append(marker)
        }
    }
 
    private func updateTravelTitleLabel() {
        
        let tourTitle = "서울 여행"
        
        
        let allPois: [POI] = poisByDay.flatMap { $0 }
        //        print("allpois: \(allPois)")
        guard let firstPoi = allPois.first,
              let poiName = firstPoi.name else {
            travleTitleLabel.text = tourTitle
            return
        }
        let extraCount = allPois.count - 1
        
        if extraCount > 0 {
            let fullText = "\(tourTitle) \(poiName) 외 \(extraCount)곳"
            let suffix = "\(poiName) 외 \(extraCount)곳"
            
            let attributed = NSMutableAttributedString(
                string: fullText,
                attributes: [
                    .font: UIFont.systemFont(ofSize: 20),
                    .foregroundColor: UIColor.label
                ]
            )
            
            if let range = fullText.range(of: suffix) {
                let nsRange = NSRange(range, in: fullText)
                attributed.addAttributes([
                    .font: UIFont.systemFont(ofSize: 16),
                    .foregroundColor: UIColor.secondaryLabel
                ], range: nsRange)
            }
            
            travleTitleLabel.attributedText = attributed
        }
    }
    
    
    private func updateTravelPeriodLabel() {
        guard
            let tour = tour,
            let startRaw = tour.startDate,
            let endRaw   = tour.endDate
        else {
            travelPeriodLabel.text = "기간 정보 없음"
            return
        }
        
        let start = Calendar.current.startOfDay(for: startRaw)
        let end   = Calendar.current.startOfDay(for: endRaw)
        
        let firstStr = fullFormatter.string(from: start)
        let lastStr: String
        
        if start == end {
            travelPeriodLabel.text = firstStr
            return
        }
        
        if Calendar.current.component(.year, from: start)
            == Calendar.current.component(.year, from: end) {
            lastStr = shortFormatter.string(from: end)
        } else {
            lastStr = fullFormatter.string(from: end)
        }
        
        travelPeriodLabel.text = "\(firstStr) ~ \(lastStr)"
    }
    
    
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        circleTimer?.invalidate()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        
        if let vc = segue.destination as? DetailSheetViewController {
            guard let indexPath = tableView.indexPathForSelectedRow else { return }
            
            vc.pois = poisByDay[indexPath.section]
            vc.delegate = self
        }
        
        
        
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        tableView.setEditing(editing, animated: animated)
    }
    
    func circleAnimation(_ animated: Bool) {
        let locationOverlay = myMapView.mapView.locationOverlay
        opacity = 1
        radius = 10
        locationOverlay.circleRadius = 0
        
        if animated {
            circleTimer?.isPaused = false
            counter = 0
        } else {
            circleTimer?.isPaused = true
        }
    }
    
    
    @objc func updateCircle() {
        let locationOverlay = myMapView.mapView.locationOverlay
        let duration = circleTimer?.duration ?? 0
        let constantValue = duration * 250
        radius += 1.0 * constantValue;
        opacity -= 0.02 * constantValue;
        
        locationOverlay.circleRadius = CGFloat(radius)
        locationOverlay.circleColor = circleColor.withAlphaComponent(CGFloat(opacity))
        if radius > 50.0 {
            radius = 10;
            opacity = 1;
            counter += 1
            if counter > 2 {
                counter = 0
                circleAnimation(false)
            }
        }
    }
    
    func getColor(at index: Int, totalCount: Int) -> UIColor {
        if index == 0 {
            return .mapPointGreen
        } else if index == totalCount - 1 {
            return .mapPointRed
        } else {
            return .mapPointGray
        }
    }
    
    
    
    func checkUserCurrentLocationAuthorization(_ status: CLAuthorizationStatus) {
        switch status {
        case .notDetermined:
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.requestWhenInUseAuthorization()
            
        case .denied, .restricted:
            showRequestLocationServiceAlert()
            
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.startUpdatingLocation()
            
        default:
            break
        }
    }
    
    func checkUserDeviceLocationServiceAuthorization() {
        DispatchQueue.global().async {
            guard CLLocationManager.locationServicesEnabled() else {
                // 시스템 설정으로 유도하는 커스텀 얼럿
                self.showRequestLocationServiceAlert()
                return
            }
            
            
            let authorizationStatus: CLAuthorizationStatus
            
            // 앱의 권한 상태 가져오는 코드
            authorizationStatus = self.locationManager.authorizationStatus
            
            
            // 권한 상태값에 따라 분기처리를 수행하는 메서드 실행
            self.checkUserCurrentLocationAuthorization(authorizationStatus)
            
        }
    }
    
    private func updateDaysLabel(for section: Int) {
        guard section >= 0,
              section < sortedDates.count else {
            daysLabel.text = ""
            return
        }
        let dayNumber = section + 1
        let sectionDate = sortedDates[section]
        let dateStr = shortFormatter.string(from: sectionDate)
        let prefix = "Day \(dayNumber) "
        let suffix = "/ \(dateStr)"
        let fullText = prefix + suffix
        
        let attributed = NSMutableAttributedString(
            string: fullText,
            attributes: [
                .font: UIFont.systemFont(ofSize: 20),
                .foregroundColor: UIColor.label
            ]
        )
        
        if let range = fullText.range(of: suffix) {
            let nsRange = NSRange(range, in: fullText)
            attributed.addAttributes([
                .font: UIFont.systemFont(ofSize: 16),
                .foregroundColor: UIColor.secondaryLabel
            ], range: nsRange)
        }
        
        daysLabel.attributedText = attributed
        
        
    }
    
    
    
    func showRequestLocationServiceAlert() {
        let requestLocationServiceAlert = UIAlertController(title: "위치 정보 이용", message: "위치 서비스를 사용할 수 없습니다.\n디바이스의 '설정 > 개인정보 보호'에서 위치 서비스를 켜주세요.", preferredStyle: .alert)
        let goSetting = UIAlertAction(title: "설정으로 이동", style: .destructive) { _ in
            if let appSetting = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(appSetting)
            }
        }
        let cancel = UIAlertAction(title: "취소", style: .default) { [weak self] _ in
            self?.locationManager.startUpdatingLocation()
        }
        
        requestLocationServiceAlert.addAction(cancel)
        requestLocationServiceAlert.addAction(goSetting)
        
        present(requestLocationServiceAlert, animated: true)
    }
    
    
    @objc func footerButtonTapped(_ sender: UIButton) {
        let section = sender.tag
        print("Button tapped in section \(section)")
        
    }
    
    
    
}


extension MapViewController: NMFAuthManagerDelegate {
    func authorized(_ state: NMFAuthState, error: (any Error)?) {
        switch state {
        case .authorized:
            print("인증완료")
        case .unauthorized:
            print("인증 실패")
        default:
            break
        }
    }
}

extension MapViewController: NMFMapViewTouchDelegate {
    func mapView(_ mapView: NMFMapView, didTapMap latlng: NMGLatLng, point: CGPoint) {
        let latitude = latlng.lat
        let longitutde = latlng.lng
        print("latitude: \(latitude), longitutde: \(longitutde)")
        UIView.animate(withDuration: 0.3) {
            self.stackView.isHidden.toggle()
            
        }
        
        
        
        
    }
}

extension MapViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        let latitude = location.coordinate.latitude
        let longitude = location.coordinate.longitude
        
        let update = NMFCameraUpdate(scrollTo: NMGLatLng(lat: latitude, lng: longitude))
        update.animation = .easeIn
        myMapView.mapView.moveCamera(update)
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        checkUserDeviceLocationServiceAuthorization()
    }
    
    
}

extension MapViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return sortedSchedules.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return poisByDay[section].count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        let isLastRow = indexPath.row == poisByDay[indexPath.section].count
        
        if isLastRow {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "addButtonCell", for: indexPath) as? AddPlaceButtonCell else { return UITableViewCell() }
            cell.delegate = self
            cell.addButton.tag = indexPath.section
            cell.routeButton.tag = indexPath.section
            return cell
        } else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "placeInfoCell", for: indexPath) as? MapTableViewCell else { return UITableViewCell() }
            
            cell.numberLabel.text = "\(indexPath.row + 1)"
            cell.placeTitleLabel.text = poisByDay[indexPath.section][indexPath.row].name ?? ""
            cell.placeCategoryLabel.text = poisByDay[indexPath.section][indexPath.row].category ?? ""
            cell.numberView.backgroundColor = .main
            return cell
            
        }
        
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return indexPath.row < poisByDay[indexPath.section].count
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let schedule = sortedSchedules[indexPath.section]
            let poi = poisByDay[indexPath.section][indexPath.row]
            schedule.removeFromPois(poi)
            CoreDataManager.shared.delete(poi)
            poisByDay[indexPath.section].remove(at: indexPath.row)
            tableView.reloadSections(IndexSet(integer: indexPath.section), with: .automatic)
            makePath(for: indexPath.section, with: coordsByDay[indexPath.section])
            editButtonVisibility()
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let vc = storyboard?.instantiateViewController(withIdentifier: "DetailSheetViewController") as? DetailSheetViewController else { return }
        vc.place = poisByDay[indexPath.section][indexPath.row].name ?? ""
        vc.placeCategory = poisByDay[indexPath.section][indexPath.row].category ?? ""
        vc.placeOpenTime = poisByDay[indexPath.section][indexPath.row].openingHours ?? ""
        vc.pois = poisByDay[indexPath.section]
        vc.selectedRow = indexPath.row
        vc.delegate = self
        if let presentationController = vc.presentationController as? UISheetPresentationController {
            let small = UISheetPresentationController.Detent.custom(identifier: .init(rawValue: "small")) { context in
                return context.maximumDetentValue * 0.33
            }
            
            presentationController.detents = [small]
        }
        self.present(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView,
                   moveRowAt sourceIndexPath: IndexPath,
                   to destinationIndexPath: IndexPath) {
        let poi = poisByDay[sourceIndexPath.section][sourceIndexPath.row]
        let srcSched = sortedSchedules[sourceIndexPath.section]
        let dstSched = sortedSchedules[destinationIndexPath.section]
        srcSched.removeFromPois(poi)
        dstSched.insertIntoPois(poi, at: destinationIndexPath.row)
        CoreDataManager.shared.saveContext()
        
        poisByDay[sourceIndexPath.section].remove(at: sourceIndexPath.row)
        poisByDay[destinationIndexPath.section].insert(poi, at: destinationIndexPath.row)
        tableView.reloadData()
        
    }

    
    func tableView(_ tableView: UITableView, targetIndexPathForMoveFromRowAt sourceIndexPath: IndexPath, toProposedIndexPath proposedDestinationIndexPath: IndexPath) -> IndexPath {
        let section = proposedDestinationIndexPath.section
        let maxRow = poisByDay[section].count - 1
        let row = min(proposedDestinationIndexPath.row, maxRow)
        return IndexPath(row: row, section: section)
    }
    
    func tableView(_ tableView: UITableView,
                   heightForFooterInSection section: Int) -> CGFloat {
        if section == poisByDay.count - 1 {
            return 0
        }
        return 10
    }
    
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        guard section < poisByDay.count - 1 else { return nil }
        
        let footerView = UIView()
        let separator = UIView()
        
        separator.backgroundColor = .lightGray
        separator.alpha = 0.7
        separator.translatesAutoresizingMaskIntoConstraints = false
        footerView.addSubview(separator)
        
        NSLayoutConstraint.activate([
            separator.heightAnchor.constraint(equalToConstant: 0.5),
            separator.leadingAnchor.constraint(equalTo: footerView.leadingAnchor, constant: 16),
            separator.trailingAnchor.constraint(equalTo: footerView.trailingAnchor, constant: -16),
            separator.bottomAnchor.constraint(equalTo: footerView.bottomAnchor)
        ])
        
        return footerView
        
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        guard isMarkerScroll, let top = pendingIndexPath else { return }
        
        isMarkerScroll = false
        pendingIndexPath = nil
        
        let poi = poisByDay[top.section][top.row]
        let coord = NMGLatLng(lat: poi.latitude, lng: poi.longitude)
        
        let update = NMFCameraUpdate(scrollTo: coord)
        update.animation = .easeIn
        myMapView.mapView.moveCamera(update)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if isMarkerScroll { return }
        guard let tableView = scrollView as? UITableView else { return }
        
        //화면 상단에 가장 가까운 셀 찾기
        guard let indexPaths = tableView.indexPathsForVisibleRows else { return }
        
        let topIndexPath = indexPaths.min(by: {
            let cellFrame0 = tableView.rectForRow(at: $0)
            let cellFrame1 = tableView.rectForRow(at: $1)
            
            let y0 = tableView.convert(cellFrame0, to: tableView.superview).minY
            let y1 = tableView.convert(cellFrame1, to: tableView.superview).minY
            
            return y0 < y1
        })
        
        if let top = topIndexPath {
            let coords = poisByDay[top.section]
                .map { NMGLatLng(lat: $0.latitude, lng: $0.longitude) }
            
            makePath(for: top.section, with: coords)
            
            updateDaysLabel(for: top.section)
            
            guard let top = topIndexPath,
                  top != currentTopIndexPath else { return }
            let lastRowIndex = poisByDay[top.section].count
            guard top.row < lastRowIndex else {
                currentTopIndexPath = top
                return
            }
            currentTopIndexPath = top
            let poi = poisByDay[top.section][top.row]
            let coord = NMGLatLng(lat: poi.latitude, lng: poi.longitude)
            let update = NMFCameraUpdate(scrollTo: coord)
            update.animation = .easeIn
            self.myMapView.mapView.moveCamera(update)
            
        }
    }
    
}

extension MapViewController: AddPlaceButtonCellDelegate {
    func addPlace(_ cell: AddPlaceButtonCell) {
        let storyboard = UIStoryboard(name: "Search", bundle: nil)
        if let vc = storyboard.instantiateViewController(withIdentifier: "SearchVC") as? SearchViewController {
            navigationController?.pushViewController(vc, animated: true)
            navigationController?.navigationBar.isHidden = true
            let dayIndex = cell.addButton.tag
            vc.POIsBackToVC = { [weak self] returnedPois in
                returnedPois.forEach { i in
                    self?.addPOI(i, toDay: dayIndex)
                }
            }
            cameBackFromSearch = true
        }
    }
    
    func goToRoute(_ cell: AddPlaceButtonCell) {
        let dayIndex = cell.routeButton.tag
        let pois = poisByDay[dayIndex]

        if pois.count > 5 {
            setupNoRouteAlert()
        } else {
            let storyboard = UIStoryboard(name: "RouteMap", bundle: nil)

            if let vc = storyboard.instantiateViewController(withIdentifier: "RouteMap") as? RouteMapViewController {
                vc.pois = pois
                navigationController?.pushViewController(vc, animated: true)
            }
        }
    }

    func setupNoRouteAlert() {
        let noRouteAlert = UIAlertController(
            title: "죄송합니다.",
            message: "경로 탐색은 한번에 5개의 장소까지만 지원합니다.\n일정 조정 후 다시 시도해 주세요",
            preferredStyle: .alert
        )

        let confirm = UIAlertAction(title: "확인", style: .default)

        noRouteAlert.addAction(confirm)

        present(noRouteAlert, animated: true)
    }
}

extension MapViewController: DetailSheetDelegate {
    func detailSheetGoToDetail(_ sheet: DetailSheetViewController) {
        let poi = sheet.pois[sheet.selectedRow]
        let storyboard = UIStoryboard(name: "POIDetail", bundle: nil)
        if let vc = storyboard.instantiateViewController(withIdentifier: "POIDetailView") as? POIDetailViewController {
            vc.nameLabel = poi.placeID ?? ""
            vc.latitude = poi.latitude
            vc.longtitude = poi.longitude
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    
}
