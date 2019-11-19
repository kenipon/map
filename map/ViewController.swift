//
//  ViewController.swift
//  map
//
//  Created by 中 裕紀 on 2019/07/19.
//  Copyright © 2019 Personal. All rights reserved.
//

import UIKit
import MapKit

// ピンのカスタマイズ
class customPin: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?

    init(pinTitle:String, pinSubTitle:String, location:CLLocationCoordinate2D) {
        self.title = pinTitle
        self.subtitle = pinSubTitle
        self.coordinate = location
    }
}

class ViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        //set delegate for mapview
        self.mapView.delegate = self
        
        
        // ２拠点の位置指定
        let sourceLocation = CLLocationCoordinate2D(latitude:35.0393553, longitude: 135.72932649999998)
        let destinationLocation = CLLocationCoordinate2D(latitude:35.0270213, longitude: 135.79820580000003)


        // ピンの設定
        let sourcePin = customPin(pinTitle: "金閣寺", pinSubTitle: "", location: sourceLocation)
        let destinationPin = customPin(pinTitle: "銀閣寺", pinSubTitle: "", location: destinationLocation)
        self.mapView.addAnnotation(sourcePin)
        self.mapView.addAnnotation(destinationPin)


        // 経路検索する設定？
        let sourcePlaceMark = MKPlacemark(coordinate: sourceLocation)
        let destinationPlaceMark = MKPlacemark(coordinate: destinationLocation)

        // 経路検索
        let directionRequest = MKDirections.Request()
        directionRequest.source = MKMapItem(placemark: sourcePlaceMark)
        directionRequest.destination = MKMapItem(placemark: destinationPlaceMark)
        directionRequest.transportType = .automobile

        let directions = MKDirections(request: directionRequest)
        directions.calculate { (response, error) in
            guard let directionResonse = response else {
                if let error = error {
                    print("we have error getting directions==\(error.localizedDescription)")
                }
                return
            }

            // ルート追加
            let route = directionResonse.routes[0]
            self.mapView.addOverlay(route.polyline, level: .aboveRoads)

            // 縮尺の設定
            let rect = route.polyline.boundingMapRect
            self.mapView.setRegion(MKCoordinateRegion(rect), animated: true)
        }
    }
}

//MARK:- MapKit delegates

extension ViewController: MKMapViewDelegate {
    /// annotationの描画設定
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let identifier = "annotation"
        let annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
        
        let baseImage = UIImage(named: "otabechan")

        // リサイズ
        let resizedImage = UIImage(cgImage: (baseImage?.cgImage)!, scale: 1/(20/baseImage!.size.width), orientation: .up)
        //let size = resizedImage.size
        
        annotationView.image = resizedImage

        return annotationView
    }
    
    /// 経路の描画設定
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        // 経路の描画
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = UIColor.blue
        renderer.lineWidth = 4.0
        return renderer
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
