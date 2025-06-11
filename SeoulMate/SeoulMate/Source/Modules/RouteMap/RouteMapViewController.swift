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

class RouteMapViewController: UIViewController {
    @IBOutlet weak var naverMapView: NMFNaverMapView!

    let multipartPath = NMFMultipartPath()

    var startPoint: Location?
    var intermediates: [NMGLatLng] = []
    var endPoint: Location?

    override func viewDidLoad() {
        super.viewDidLoad()

        guard let first = dummyData.first, let last = dummyData.last else { return }

        let cameraUpdate = NMFCameraUpdate(scrollTo: first)
        cameraUpdate.animation = .easeIn

        naverMapView.mapView.moveCamera(cameraUpdate)

        startPoint = Location(latitude: first.lat, longitude: first.lng)
        endPoint = Location(latitude: last.lat, longitude: last.lng)

        if dummyData.count > 2 {
            let count = dummyData.count
            intermediates = Array(dummyData[1 ..< count-1])
        }

        var lineParts: [NMGLineString<AnyObject>] = []
        var colorParts: [NMFPathColor] = []

        if let startPoint, let endPoint {
            Task {
                let response: RoutesApiResponseDto? = await RouteApiManager.shared.calcRouteByTransit(startPoint: startPoint, endPoint: endPoint)

                guard let steps: [Step] = response?.routes[0].legs[0].steps else {
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
                        color = .lightGray
                    case "TRANSIT":
                        color = UIColor(red: 86/255, green: 169/255, blue: 73/255, alpha: 1)
                    default:
                        color = .lightGray
                    }

                    let colorPart: NMFPathColor = NMFPathColor(color: color)

                    colorParts.append(colorPart)
                }

                multipartPath.width = 8

                multipartPath.patternIcon = NMFOverlayImage(name: "route_path_arrow")
                multipartPath.patternInterval = 16

                multipartPath.lineParts = lineParts
                multipartPath.colorParts = colorParts

                multipartPath.mapView = naverMapView.mapView
            }
        } else {
            // TODO: 좌표 생성 못했을때 오류 처리
        }
    }
}
