//
//  RouteMapViewController.swift
//  SeoulMate
//
//  Created by JuHyeon Seong on 6/10/25.
//

import UIKit
import NMapsMap

var dummyData = [
    NMGLatLng(lat: 37.552987, lng: 126.972591),
    //        NMGLatLng(lat: 37.68679153826095, lng: 126.99438668262837),
    NMGLatLng(lat: 37.496486, lng: 127.028361)
]

enum TravelMode: Int {
	case drive = 0
    case transit
    case walk
}

class RouteMapViewController: UIViewController {
    @IBOutlet weak var stackView: UIStackView!

    @IBOutlet weak var visualEffectView: UIVisualEffectView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!

    @IBOutlet weak var naverMapView: NMFNaverMapView!

    @IBAction func didValueChanged(_ sender: Any) {
        guard let type = TravelMode(rawValue: segmentedControl.selectedSegmentIndex) else {
            return
        }

        Task {
            await calcRoute(type: type, startPoint: startPoint, endPoint: endPoint)
        }

    }

    let multipartPath = NMFMultipartPath()

    var startPoint: Location? {
        guard let first = dummyData.first else {
			return nil
        }

        return Location(latitude: first.lat, longitude: first.lng)
    }

    var endPoint: Location? {
        guard let last = dummyData.last else {
            return nil
        }

        return Location(latitude: last.lat, longitude: last.lng)
    }

    var intermediates: [Location]? = nil

    override func viewDidLoad() {
        super.viewDidLoad()

        setupLayout()

        if dummyData.count > 2 {
            let count = dummyData.count

            intermediates = dummyData[1 ..< count-1].map { Location(latitude: $0.lat, longitude: $0.lng) }
        }

        if let startPoint, let endPoint {
            moveCamera(location: startPoint)

            Task {
                await calcRoute(type: .drive, startPoint: startPoint, endPoint: endPoint)
            }
        } else {
            // TODO: 좌표 생성 못했을때 오류 처리
        }
    }
}

extension RouteMapViewController {
    func setupLayout() {
        let cornerRadius = segmentedControl.frame.height / 2

        self.segmentedControl.layer.borderColor = UIColor.white.cgColor
        self.segmentedControl.layer.borderWidth = 1.0;

        visualEffectView.layer.cornerRadius = cornerRadius
    }

    func moveCamera(location: Location) {
        let scrollTo = NMGLatLng(lat: location.latitude, lng: location.longitude)

        let cameraUpdate = NMFCameraUpdate(scrollTo: scrollTo)
        cameraUpdate.animation = .easeIn

        naverMapView.mapView.moveCamera(cameraUpdate)
    }

    func resetPathOverlay() {
        multipartPath.mapView = nil
    }

    func calcRoute(type: TravelMode, startPoint: Location?, endPoint: Location?, intermediates: [Location]? = nil) async {
        guard let startPoint, let endPoint else {
			print("Parameter error")

            return
        }

        switch type {
        case .drive, .walk:
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
            print(step.staticDuration, step.travelMode)

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
        }

        drawPathOverlay(lineParts: lineParts, colorParts: colorParts)
    }

    func calcRouteTMap(type: TravelMode, startPoint: Location, endPoint: Location, intermediates: [Location]? = nil) async {
        var response: TMapRoutesApiResponseDto? = nil

        if type == .drive {
            response = await RouteApiManager.shared.calcRouteByDrive(startPoint: startPoint, endPoint: endPoint)
        }
        else if type == .walk {
            response = await RouteApiManager.shared.calcRouteByWalk(startPoint: startPoint, endPoint: endPoint)
        } else {
            return
        }

        var lineParts: [NMGLineString<AnyObject>] = []

        if let features = response?.features {
            for feature in features {
                if feature.properties.pointType == .sp {
//                    feature.properties.totalDistance // 총 이동 거리
//                    feature.properties.totalTime // 총 소요시간 (ETA)
                }


                if feature.geometry.type == .point {
                    // TODO: 마커 처리
//                    if case let .double(latitude) = feature.geometry.coordinates[0],
//                       case let .double(longitude) = feature.geometry.coordinates[1] {
//
//                    }
                } else if feature.geometry.type == .lineString {
                    var points: [NMGLatLng] = []

                    for coordinate in feature.geometry.coordinates {
                        guard case let .doubleArray(latLng) = coordinate else {
                            continue
                        }

                        let point = NMGLatLng(lat: latLng[1], lng: latLng[0])
                        points.append(point)
                    }

                    let linePart = NMGLineString<AnyObject>(points: points)
                    lineParts.append(linePart)
                }
            }

            drawPathOverlay(lineParts: lineParts)
        }
    }

//    func calcRouteByDrive(startPoint: Location, endPoint: Location, intermediates: [Location]? = nil) async {
//        var lineParts: [NMGLineString<AnyObject>] = []
//
//        let response: TMapRoutesApiResponseDto? = await RouteApiManager.shared.calcRouteByDrive(startPoint: startPoint, endPoint: endPoint)
//
//
//    }

//    func calcRouteByWalk(startPoint: Location, endPoint: Location, intermediates: [Location]? = nil) async {
//        var lineParts: [NMGLineString<AnyObject>] = []
//
//        let result = await RouteApiManager.shared.calcRouteByWalk(startPoint: startPoint, endPoint: endPoint)
//
//        if let features = result?.features {
//            for feature in features {
//                if feature.properties.pointType == .sp {
////                    feature.properties.totalDistance // 총 이동 거리
////                    feature.properties.totalTime // 총 소요시간 (ETA)
//                }
//
//
//                if feature.geometry.type == .point {
//                    // TODO: 마커 처리
////                    if case let .double(latitude) = feature.geometry.coordinates[0],
////                       case let .double(longitude) = feature.geometry.coordinates[1] {
////
////                    }
//                } else if feature.geometry.type == .lineString {
//                    var points: [NMGLatLng] = []
//
//                    for coordinate in feature.geometry.coordinates {
//                        guard case let .doubleArray(latLng) = coordinate else {
//							continue
//                        }
//
//                        let point = NMGLatLng(lat: latLng[1], lng: latLng[0])
//                        points.append(point)
//                    }
//
//                    let linePart = NMGLineString<AnyObject>(points: points)
//                    lineParts.append(linePart)
//                }
//            }
//
//            drawPathOverlay(lineParts: lineParts)
//        }
//    }

    func drawPathOverlay(lineParts: [NMGLineString<AnyObject>], colorParts: [NMFPathColor]? = nil) {
        multipartPath.width = 8

        multipartPath.patternIcon = NMFOverlayImage(name: "route_path_arrow")
        multipartPath.patternInterval = 16

        // FIXME: 간헐적인 색상 오류 -> 확인 필요
        multipartPath.lineParts = lineParts

        if let colorParts {
            multipartPath.colorParts = colorParts
        } else {
            let color = UIColor(red: 54/255, green: 81/255, blue: 251/255, alpha: 1)
            let pathColor = NMFPathColor(color: color)

            let colorParts = Array(repeating: pathColor, count: lineParts.count)

            multipartPath.colorParts = colorParts
        }

        multipartPath.mapView = naverMapView.mapView
    }
}
