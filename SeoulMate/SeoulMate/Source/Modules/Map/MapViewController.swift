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
            let req: NSFetchRequest<POI> = POI.fetchRequest()
            // (필요하다면 predicate로 오늘 날짜 등 조건 추가)
            let savedPOIs = try context.fetch(req)
            print("▶️ 현재 저장된 POI 개수: \(savedPOIs.count)")
            savedPOIs.forEach { poi in
                print("   • \(poi.name ?? "이름없음") @ (\(poi.latitude), \(poi.longitude))")
            }


            tableView.setEditing(false, animated: true)
            cameBackFromSearch = false
            saveButton.isHidden = true
        } catch {
            print("saveerror:", error)
        }
    }
    @IBAction func editAction(_ sender: UIButton) {
        if tableView.isEditing {
            tableView.setEditing(false, animated: true)
            sender.setTitle("편집", for: .normal)
        } else {
            tableView.setEditing(true, animated: true)
            sender.setTitle("완료", for: .normal)
        }
        tableView.reloadData()
    }
    private var cameBackFromSearch = false
    var isMapViewHidden = false
    var lastMarker: NMFMarker?
    var markersArray: [NMFMarker] = []
    let pathOverlay = NMFPath()
//    var scheduleItemsArray: [[NMGLatLng]] = [
//        [NMGLatLng(lat: 37.582564808534975, lng: 127.06799230339993),
//         NMGLatLng(lat: 37.68679153826095, lng: 126.99438668262837),
//         NMGLatLng(lat: 37.55822420754909, lng: 126.98962705707905)
//        ],
//        [NMGLatLng(lat: 37.522564808534975, lng: 126.9679456339993),
//         NMGLatLng(lat: 37.53679153826095, lng: 126.91829668262837),
//         NMGLatLng(lat: 37.51822420754909, lng: 126.92962749207905),
//        ],
//        [NMGLatLng(lat: 37.592564808534975, lng: 126.86736230339993),
//         NMGLatLng(lat: 37.646123412676195, lng: 126.99438668092837),
//         NMGLatLng(lat: 37.59931823123229, lng: 126.9961095707905)]
//    ]
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
    private var coordsByDay: [[NMGLatLng]] = []
    
    let defaultDistanceStrategy = NMCDefaultDistanceStrategy()
    
    let infoWindow = NMFInfoWindow()
    var customInfoWindowDataSource = CustomInfoWindowDataSource()
    
    var currentTopSection: Int?
    private var isMarkerScroll = false
    var pendingIndexPath: IndexPath?
    var currentTopIndexPath: IndexPath?
    
    var scehduels: [[Schedule]] = []
    
    private lazy var fetchedResultsController: NSFetchedResultsController<POI> = {
        // 1) 요청 생성: schedule.date 기준으로 정렬
        let request: NSFetchRequest<POI> = POI.fetchRequest()
        request.sortDescriptors = [
          NSSortDescriptor(key: "schedule.date", ascending: true),
          NSSortDescriptor(key: "name", ascending: true) // 같은 날짜 내 정렬
        ]
        // 2) FRC 초기화: 섹션 키패스로 날짜(Date 객체)를 그대로 사용
        let frc = NSFetchedResultsController(
            fetchRequest: request,
            managedObjectContext: context,
            sectionNameKeyPath: "schedule.date",
            cacheName: nil
        )
        frc.delegate = self
        return frc
    }()


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
        guard let tour = tour else { return }
        fetchedResultsController = {
            let request: NSFetchRequest<POI> = POI.fetchRequest()
            request.predicate = NSPredicate(format: "schedule.tour == %@", tour)
            request.sortDescriptors = [
                NSSortDescriptor(key: "schedule.date", ascending: true),
                NSSortDescriptor(key: "name", ascending: true)
            ]
            let frc = NSFetchedResultsController(
                fetchRequest: request,
                managedObjectContext: context,
                sectionNameKeyPath: "schedule.date",
                cacheName: nil
            )
            frc.delegate = self
            return frc
        }()
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            print(error)
        }
        
        // CoreLocation
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        
        myMapView.mapView.touchDelegate = self
        
        
        tableView.dataSource = self
        tableView.delegate = self
        
        
        debugPrintFRC()
        
        myMapView.showLocationButton = true
        myMapView.showCompass = true
        myMapView.mapView.positionMode = .direction
        
        // 경로 표시
