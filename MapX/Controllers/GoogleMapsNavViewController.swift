//
//  GoogleMapsNavViewController.swift
//  MapX
//
//  Created by Piyush Kant on 2021/05/21.
//

import UIKit
import MapKit
import GoogleMaps
import Alamofire
import SwiftyJSON

class GoogleMapsNavViewController: UIViewController {
    
    @IBOutlet weak var mapView: GMSMapView!
    
    private let route: Route
    
    init(route: Route) {
        self.route = route
        
        super.init(nibName: String(describing: GoogleMapsNavViewController.self), bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let origin = CLLocationCoordinate2DMake(route.origin.placemark.location?.coordinate.latitude ?? 0,
                                                route.origin.placemark.location?.coordinate.longitude ?? 0)
        let destination = CLLocationCoordinate2DMake(route.stops.first?.placemark.location?.coordinate.latitude ?? 0,
                                                     route.stops.first?.placemark.location?.coordinate.longitude ?? 0)
        
        drawPath()
    }
    
    func drawPath() {
        let origin = "\(route.origin.placemark.location?.coordinate.latitude ?? 0),\(route.origin.placemark.location?.coordinate.longitude ?? 0)"
        
        let destination = "\(route.stops.first?.placemark.location?.coordinate.latitude ?? 0),\(route.stops.first?.placemark.location?.coordinate.longitude ?? 0)"
        
        let url = "https://maps.googleapis.com/maps/api/directions/json?origin=\(origin)&destination=\(destination)&mode=driving&key="
        
        Alamofire.request(url).responseJSON { response in
            guard let json = try? JSON(data: response.data!) else {return}
            let routes = json["routes"].arrayValue
            
            print(routes)
            
            for route in routes {
                let routeOverviewPolyline = route["overview_polyline"].dictionary
                let points = routeOverviewPolyline?["points"]?.stringValue
                let path = GMSPath.init(fromEncodedPath: points!)
                let polyline = GMSPolyline.init(path: path)
                polyline.map = self.mapView
            }
        }
    }
}
