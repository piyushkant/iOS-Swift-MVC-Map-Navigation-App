//
//  ViewController.swift
//  MapX
//
//  Created by Piyush Kant on 2021/05/19.
//

import UIKit
import MapKit
import CoreLocation
import MapboxCoreNavigation
import MapboxNavigation
import MapboxDirections

class NavSelectionViewController: UIViewController {
    
    @IBOutlet private var headerLabel: UILabel!
    @IBOutlet private var inputContainerView: UIView!
    @IBOutlet private var startTextField: UITextField!
    @IBOutlet private var stopTextField: UITextField!
    
    @IBOutlet private var suggestionContainerView: UIView!
    @IBOutlet private var suggestionLabel: UILabel!
    @IBOutlet private var suggestionContainerTopConstraint: NSLayoutConstraint!
    
    @IBOutlet private var navigateButton: UIButton!
    @IBOutlet private var activityIndicatorView: UIActivityIndicatorView!
    
    @IBOutlet private var keyboardAvoidingConstraint: NSLayoutConstraint!
    
    private let defaultAnimationDuration: TimeInterval = 0.25
    
    private var editingTextField: UITextField?
    private var currentRegion: MKCoordinateRegion?
    private var currentPlace: CLPlacemark?
    
    private let locationManager = CLLocationManager()
    private let searchCompleter = MKLocalSearchCompleter()
    
    var sdkType: SDKType = .mapKit
    
    init (sdkType: SDKType) {
        self.sdkType = sdkType
        
        super.init(nibName: String(describing: NavSelectionViewController.self), bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        searchCompleter.delegate = self
        
        setupUI()
        trytLocationAccess()
    }
    
    private func trytLocationAccess() {
        guard CLLocationManager.locationServicesEnabled() else {
            return
        }
        
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.delegate = self
        
        if CLLocationManager.authorizationStatus() == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
        } else {
            locationManager.requestLocation()
        }
    }
    
    // MARK: - UI
    private func setupUI() {
        self.headerLabel.text = self.sdkType.description
        setupTextFields()
        setupGestures()
        setupNotifications()
        hideSuggestionView(animated: false)
        navigateButton.setStyle()
    }
    
    private func setupTextFields() {
        startTextField.delegate = self
        stopTextField.delegate = self
        
        startTextField.addTarget(
            self,
            action: #selector(textFieldDidChange(_:)),
            for: .editingChanged
        )
        stopTextField.addTarget(
            self,
            action: #selector(textFieldDidChange(_:)),
            for: .editingChanged
        )
    }
    
    @objc private func textFieldDidChange(_ field: UITextField) {
        if field == startTextField && currentPlace != nil {
            currentPlace = nil
            field.text = ""
        }
        
        guard let query = field.contents else {
            hideSuggestionView(animated: true)
            
            if searchCompleter.isSearching {
                searchCompleter.cancel()
            }
            return
        }
        
        searchCompleter.queryFragment = query
    }
    
    private func setupGestures() {
        view.addGestureRecognizer(
            UITapGestureRecognizer(
                target: self,
                action: #selector(handleTap(_:))
            )
        )
        
        suggestionContainerView.addGestureRecognizer(
            UITapGestureRecognizer(
                target: self,
                action: #selector(suggestionTapped(_:))
            )
        )
    }
    
    @objc private func handleTap(_ gesture: UITapGestureRecognizer) {
        let gestureView = gesture.view
        let point = gesture.location(in: gestureView)
        
        guard
            let hitView = gestureView?.hitTest(point, with: nil),
            hitView == gestureView
        else {
            return
        }
        
        view.endEditing(true)
    }
    
    @objc private func suggestionTapped(_ gesture: UITapGestureRecognizer) {
        hideSuggestionView(animated: true)
                
        editingTextField?.text = suggestionLabel.text
    }
    
