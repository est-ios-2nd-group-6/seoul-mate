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
        }
        
        self.myMapView.isHidden ? self.upDownButton.setImage(UIImage(systemName: "chevron.down"), for: .normal) : self.upDownButton.setImage(UIImage(systemName: "chevron.up"), for: .normal)
        
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
    var isMapViewHidden = false
    var lastMarker: NMFMarker?
    var markersArray: [NMFMarker] = []
    let pathOverlay = NMFPath()
    var scheduleItemsArray: [[NMGLatLng]] = [
        [NMGLatLng(lat: 37.582564808534975, lng: 127.06799230339993),
         NMGLatLng(lat: 37.68679153826095, lng: 126.99438668262837),
         NMGLatLng(lat: 37.55822420754909, lng: 126.98962705707905)
        ],
        [NMGLatLng(lat: 37.522564808534975, lng: 126.9679456339993),
         NMGLatLng(lat: 37.53679153826095, lng: 126.91829668262837),
         NMGLatLng(lat: 37.51822420754909, lng: 126.92962749207905),
        ],
        [NMGLatLng(lat: 37.592564808534975, lng: 126.86736230339993),
         NMGLatLng(lat: 37.646123412676195, lng: 126.99438668092837),
         NMGLatLng(lat: 37.59931823123229, lng: 126.9961095707905)]
    ]
    private var poisByDay: [[POI]] = []
//    private var scheduleItemsArray: [[NMGLatLng]] = []
    
    let latLngOfLastMarker: NMGLatLng? = nil
    let circleColor = UIColor(red: 0.58, green: 0.78, blue: 0.98, alpha: 1.0)
    var opacity: Double = 0
    var radius: Double = 10
    var counter: Int = 0
    var circleTimer: CADisplayLink?
    let locationManager: CLLocationManager = CLLocationManager()
    
    var selectedDays: [String] = []
    
    let colorArray: [UIColor] = [.blue, .red, .yellow, .green, .main, .systemTeal, .systemMint, .systemPink, .magenta, .systemIndigo]
    var lastColor: UIColor?
    var colorSequence: [UIColor] = []
    
    let defaultDistanceStrategy = NMCDefaultDistanceStrategy()
    
    let infoWindow = NMFInfoWindow()
    var customInfoWindowDataSource = CustomInfoWindowDataSource()
    
    var currentTopSection: Int?
    private var isMarkerScroll = false
    var pendingIndexPath: IndexPath?
    var currentTopIndexPath: IndexPath?

    var tour: Tour!
    var scehduels: [[Schedule]] = []
    var context: NSManagedObjectContext {
        (UIApplication.shared.delegate as! AppDelegate)
            .persistentContainer
            .viewContext
    }
    
    private let fullFormatter: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "ko_KR")
        f.dateFormat = "yyyy.MM.dd"
        return f
    }()

    
    private let shortFormatter: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "ko_KR")
        // 7.17 형태로
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
        makePath(for: 0)
        
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
        
        // 장소 정보
//        infoWindow.anchor = CGPoint(x: 0, y: 1)
//        infoWindow.dataSource = customInfoWindowDataSource
//        infoWindow.offsetX = -40
//        infoWindow.offsetY = -5
//        infoWindow.touchHandler = { [weak self] (overlay: NMFOverlay) -> Bool in
//            self?.infoWindow.close()
//            return true
//        }
        
        // 날짜 표시
        if let firstDay = selectedDays.first,
           let lastDay = selectedDays.last {
            
            let firstYear = selectedDays.first?.prefix(4)
            let lastYear = selectedDays.last?.prefix(4)
            
            if firstYear == lastYear {
                let lastWithoutYear = String(lastDay.dropFirst(5))
                travelPeriodLabel.text = firstDay + "~" + lastWithoutYear
            } else {
                travelPeriodLabel.text = firstDay + "~" + lastDay
            }
            
        }
    
        // 추가 스크롤을 위한 footer
        let footer = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: tableView.bounds.height / 2))
        footer.backgroundColor = .clear
        tableView.tableFooterView = footer
        
