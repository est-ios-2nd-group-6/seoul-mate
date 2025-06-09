//
//  MapViewController.swift
//  SeoulMate
//
//  Created by 하재준 on 6/7/25.
//

import UIKit
import NMapsMap
import CoreLocation

class MapViewController: UIViewController {
    class ItemKey: NSObject, NMCClusteringKey {
        let identifier: Int
        let position: NMGLatLng

        init(identifier: Int, position: NMGLatLng) {
            self.identifier = identifier
            self.position = position
        }

        static func markerKey(withIdentifier identifier: Int, position: NMGLatLng) -> ItemKey {
            return ItemKey(identifier: identifier, position: position)
        }

        override func isEqual(_ o: Any?) -> Bool {
            guard let o = o as? ItemKey else {
                return false
            }
            if self === o {
                return true
            }

            return o.identifier == self.identifier
        }

        override var hash: Int {
            return self.identifier
        }
        
        func copy(with zone: NSZone? = nil) -> Any {
            return ItemKey(identifier: self.identifier, position: self.position)
        }
    }
    
    class ItemData: NSObject {
        let name: String
        let gu: String

        init(name: String, gu: String) {
            self.name = name
            self.gu = gu
        }
    }
    
    class MarkerManager: NMCDefaultMarkerManager {
        override func createMarker() -> NMFMarker {
            let marker = super.createMarker()
            marker.subCaptionTextSize = 10
            marker.subCaptionColor = UIColor.white
            marker.subCaptionHaloColor = UIColor.clear
            return marker
        }
    }
    

    @IBOutlet weak var addPlaceButton: UIButton!
    @IBOutlet weak var myMapView: NMFNaverMapView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var upDownButton: UIButton!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var tableContentView: UIView!
    @IBOutlet weak var mapViewHeightConstraint: NSLayoutConstraint!
    
    @IBAction func addPlacesAction(_ sender: Any) {
        // 장소가 2개 이상인 경우 경로
        if let lastMarker {
            pathArray.append(lastMarker.position)
            
        }
    }
    @IBAction func upDownAction(_ sender: Any) {

        UIView.animate(withDuration: 0.3) {
            self.myMapView.isHidden.toggle()
        }
        
        self.myMapView.isHidden ? self.upDownButton.setImage(UIImage(systemName: "chevron.down"), for: .normal) : self.upDownButton.setImage(UIImage(systemName: "chevron.up"), for: .normal)

    }
    var isMapViewHidden = false
    var lastMarker: NMFMarker?
    var markersArray: [NMFMarker] = []
    let pathOverlay = NMFPath()
    var pathArray: [NMGLatLng] = []
    let latLngOfLastMarker: NMGLatLng? = nil
    let circleColor = UIColor(red: 0.58, green: 0.78, blue: 0.98, alpha: 1.0)
    var opacity: Double = 0
    var radius: Double = 10
    var counter: Int = 0
    var circleTimer: CADisplayLink?
    let locationManager: CLLocationManager = CLLocationManager()
    let seoulBounds = NMGLatLngBounds(
        southWestLat: 37.413294,
        southWestLng: 126.734086,
        northEastLat: 37.715133,
        northEastLng: 127.269311
    )
    
    let defaultDistanceStrategy = NMCDefaultDistanceStrategy()
    var clusterer: NMCClusterer<ItemKey>?
    
    let infoWindow = NMFInfoWindow()
    var customInfoWindowDataSource = CustomInfoWindowDataSource()

    
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
        makePath()
        
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
        myMapView.mapView.extent = seoulBounds
        myMapView.mapView.moveCamera(NMFCameraUpdate(fit: seoulBounds, padding: 24))
        let polylineOverlay = NMFPolylineOverlay([seoulBounds.southWest,
                                                  NMGLatLng(lat: seoulBounds.southWestLat, lng: seoulBounds.northEastLng),
                                                  seoulBounds.northEast,
                                                  NMGLatLng(lat: seoulBounds.northEastLat, lng: seoulBounds.southWestLng),
                                                  seoulBounds.southWest])
        polylineOverlay?.color = .orange
        polylineOverlay?.mapView = myMapView.mapView
        
        // 장소 정보
        infoWindow.anchor = CGPoint(x: 0, y: 1)
        infoWindow.dataSource = customInfoWindowDataSource
        infoWindow.offsetX = -40
        infoWindow.offsetY = -5
        infoWindow.touchHandler = { [weak self] (overlay: NMFOverlay) -> Bool in
            self?.infoWindow.close()
            return true
        }
        
        
//        clustering()
        
       

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
    