//        makePath(for: 0)
        
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
        let footer = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: tableView.bounds.height / 2))
        footer.backgroundColor = .clear
        tableView.tableFooterView = footer
        
        if scheduleItemsArray.count == 0 {
            editButton.isHidden = true
        } else {
            editButton.isHidden = false
        }
        
        

        
        updateTravelPeriodLabel()
        updateTravelTitleLabel()
        loadTourData()
        tableView.reloadData()

    }
    
//    func addPOI(latLng: NMGLatLng, toDay dayIndex: Int) {
//        // 1) 배열 인덱스 안전하게 체크
//        guard dayIndex >= 0 && dayIndex < scheduleItemsArray.count else {
//            print("❌ addPOI: 잘못된 dayIndex \(dayIndex)")
//            return
//        }
//        
//        // 2) 메모리 상 2차원 배열에만 추가
//        scheduleItemsArray[dayIndex].append(poi)
//
//        // 3) 해당 섹션만 리로드해서 '추가' 버튼 유지
//        tableView.reloadSections(IndexSet(integer: dayIndex), with: .automatic)
//        
//        // 4) 지도에 경로·마커 다시 그리기
//        makePath(for: dayIndex)
//    }
    
    private func loadTourData() {
        guard let tour = tour else { return }
        print("tourunwrapping")
        // 1) Tour.days에서 Schedule을 날짜 순으로 추출
           let schedules = (tour.days as? Set<Schedule> ?? [])
               .compactMap { $0.date != nil ? $0 : nil }
               .sorted { $0.date! < $1.date! }
        print(schedules)
           // 2) 섹션용 날짜 배열
           sortedDates = schedules.map { Calendar.current.startOfDay(for: $0.date!) }

           // 3) 각 Schedule별 POI 배열 (NSOrderedSet 처리)
           poisByDay = schedules.map { schedule in
               // Core Data 관계가 NSOrderedSet이므로 array로 변환
               let ordered = schedule.pois
               let poiArray = (ordered?.array as? [POI]) ?? []
               return poiArray.sorted { ($0.name ?? "") < ($1.name ?? "") }
           }

           // 4) 좌표 2차원 배열로 변환
           coordsByDay = poisByDay.map { poiList in
               poiList.map { NMGLatLng(lat: $0.latitude, lng: $0.longitude) }
           }
    }

    
    func addPOI(_ poi: POI, toDay dayIndex: Int) {
        // 1) 인덱스 체크
        guard dayIndex >= 0 && dayIndex < scheduleItemsArray.count else {
            print("❌ addPOI: 잘못된 dayIndex \(dayIndex)")
            return
        }

        // 2) 배열에 POI 추가
        scheduleItemsArray[dayIndex].append(poi)

        // 3) 테이블뷰 해당 섹션만 리로드
        tableView.reloadSections(IndexSet(integer: dayIndex), with: .automatic)

        // 4) 지도에 경로 다시 그리기
        let coords = scheduleItemsArray[dayIndex]
            .map { NMGLatLng(lat: $0.latitude, lng: $0.longitude) }
        makePath(for: dayIndex, with: coords)
    }

    func makePath(for section: Int, with coords: [NMGLatLng]) {
        // 기존 오버레이·마커 클리어
        pathOverlay.mapView = nil
        markersArray.forEach { $0.mapView = nil }
        markersArray.removeAll()

        // 좌표가 없으면 종료
        guard !coords.isEmpty else { return }

        // 1) Path 그리기
        let points = coords.map { $0 as AnyObject }
        pathOverlay.path = NMGLineString(points: points)
        pathOverlay.width = 8
        pathOverlay.color = .main
        pathOverlay.outlineWidth = 0
        pathOverlay.patternIcon = NMFOverlayImage(name: "route_path_arrow")
        pathOverlay.patternInterval = 10
        // 좌표가 2개 이상일 때만 보이도록
        if coords.count > 1 {
            pathOverlay.mapView = myMapView.mapView
        }

        // 2) 순번 마커 찍기
        for (i, coord) in coords.enumerated() {
            let marker = NMFMarker(position: coord)
            marker.mapView = myMapView.mapView

            // 번호 캡션
            marker.captionText = "\(i + 1)"
            marker.captionTextSize = 14
            marker.captionColor = .main

            // 아이콘 색상
            let color = getColor(at: i, totalCount: coords.count)
            marker.iconImage = NMF_MARKER_IMAGE_BLACK
            marker.iconTintColor = color

            // 터치 시 테이블/카메라 동기화
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



    
    
    private func fetchSchedules() {
        let scheduleRequest: NSFetchRequest<Schedule> = Schedule.fetchRequest()
        scheduleRequest.sortDescriptors = [
            NSSortDescriptor(key: "date", ascending: true)
        ]
        
        do {
            allSchedules = try context.fetch(scheduleRequest)
            print("All Schduels: \(allSchedules.count)개")
        } catch {
            print("❌ 스케줄 fetch 실패:", error)
        }
    }
    private func fetchTours() {
        let tourRequest: NSFetchRequest<Tour> = Tour.fetchRequest()
        tourRequest.sortDescriptors = [
          NSSortDescriptor(key: "startDate", ascending: true)
        ]
        do {
            allTours = try context.fetch(tourRequest)
            print("All Tours: \(allTours.count)")
        } catch {
            print(error)
        }
    }
    
    private func fetchPois() {
        let poiRequest: NSFetchRequest<POI> = POI.fetchRequest()
        poiRequest.sortDescriptors = [
            // Schedule 객체의 date 속성을 기준으로 정렬
            NSSortDescriptor(key: "schedule.date", ascending: true),
        ]

        do {
            allPois = try context.fetch(poiRequest)  // [POI]
            print(" 전체 POI (\(allPois.count)")
        } catch {
            print(error)
        }
    }
    
    private func fetchTourData() {
        guard let tour = tour else {
            scheduleItemsArray = []
            return
        }
        // 1) 날짜 순 Schedule
        let schedules = (tour.days as? Set<Schedule> ?? [])
            .compactMap { $0.date != nil ? $0 : nil }
            .sorted { $0.date! < $1.date! }

        // 2) 섹션용 날짜 리스트
        sortedDates = schedules.map { Calendar.current.startOfDay(for: $0.date!) }

        // 3) Schedule → [POI] 그룹핑
        let grouped: [Date: [POI]] = Dictionary(
            uniqueKeysWithValues: schedules.map { sched in
                let day = Calendar.current.startOfDay(for: sched.date!)
                let pois = (sched.pois as? Set<POI> ?? [])
                    .sorted { ($0.name ?? "") < ($1.name ?? "") }
                return (day, pois)
            }
        )

        // 4) scheduleItemsArray 에 채우기
        scheduleItemsArray = sortedDates.map { grouped[$0] ?? [] }
    }




    private func debugPrintFRC() {
        do {
            try fetchedResultsController.performFetch()
        } catch {
            print("❌ FRC performFetch failed:", error)
            return
        }
        guard let sections = fetchedResultsController.sections else {
            print("🟠 FRC.sections is nil")
            return
        }
        print("🟢 FRC 섹션 개수: \(sections.count)")
        for sec in sections {
            print("  • section name(raw): \(sec.name), 객체 수: \(sec.numberOfObjects)")
        }
        let total = (sections.reduce(0) { $0 + $1.numberOfObjects })
        print("  → 총 POI 개수: \(total)")
    }



    private func updateTravelTitleLabel() {
        // 1) tour가 있어야 진행
        guard let tour = tour else {
            return
        }

        let tourTitle = "서울 여행"

        // 3) Tour에 속한 모든 Schedule을 날짜순으로 정렬
        let schedules = (tour.days as? Set<Schedule>)?
            .compactMap { $0.date != nil ? $0 : nil }
            .sorted { $0.date! < $1.date! } ?? []

        let allPois = allPois

        // 5) POI가 하나도 없으면 tourTitle만 표시
        guard let firstPoi = allPois.first,
              let poiName = firstPoi.name else {
            travleTitleLabel.text = tourTitle
            return
        }

        // 6) 첫 POI 외 남은 개수 계산
        let extraCount = allPois.count - 1

        // 7) 레이블 텍스트 설정
        if extraCount > 0 {
            travleTitleLabel.text = "\(tourTitle) \(poiName) 외 \(extraCount)곳"
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
            // 당일 여행인 경우
            travelPeriodLabel.text = firstStr
            return
        }

        // 같은 연도면 "yyyy.MM.dd ~ M.d"
        if Calendar.current.component(.year, from: start)
         == Calendar.current.component(.year, from: end) {
            lastStr = shortFormatter.string(from: end)
        } else {
            // 다른 연도면 "yyyy.MM.dd ~ yyyy.MM.dd"
            lastStr = fullFormatter.string(from: end)
        }

        travelPeriodLabel.text = "\(firstStr) ~ \(lastStr)"
    }



    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
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
        
        
        fetchTourData()
        tableView.reloadData()
//        reloadMapData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        circleTimer?.invalidate()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        if let vc = segue.destination as? DetailSheetViewController {
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
    
    
//    private func loadDatas() {
//            // 1) POI 리스트 배열: [[POI]]
//            let poisByDay: [[POI]] = sortedDates.map { date in
//                groupedPOIsByDate[date] ?? []
//            }
//            // 2) 좌표(NMGLatLng) 리스트 배열: [[NMGLatLng]]
//            scheduleItemsArray = poisByDay.map { poiList in
//                poiList.map { NMGLatLng(lat: $0.latitude, lng: $0.longitude) }
//            }
//            // 3) 테이블·지도 갱신
//            tableView.reloadData()
//            if !scheduleItemsArray.isEmpty {
//                makePath(for: 0)
//            } else {
//                pathOverlay.mapView = nil
//            }
//        }
    
//    private func reloadMapData() {
//        // 각 섹션(날짜)별 POI 좌표 가져와 scheduleItemsArray 세팅
//        let sections = fetchedResultsController.sections ?? []
//        scheduleItemsArray = sections.map { sectionInfo in
//            (0 ..< sectionInfo.numberOfObjects).compactMap { row in
//                let indexPath = IndexPath(row: row, section: sectionInfo.numberOfObjects)
//                let poi = fetchedResultsController.object(at: indexPath)
//                return NMGLatLng(lat: poi.latitude, lng: poi.longitude)
//            }
//        }
//        // 첫 섹션 경로 그리기
//        if !scheduleItemsArray.isEmpty {
//            makePath(for: 0)
//        } else {
//            pathOverlay.mapView = nil
//        }
//    }

    
//    func makePath(for section: Int) {
//        pathOverlay.mapView = nil
//        markersArray.forEach { $0.mapView = nil }
//        markersArray.removeAll()
//        
//        let dayCoords = scheduleItemsArray[section]
//        //        guard dayCoords.count >= 2 else { return }
//        
//        // 1) Path
//        let points = dayCoords.map { $0 as AnyObject }
//        pathOverlay.path = NMGLineString(points: points)
//        pathOverlay.width = 8
//        pathOverlay.color = .main
//        pathOverlay.outlineWidth = 0
//        pathOverlay.patternIcon = NMFOverlayImage(name: "route_path_arrow")
//        pathOverlay.patternInterval = 10
//        if dayCoords.count <= 1 {
//            pathOverlay.mapView = nil
//        } else {
//            pathOverlay.mapView = myMapView.mapView
//        }
//        
//        
//        // 2) Markers
//        for (i, coord) in dayCoords.enumerated() {
//            let marker = NMFMarker(position: coord)
//            marker.mapView = myMapView.mapView
//            
//            marker.captionTextSize = 30
//            marker.captionText = "\(i + 1)"
//            marker.captionColor = .main
//            marker.iconImage = NMF_MARKER_IMAGE_BLACK
//            marker.iconTintColor = getColor(at: i)
//            
//            // 터치 시 카메라 이동
//            marker.touchHandler = { _ in
//                // 마커터치 스크롤
//                self.isMarkerScroll = true
//                
//                let indexPath = IndexPath(row: i, section: section)
//                if self.scheduleItemsArray[section].indices.contains(i) {
//                    self.tableView.scrollToRow(at: indexPath, at: .top, animated: true)
//                }
//                
//                // 스크롤 끝난 뒤 카메라 이동
//                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
//                    let update = NMFCameraUpdate(scrollTo: coord)
//                    update.animation = .easeIn
//                    update.animationDuration = 0.1
//                    self.myMapView.mapView.moveCamera(update)
//                    
//                    // 리셋
//                    self.isMarkerScroll = false
//                }
//                
//                return true
//            }
//            
//            markersArray.append(marker)
//        }
//        
//    }
    
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
            // 권한 요청을 보낸다.
            locationManager.requestWhenInUseAuthorization()
            
        case .denied, .restricted:
            // 시스템 설정으로 유도하는 커스텀 얼럿
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
//        print(fetchedResultsController.sections?.count)
//        return fetchedResultsController.sections?.count ?? 0
//        return allSchedules.count
        print(sortedDates.count)
        return sortedDates.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        guard let sectionInfo = fetchedResultsController.sections?[section] else { return 1 }
//        return sectionInfo.numberOfObjects + 1
        return poisByDay[section].count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
//        let sectionInfo = fetchedResultsController.sections![indexPath.section]
//        let objectCount = sectionInfo.numberOfObjects
//        let isLastRow = indexPath.row == scheduleItemsArray[indexPath.section].count
//
//        if isLastRow {
//            let cell = tableView.dequeueReusableCell(
//                withIdentifier: "addButtonCell", for: indexPath
//            ) as! AddPlaceButtonCell
//            cell.delegate = self
//            cell.addButton.tag = indexPath.section
//            return cell
//        }
//        
//        let poi = fetchedResultsController.object(at: indexPath)
//        guard let cell = tableView.dequeueReusableCell(withIdentifier: "placeInfoCell", for: indexPath) as? MapTableViewCell else { return UITableViewCell() }
//        cell.numberLabel.text = "\(indexPath.row + 1)"
//        cell.placeTitleLabel.text = poi.name
//        cell.numberView.backgroundColor = getColor(at: indexPath.row)
//        return cell

        
        let isLastRow = indexPath.row == poisByDay[indexPath.section].count
        
        if isLastRow {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "addButtonCell", for: indexPath) as? AddPlaceButtonCell else { return UITableViewCell() }
            cell.delegate = self
            return cell
        } else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "placeInfoCell", for: indexPath) as? MapTableViewCell else { return UITableViewCell() }
            
            cell.numberLabel.text = "\(indexPath.row + 1)"
            cell.placeTitleLabel.text = String(format: "%.3f", poisByDay[indexPath.section][indexPath.row].latitude)
            cell.numberView.backgroundColor = .main
            return cell
            
        }
        
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return indexPath.row < poisByDay[indexPath.section].count
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            poisByDay[indexPath.section].remove(at: indexPath.row)
            tableView.reloadSections(IndexSet(integer: indexPath.section), with: .automatic)
            
            let coords = poisByDay[indexPath.section]
                .map { NMGLatLng(lat: $0.latitude, lng: $0.longitude) }

            makePath(for: indexPath.section, with: coords)
            
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let vc = storyboard?.instantiateViewController(withIdentifier: "DetailSheetViewController") as? DetailSheetViewController else { return }
        vc.place = "굽네치킨"
        vc.placeCategory = "식당"
        vc.placeOpenTime = "09:00 ~ 22:00"
        vc.delegate = self
        if let presentationController = vc.presentationController as? UISheetPresentationController {
            let small = UISheetPresentationController.Detent.custom(identifier: .init(rawValue: "small")) { context in
                return context.maximumDetentValue * 0.33
            }
            
            presentationController.detents = [small]
        }
        // vc.isModalInPresentation = true
        self.present(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let itemToMove = poisByDay[sourceIndexPath.section].remove(at: sourceIndexPath.row)
        poisByDay[destinationIndexPath.section].insert(itemToMove, at: destinationIndexPath.row)
        //        tableView.reloadSections(IndexSet(integer: destinationIndexPath.section), with: .automatic)
        let coords = poisByDay[destinationIndexPath.section]
            .map { NMGLatLng(lat: $0.latitude, lng: $0.longitude) }

        makePath(for: destinationIndexPath.section, with: coords)
    }
    
    func tableView(_ tableView: UITableView, targetIndexPathForMoveFromRowAt sourceIndexPath: IndexPath, toProposedIndexPath proposedDestinationIndexPath: IndexPath) -> IndexPath {
        let section = proposedDestinationIndexPath.section
        let maxRow = poisByDay[section].count - 1
        let row = min(proposedDestinationIndexPath.row, maxRow)
        return IndexPath(row: row, section: section)
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        guard isMarkerScroll, let top = pendingIndexPath else { return }
        
        isMarkerScroll = false
        pendingIndexPath = nil
        
        // 이때 한 번만 카메라 이동
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

            //print("상단에 가장 가까운 셀: section \(top.section), row \(top.row)")
            makePath(for: top.section, with: coords)
            daysLabel.text = "Day \(top.section + 1)"
            
            if coords.count == 0 {
                self.pathOverlay.mapView = nil
            }
            
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
//            let selectedLatLng = NMGLatLng(lat: 37.6877, lng: 126.8381)
//            newPoi.id = UUID()
//            newPoi.latitude = selectedLatLng.lat
//            newPoi.longitude = selectedLatLng.lng
//            newPoi.name = "경복궁"
//            newPoi.address = "123123"
//            newPoi.openingHours = "1231 23"
//            newPoi.placeID = "123123"

            cameBackFromSearch = true
            addPOI(newPoi, toDay: dayIndex)
        }
    }
}