//        loadPOIsByDay()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        circleTimer = CADisplayLink(target: self, selector: #selector(updateCircle))
        circleTimer?.preferredFramesPerSecond = 20
        
        circleTimer?.add(to: RunLoop.current, forMode: RunLoop.Mode.default)
        circleTimer?.isPaused = true
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
    
    private func loadPOIsByDay() {
        // 1) Tour.pois 관계에서 Set<POI> 꺼내기
        guard let poiSet = tour.pois as? Set<POI>, !poiSet.isEmpty else {
          poisByDay = []
          scheduleItemsArray = []
          tableView.reloadData()
          return
        }
        
        // 2) POI 하나하나가 속한 Schedule의 date(하루 단위)로 그룹핑
        let grouped: [Date: [POI]] = Dictionary(grouping: poiSet) { poi in
          // Schedule이 to-one 관계라면
          guard let sched = poi.schedule, let date = sched.date else {
            // date 없으면 오늘로 치환
            return Calendar.current.startOfDay(for: Date())
          }
          return Calendar.current.startOfDay(for: date)
        }
        
        // 3) 날짜 키(하루 단위) 오름차순 정렬
        let sortedDays = grouped.keys
          .sorted(by: { $0 < $1 })
        
        // 4) 그 순서대로 2차원 배열로 변환
        poisByDay = sortedDays.map { grouped[$0]! }
        
        // 5) 좌표 배열 생성
        scheduleItemsArray = poisByDay.map { poiList in
          poiList.map { poi in
            NMGLatLng(lat: poi.latitude, lng: poi.longitude)
          }
        }
        
        // 6) UI 갱신
        tableView.reloadData()
        if !scheduleItemsArray.isEmpty {
          makePath(for: 0)    // section 0 경로 그리기
        }
      }
    
    func makePath(for section: Int) {
        pathOverlay.mapView = nil
        markersArray.forEach { $0.mapView = nil }
        markersArray.removeAll()
        
        let dayCoords = scheduleItemsArray[section]
//        guard dayCoords.count >= 2 else { return }
        
        // 1) Path
        let points = dayCoords.map { $0 as AnyObject }
        pathOverlay.path = NMGLineString(points: points)
        pathOverlay.width = 8
        pathOverlay.color = .main
        pathOverlay.outlineWidth = 0
        pathOverlay.patternIcon = NMFOverlayImage(name: "route_path_arrow")
        pathOverlay.patternInterval = 10
        if dayCoords.count <= 1 {
            pathOverlay.mapView = nil
        } else {
            pathOverlay.mapView = myMapView.mapView
        }
        
        
        // 2) Markers
        for (i, coord) in dayCoords.enumerated() {
            let marker = NMFMarker(position: coord)
            marker.mapView = myMapView.mapView
            
            marker.captionTextSize = 30
            marker.captionText = "\(i + 1)"
            marker.captionColor = .main
            marker.iconImage = NMF_MARKER_IMAGE_BLACK
            marker.iconTintColor = getColor(at: i)
            
            // 터치 시 카메라 이동
            marker.touchHandler = { _ in
                // 마커터치 스크롤
                self.isMarkerScroll = true
                
                let indexPath = IndexPath(row: i, section: section)
                if self.scheduleItemsArray[section].indices.contains(i) {
                    self.tableView.scrollToRow(at: indexPath, at: .top, animated: true)
                }
                
                // 스크롤 끝난 뒤 카메라 이동
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    let update = NMFCameraUpdate(scrollTo: coord)
                    update.animation = .easeIn
                    update.animationDuration = 0.1
                    self.myMapView.mapView.moveCamera(update)
                    
                    // 리셋
                    self.isMarkerScroll = false
                }
                
                return true
            }
            
            markersArray.append(marker)
        }
      
    }
  
    func getColor(at index: Int) -> UIColor {
        // 이미 생성된 경우 재사용
        if index < colorSequence.count {
            return colorSequence[index]
        }
        
        // 필요한 색을 계속 생성해서 채우기
        while colorSequence.count <= index {
            let availableColors = colorArray.filter { $0 != lastColor }
            let newColor = availableColors.randomElement() ?? colorArray.first!
            colorSequence.append(newColor)
            lastColor = newColor
        }
        
        return colorSequence[index]
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
            
            if self.stackView.isHidden == false {
                self.tableView.reloadData()
            }

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
        //        locationManager.stopUpdatingLocation()
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        checkUserDeviceLocationServiceAuthorization()
    }
    
    
}