    func makePath() {
        pathArray = [NMGLatLng(lat: 37.582564808534975, lng: 127.06799230339993),
                     NMGLatLng(lat: 37.68679153826095, lng: 126.99438668262837),
                     NMGLatLng(lat: 37.55822420754909, lng: 126.82962705707905)
        ]
        if pathArray.count >= 2 {
            let paths = pathArray.map { $0 as AnyObject }
            pathOverlay.path = NMGLineString(points: paths)
            pathOverlay.width = 8
            pathOverlay.color = .orange
            pathOverlay.outlineWidth = 0
            pathOverlay.patternIcon = NMFOverlayImage(name: "route_path_arrow")
            pathOverlay.patternInterval = 10
            for coord in pathArray {
                let marker = NMFMarker(position: coord)
                marker.mapView = myMapView.mapView
                markersArray.append(marker)
            }
            pathOverlay.mapView = myMapView.mapView
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
    
    func clustering() {
        let builder = NMCComplexBuilder<ItemKey>()
        builder.minClusteringZoom = 9
        builder.maxClusteringZoom = 16
        builder.maxScreenDistance = 200
        builder.thresholdStrategy = self
        builder.distanceStrategy = self
        builder.tagMergeStrategy = self
        builder.markerManager = MarkerManager()
        builder.leafMarkerUpdater = self
        builder.clusterMarkerUpdater = self
        self.clusterer = builder.build()
        
        var keyTagMap = [ItemKey: ItemData]()
        for i in 0 ..< pathArray.count {
            let key = ItemKey(identifier: i, position: NMGLatLng(lat: pathArray[i].lat, lng: pathArray[i].lng))
            keyTagMap[key] = ItemData(name: "ㅇㅇㅇ", gu: "구구구")
        }
        
        
    
        self.clusterer?.addAll(keyTagMap)
        self.clusterer?.mapView = myMapView.mapView
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
        lastMarker?.mapView = nil
        
        let marker = NMFMarker()
        marker.position = latlng
        marker.mapView = mapView
        lastMarker = marker
        
        infoWindow.close()
        
        infoWindow.position = latlng
        infoWindow.open(with: mapView)
        


        
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
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return pathArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? MapTableViewCell else { return UITableViewCell() }
        
        cell.numberLabel.text = "\(indexPath.row + 1)"
        return cell
    }
    
    
}


extension MapViewController: NMCThresholdStrategy, NMCDistanceStrategy, NMCTagMergeStrategy, NMCClusterMarkerUpdater, NMCLeafMarkerUpdater {
    func getThreshold(_ zoom: Int) -> Double {
        if zoom <= 11 {
            return 0
        } else {
            return 70
        }
    }
    
    func getDistance(_ zoom: Int, node1: NMCNode, node2: NMCNode) -> Double {
        if zoom <= 9 {
            return -1
        }
        assert(node1.tag != nil)
        assert(node2.tag != nil)
        if let tag1 = node1.tag as? ItemData, let tag2 = node2.tag as? ItemData, tag1.gu == tag2.gu {
            if zoom <= 11 {
                return -1
            } else {
                return defaultDistanceStrategy.getDistance(zoom, node1: node1, node2: node2)
            }
        }
        return 10000
    }
    
    func mergeTag(_ cluster: NMCCluster) -> NSObject? {
        if cluster.maxZoom > 9 {
            if let tag = cluster.children.first?.tag as? ItemData {
                return ItemData(name: "", gu: tag.gu)
            }
        }
        return nil;
    }
    
    func updateClusterMarker(_ info: NMCClusterMarkerInfo, _ marker: NMFMarker) {
        let size = info.size
        if info.minZoom <= 10 {
            marker.iconImage = NMF_MARKER_IMAGE_CLUSTER_HIGH_DENSITY
        } else if size < 10 {
            marker.iconImage = NMF_MARKER_IMAGE_CLUSTER_LOW_DENSITY
        } else {
            marker.iconImage = NMF_MARKER_IMAGE_CLUSTER_MEDIUM_DENSITY
        }
        if info.minZoom == 10 {
            assert(info.tag != nil)
            if let tag = info.tag as? ItemData {
                marker.subCaptionText = tag.gu;
            }
        } else {
            marker.subCaptionText = ""
        }
        marker.anchor = NMF_CLUSTER_ANCHOR_DEFAULT
        marker.captionText = String(size)
        marker.captionAligns = [NMFAlignType.center]
        marker.captionColor = UIColor.white
        marker.captionHaloColor = UIColor.clear
        marker.touchHandler = { overlay in
            if let mapView = overlay.mapView {let position = NMFCameraPosition(info.position, zoom: Double(info.maxZoom + 1))
                let cameraUpdate = NMFCameraUpdate(position: position)
                cameraUpdate.animation = .easeIn
                mapView.moveCamera(cameraUpdate)
            }
            return true
        }
    }
    
    func updateLeafMarker(_ info: NMCLeafMarkerInfo, _ marker: NMFMarker) {
        assert(info.tag != nil)
        marker.iconImage = NMF_MARKER_IMAGE_DEFAULT
        marker.anchor = NMF_MARKER_ANCHOR_DEFAULT
        if let tag = info.tag as? ItemData {
            marker.captionText = tag.name;
        }
        marker.captionAligns = [NMFAlignType.bottom]
        marker.captionColor = UIColor.black
        marker.captionHaloColor = UIColor.white
        marker.subCaptionText = ""
        marker.touchHandler = nil
    }
}