    @IBAction private func navigateButtonTapped() {
        view.endEditing(true)
        
        navigateButton.isEnabled = false
        activityIndicatorView.startAnimating()
        
        let segment: RouteBuilder.Segment?
        if let currentLocation = currentPlace?.location {
            segment = .location(currentLocation)
        } else if let originValue = startTextField.contents {
            segment = .text(originValue)
        } else {
            segment = nil
        }
        
        let stopSegments: [RouteBuilder.Segment] = [
            stopTextField.contents
        ]
        .compactMap { contents in
            if let value = contents {
                return .text(value)
            } else {
                return nil
            }
        }
        
        guard
            let originSegment = segment,
            !stopSegments.isEmpty
        else {
            showAlert(message: "Please select an origin and a stop.")
            activityIndicatorView.stopAnimating()
            navigateButton.isEnabled = true
            return
        }
        
        RouteBuilder.buildRoute(
            origin: originSegment,
            stops: stopSegments,
            within: currentRegion
        ) { result in
            self.navigateButton.isEnabled = true
            
            switch result {
            case .success(let route):
                var vc: UIViewController = MapKitNavViewController(route: route)
                                
                switch self.sdkType {
                case .mapbox:
                    self.openMapboxNavigation(route: route, simulationIsEnabled: true)
                case .googleMaps:
                    self.activityIndicatorView.stopAnimating()
                    vc = GoogleMapsNavViewController(route: route)
                    self.navigationController?.pushViewController(vc, animated: true)
                default:
                    self.activityIndicatorView.stopAnimating()
                    vc = MapKitNavViewController(route: route)
                    self.navigationController?.pushViewController(vc, animated: true)
                }
                
            case .failure(let error):
                let errorMessage: String
                
                switch error {
                case .invalidSegment(let reason):
                    errorMessage = "Error: \(reason)."
                }
                
                self.showAlert(message: errorMessage)
            }
        }
    }
    
    private func openMapboxNavigation(route: Route, simulationIsEnabled: Bool) {
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
                
                strongSelf.activityIndicatorView.stopAnimating()

                let navigationService = MapboxNavigationService(route: route, routeIndex: 0, routeOptions: options, simulating: simulationIsEnabled ? .always : .onPoorGPS)
                let navigationOptions = NavigationOptions(navigationService: navigationService)
                let navigationViewController = NavigationViewController(for: route, routeIndex: 0, routeOptions: options, navigationOptions: navigationOptions)
                navigationViewController.modalPresentationStyle = .fullScreen
                navigationViewController.routeLineTracksTraversal = true
                navigationViewController.title = "Mapbox"
                
                strongSelf.navigationController?.pushViewController(navigationViewController, animated: true)
            }
        }
    }
    
    private func hideSuggestionView(animated: Bool) {
        suggestionContainerTopConstraint.constant = -1 * (suggestionContainerView.bounds.height + 1)
        
        guard animated else {
            view.layoutIfNeeded()
            return
        }
        
        UIView.animate(withDuration: defaultAnimationDuration) {
            self.view.layoutIfNeeded()
        }
    }
    
    private func setupNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleKeyboardFrameChange(_:)),
            name: UIResponder.keyboardWillChangeFrameNotification,
            object: nil
        )
    }
    
    @objc private func handleKeyboardFrameChange(_ notification: Notification) {
        guard let frame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else {
            return
        }
        
        let viewHeight = view.bounds.height - view.safeAreaInsets.bottom
        let visibleHeight = viewHeight - frame.origin.y
        keyboardAvoidingConstraint.constant = visibleHeight + 32
        
        UIView.animate(withDuration: defaultAnimationDuration) {
            self.view.layoutIfNeeded()
        }
    }
    
    private func showSuggestion(_ suggestion: String) {
        suggestionLabel.text = suggestion
        suggestionContainerTopConstraint.constant = -4 // to hide the top corners
        
        UIView.animate(withDuration: defaultAnimationDuration) {
            self.view.layoutIfNeeded()
        }
    }
    
    private func showAlert(message: String) {
        let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        
        present(alertController, animated: true)
    }
}

// MARK: - CLLocationManagerDelegate

extension NavSelectionViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        guard status == .authorizedWhenInUse else {
            return
        }
        
        manager.requestLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let firstLocation = locations.first else {
            return
        }
        
        let commonDelta: CLLocationDegrees = 25 / 111 // 1/111 = 1 latitude km
        let span = MKCoordinateSpan(latitudeDelta: commonDelta, longitudeDelta: commonDelta)
        let region = MKCoordinateRegion(center: firstLocation.coordinate, span: span)
        
        currentRegion = region
        searchCompleter.region = region
        
        CLGeocoder().reverseGeocodeLocation(firstLocation) { places, _ in
            guard let firstPlace = places?.first, self.startTextField.contents == nil else {
                return
            }
            
            self.currentPlace = firstPlace
            self.startTextField.text = firstPlace.shortAddress
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error requesting location: \(error.localizedDescription)")
    }
}

// MARK: - MKLocalSearchCompleterDelegate

extension NavSelectionViewController: MKLocalSearchCompleterDelegate {
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        guard let firstResult = completer.results.first else {
            return
        }
        
        showSuggestion(firstResult.title)
    }
    
    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        print("Error suggesting a location: \(error.localizedDescription)")
    }
}

// MARK: - UITextFieldDelegate

extension NavSelectionViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        hideSuggestionView(animated: true)
        
        if searchCompleter.isSearching {
            searchCompleter.cancel()
        }
        
        editingTextField = textField
    }
}