extension MapViewController: DetailSheetDelegate {
    func detailSheetDidTapNavigate(_ sheet: DetailSheetViewController) {
        
        let poiStoryboard = UIStoryboard(name: "POIDetail", bundle: nil)
        guard let poiDetailVC = poiStoryboard
            .instantiateViewController(withIdentifier: "POIDetail")
                as? PoiDetailViewController else { return }
        
        //        poiDetailVC.place = sheet.place
        //        poiDetailVC.placeCategory = sheet.placeCategory
        //        poiDetailVC.placeOpenTime = sheet.placeOpenTime
        
        navigationController?.pushViewController(poiDetailVC, animated: true)
    }
}

extension MapViewController: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<any NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<any NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
            case .insert:
                if let insertIndexPath = newIndexPath {
                    tableView.insertRows(at: [insertIndexPath], with: .automatic)
                }
            case .delete:
                if let deleteIndexPath = indexPath {
                    tableView.deleteRows(at: [deleteIndexPath], with: .automatic)
                }
            case .update:
                if let updateIndexPath = indexPath {
                    tableView.reloadRows(at: [updateIndexPath], with: .automatic)
                }
            case .move:
                if let originalIndexPath = indexPath, let targetIndexPath = newIndexPath {
                    tableView.moveRow(at: originalIndexPath, to: targetIndexPath)
                }
            default:
                break
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<any NSFetchRequestResult>) {
        tableView.endUpdates()
//        makePath(for: 0)
//        reloadMapData()
    }
}
