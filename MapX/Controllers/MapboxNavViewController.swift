//
//  BasicViewController.swift
//  MapX
//
//  Created by Piyush Kant on 2021/05/19.
//

import Foundation
import UIKit
import MapboxCoreNavigation
import MapboxNavigation
import MapboxDirections

var simulationIsEnabled = true

class MapboxNavViewController: UIViewController {
    
    private let route: Route
    
    init(route: Route) {
        self.route = route

        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let origin = CLLocationCoordinate2DMake(route.origin.placemark.location?.coordinate.latitude ?? 0,
                                                route.origin.placemark.location?.coordinate.longitude ?? 0)
        let destination = CLLocationCoordinate2DMake(route.stops.first?.placemark.location?.coordinate.latitude ?? 0,                     route.stops.first?.placemark.location?.coordinate.longitude ?? 0)
       
        let options = NavigationRouteOptions(coordinates: [origin, destination])
        
        Directions.shared.calculate(options) { [weak self] (session, result) in
            switch result {
            case .failure(let error):
                print(error.localizedDescription)
            case .success(let response):
                guard let route = response.routes?.first, let strongSelf = self else {
                    return
                }
                
                // For demonstration purposes, simulate locations if the Simulate Navigation option is on.
                // Since first route is retrieved from response `routeIndex` is set to 0.
                let navigationService = MapboxNavigationService(route: route, routeIndex: 0, routeOptions: options, simulating: simulationIsEnabled ? .always : .onPoorGPS)
                let navigationOptions = NavigationOptions(navigationService: navigationService)
                let navigationViewController = NavigationViewController(for: route, routeIndex: 0, routeOptions: options, navigationOptions: navigationOptions)
                navigationViewController.modalPresentationStyle = .fullScreen
                // Render part of the route that has been traversed with full transparency, to give the illusion of a disappearing route.
                navigationViewController.routeLineTracksTraversal = true
                
                strongSelf.present(navigationViewController, animated: true, completion: nil)
            }
        }
    }
}
