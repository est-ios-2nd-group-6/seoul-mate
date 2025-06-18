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
        do {
            try context.save()
            
            tableView.setEditing(false, animated: true)
            cameBackFromSearch = false
            saveButton.isHidden = true
        } catch {
            print("saveerror:", error)
        }
    }
    @IBAction func editAction(_ sender: UIButton) {
        if tableView.isEditing {
            // 1) Core Data 저장
            do {
                try context.save()
                print("저장했따리")
            } catch {
                print("Core Data 저장 실패:", error)
            }
            
         
            
            // 3) poisByDay / coordsByDay 재구성
            fetchTourData()
            
            tableView.setEditing(false, animated: true)
            sender.setTitle("편집", for: .normal)
        } else {
            tableView.setEditing(true, animated: true)
            sender.setTitle("완료", for: .normal)
        }

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
    var lastColor: UIColor?
    var colorSequence: [UIColor] = []
    
    private var poisByDay: [[POI]] = []
    private var schedules: [Schedule] = []
    private var coordsByDay: [[NMGLatLng]] = []
    
    let defaultDistanceStrategy = NMCDefaultDistanceStrategy()
    
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
        
        // 경로 표시
        
        
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
        
        
        // 추가 스크롤을 위한 footer
        let footer = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: self.view.bounds.height / 2))
        
        footer.backgroundColor = .clear
        tableView.tableFooterView = footer
        
        
        
        
        
        
        fetchTourData()
        tableView.reloadData()
        let coords = coordsByDay.first ?? []
        makePath(for: 0, with: coords)
        updateDaysLabel(for: 0)
        updateEditButtonVisibility()
        updateTravelPeriodLabel()
        updateTravelTitleLabel()
        
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchTourData()
        
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
        
        updateEditButtonVisibility()
    }
    
    
    private func fetchTourData() {
        guard let tour = self.tour else { return }
        let fetched = CoreDataManager.shared.fetchSchedules(for: tour)
        schedules = fetched
        
        sortedDates = fetched.compactMap {
            $0.date.map { Calendar.current.startOfDay(for: $0) }
        }
        
        poisByDay = fetched.map { sched in
            CoreDataManager.shared.fetchPOIs(for: sched)
                .sorted { ($0.name ?? "") < ($1.name ?? "") }
        }
        
        coordsByDay = poisByDay.map { $0.map { NMGLatLng(lat: $0.latitude, lng: $0.longitude) } }
    }
    
    
    func addPOI(_ poi: POI, toDay dayIndex: Int) {
        guard dayIndex >= 0 && dayIndex < scheduleItemsArray.count else {
            return
        }
        
        scheduleItemsArray[dayIndex].append(poi)
        
        tableView.reloadSections(IndexSet(integer: dayIndex), with: .automatic)
        
        let coords = scheduleItemsArray[dayIndex]
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
    
    
    
    //
    //
    //    private func fetchSchedules() {
    //        let scheduleRequest: NSFetchRequest<Schedule> = Schedule.fetchRequest()
    //        scheduleRequest.sortDescriptors = [
    //            NSSortDescriptor(key: "date", ascending: true)
    //        ]
    //
    //        do {
    //            allSchedules = try context.fetch(scheduleRequest)
    //            print("All Schduels: \(allSchedules.count)개")
    //        } catch {
    //            print("❌ 스케줄 fetch 실패:", error)
    //        }
    //    }
    //    private func fetchTours() {
    //        let tourRequest: NSFetchRequest<Tour> = Tour.fetchRequest()
    //        tourRequest.sortDescriptors = [
    //            NSSortDescriptor(key: "startDate", ascending: true)
    //        ]
    //        do {
    //            allTours = try context.fetch(tourRequest)
    //            print("All Tours: \(allTours.count)")
    //        } catch {
    //            print(error)
    //        }
    //    }
    //
    //    private func fetchPois() {
    //        let poiRequest: NSFetchRequest<POI> = POI.fetchRequest()
    //        poiRequest.sortDescriptors = [
    //            // Schedule 객체의 date 속성을 기준으로 정렬
    //            NSSortDescriptor(key: "schedule.date", ascending: true),
    //        ]
    //
    //        do {
    //            allPois = try context.fetch(poiRequest)  // [POI]
    //            print(" 전체 POI (\(allPois.count)")
    //        } catch {
    //            print(error)
    //        }
    //    }
    
    //    private func fetchTourData() {
    //        guard let tour = tour else {
    //            scheduleItemsArray = []
    //            return
    //        }
    //        // 1) 날짜 순 Schedule
    //        let schedules = (tour.days as? Set<Schedule> ?? [])
    //            .compactMap { $0.date != nil ? $0 : nil }
    //            .sorted { $0.date! < $1.date! }
    //
    //        // 2) 섹션용 날짜 리스트
    //        sortedDates = schedules.map { Calendar.current.startOfDay(for: $0.date!) }
    //
    //        // 3) Schedule → [POI] 그룹핑
    //        let grouped: [Date: [POI]] = Dictionary(
    //            uniqueKeysWithValues: schedules.map { sched in
    //                let day = Calendar.current.startOfDay(for: sched.date!)
    //                let pois = (sched.pois as? Set<POI> ?? [])
    //                    .sorted { ($0.name ?? "") < ($1.name ?? "") }
    //                return (day, pois)
    //            }
    //        )
    //
    //        scheduleItemsArray = sortedDates.map { grouped[$0] ?? [] }
    //
    //        updateTravelTitleLabel()
    //    }
    
    
    
    
    
    private func updateTravelTitleLabel() {
        
        let tourTitle = "서울 여행"
        
        
        let allPois: [POI] = poisByDay.flatMap { $0 }
        print("allpois: \(allPois)")
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
    
    private func updateEditButtonVisibility() {
        let allEmpty = poisByDay.allSatisfy { $0.isEmpty }
        editButton.isHidden = allEmpty
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
            //            self.upDownButton.isHidden.toggle()
            //            if self.stackView.isHidden == false {
            //                self.tableView.reloadData()
            //            }
            
        }
        print("스택뷰 히든 = ", stackView.isHidden)
        
        
        
        
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
        //        locationManager.stopUpdatingLocation()
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        checkUserDeviceLocationServiceAuthorization()
    }
}