extension MapViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return scheduleItemsArray.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return scheduleItemsArray[section].count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let isLastRow = indexPath.row == scheduleItemsArray[indexPath.section].count
        
        if !isLastRow {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "placeInfoCell", for: indexPath) as? MapTableViewCell else { return UITableViewCell() }
            
            cell.numberLabel.text = "\(indexPath.row + 1)"
            cell.placeTitleLabel.text = String(format: "%.3f", scheduleItemsArray[indexPath.section][indexPath.row].lat)
            cell.numberView.backgroundColor = colorSequence[indexPath.row]
            return cell
        } else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "addButtonCell", for: indexPath) as? AddPlaceButtonCell else { return UITableViewCell() }
            return cell
            
        }
        
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return indexPath.row < scheduleItemsArray[indexPath.section].count
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            scheduleItemsArray[indexPath.section].remove(at: indexPath.row)
            tableView.reloadSections(IndexSet(integer: indexPath.section), with: .automatic)
            makePath(for: indexPath.section)
            
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let vc = storyboard?.instantiateViewController(withIdentifier: "DetailSheetViewController") as? DetailSheetViewController else { return }
        vc.place = "굽네치킨"
        vc.placeCategory = "식당"
        vc.placeOpenTime = "09:00 ~ 22:00"
        vc.delegate = self
//        if let presentationController = vc.presentationController as? UISheetPresentationController {
//            let small = UISheetPresentationController.Detent.custom(identifier: .init(rawValue: "small")) { context in
//                return context.maximumDetentValue * 0.33
//            }
//
//            presentationController.detents = [small]
//        }
//        vc.isModalInPresentation = true
        self.present(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let itemToMove = scheduleItemsArray[sourceIndexPath.section].remove(at: sourceIndexPath.row)
        scheduleItemsArray[destinationIndexPath.section].insert(itemToMove, at: destinationIndexPath.row)
//        tableView.reloadSections(IndexSet(integer: destinationIndexPath.section), with: .automatic)
        makePath(for: destinationIndexPath.section)
    }

    func tableView(_ tableView: UITableView, targetIndexPathForMoveFromRowAt sourceIndexPath: IndexPath, toProposedIndexPath proposedDestinationIndexPath: IndexPath) -> IndexPath {
        let section = proposedDestinationIndexPath.section
        let maxRow = scheduleItemsArray[section].count - 1
        let row = min(proposedDestinationIndexPath.row, maxRow)
        return IndexPath(row: row, section: section)
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        guard isMarkerScroll, let top = pendingIndexPath else { return }
        
        isMarkerScroll = false
        pendingIndexPath = nil
        
        // 이때 한 번만 카메라 이동
        let coord = scheduleItemsArray[top.section][top.row]
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
//            print("상단에 가장 가까운 셀: section \(top.section), row \(top.row)")
            makePath(for: top.section)
            daysLabel.text = "Day \(top.section + 1)"
//            let raw = selectedDays[top.section]
//            if let d = fullFormatter.date(from: raw) {
//                let short = shortFormatter.string(from: d)
//                daysLabel.text = "Day \(top.section + 1) / \(short)"
//            }
            if scheduleItemsArray[top.section].count == 0 {
                self.pathOverlay.mapView = nil
            }
            guard let top = topIndexPath,
                  top != currentTopIndexPath else { return }
            let lastRowIndex = scheduleItemsArray[top.section].count
            guard top.row < lastRowIndex else {
                currentTopIndexPath = top
                return
            }
            currentTopIndexPath = top
            let coord = scheduleItemsArray[top.section][top.row]
            let update = NMFCameraUpdate(scrollTo: coord)
            update.animation = .easeIn
            self.myMapView.mapView.moveCamera(update)

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