extension MapViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return sortedDates.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return poisByDay[section].count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        let isLastRow = indexPath.row == poisByDay[indexPath.section].count
        
        if isLastRow {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "addButtonCell", for: indexPath) as? AddPlaceButtonCell else { return UITableViewCell() }
            cell.delegate = self
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
            CoreDataManager.shared.delete(poisByDay[indexPath.section][indexPath.row])
            poisByDay[indexPath.section].remove(at: indexPath.row)
            fetchTourData()
            tableView.reloadSections(IndexSet(integer: indexPath.section), with: .automatic)
            
            let coords = poisByDay[indexPath.section]
                .map { NMGLatLng(lat: $0.latitude, lng: $0.longitude) }
            
            makePath(for: indexPath.section, with: coords)
            updateEditButtonVisibility()
            
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
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let movedPOI = poisByDay[sourceIndexPath.section].remove(at: sourceIndexPath.row)
        poisByDay[destinationIndexPath.section].insert(movedPOI, at: destinationIndexPath.row)
        
        makePath(for: destinationIndexPath.section,
                 with: coordsByDay[destinationIndexPath.section])
        
        tableView.reloadSections(
            IndexSet([sourceIndexPath.section, destinationIndexPath.section]),
            with: .automatic
        )
    }
    
    func tableView(_ tableView: UITableView, targetIndexPathForMoveFromRowAt sourceIndexPath: IndexPath, toProposedIndexPath proposedDestinationIndexPath: IndexPath) -> IndexPath {
        let section = proposedDestinationIndexPath.section
        let maxRow = poisByDay[section].count
        let row = min(proposedDestinationIndexPath.row, maxRow)
        return IndexPath(row: row, section: section)
    }
    
    func tableView(_ tableView: UITableView,
                   heightForFooterInSection section: Int) -> CGFloat {
        return 0.5
    }
    
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        
        let isLastSection = section == poisByDay.count - 1
        
        if isLastSection {
            return UIView()
        } else {
            let separator = UIView()
            separator.backgroundColor = .gray
            separator.layer.opacity = 0.5
            return separator
        }
        
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
            print("addplacebuttoncell")
            navigationController?.pushViewController(vc, animated: true)
            navigationController?.navigationBar.isHidden = true
            let dayIndex = cell.addButton.tag
            // TODO: - 데이터 받아오기
            let newPoi = POI(context: context)
            
            cameBackFromSearch = true
            addPOI(newPoi, toDay: dayIndex)
        }
    }
    
    func goToRoute(_ cell: AddPlaceButtonCell) {
        let dayIndex = cell.routeButton.tag
        let pois = poisByDay[dayIndex]
        let storyboard = UIStoryboard(name: "RouteMap", bundle: nil)
        if let vc = storyboard.instantiateViewController(withIdentifier: "RouteMap") as? RouteMapViewController {
            vc.pois = pois
            navigationController?.pushViewController(vc, animated: true)
        }
    }
}

extension MapViewController: DetailSheetDelegate {
    func detailSheetGoToDetail(_ sheet: DetailSheetViewController) {
        let poi = sheet.pois[sheet.selectedRow]
        let storyboard = UIStoryboard(name: "POIDetail", bundle: nil)
        if let vc = storyboard.instantiateViewController(withIdentifier: "POIDetailView") as? POIDetailViewController {
            vc.id = poi.name
            vc.latitude = poi.latitude
            vc.longtitude = poi.longitude
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func detailSheetGoToRoute(_ sheet: DetailSheetViewController, didRequestRouteFor pois: [POI]) {
        let storyboard = UIStoryboard(name: "RouteMap", bundle: nil)
        if let vc = storyboard.instantiateViewController(withIdentifier: "RouteMap") as? RouteMapViewController {
            vc.pois = pois
            navigationController?.pushViewController(vc, animated: true)
        }
    }
}

//extension MapViewController: NSFetchedResultsControllerDelegate {
//    func controllerWillChangeContent(_ controller: NSFetchedResultsController<any NSFetchRequestResult>) {
//        tableView.beginUpdates()
//    }
//
//    func controller(_ controller: NSFetchedResultsController<any NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
//        switch type {
//        case .insert:
//            if let insertIndexPath = newIndexPath {
//                tableView.insertRows(at: [insertIndexPath], with: .automatic)
//            }
//        case .delete:
//            if let deleteIndexPath = indexPath {
//                tableView.deleteRows(at: [deleteIndexPath], with: .automatic)
//            }
//        case .update:
//            if let updateIndexPath = indexPath {
//                tableView.reloadRows(at: [updateIndexPath], with: .automatic)
//            }
//        case .move:
//            if let originalIndexPath = indexPath, let targetIndexPath = newIndexPath {
//                tableView.moveRow(at: originalIndexPath, to: targetIndexPath)
//            }
//        default:
//            break
//        }
//    }
//
//    func controllerDidChangeContent(_ controller: NSFetchedResultsController<any NSFetchRequestResult>) {
//        tableView.endUpdates()
//    }
//}
