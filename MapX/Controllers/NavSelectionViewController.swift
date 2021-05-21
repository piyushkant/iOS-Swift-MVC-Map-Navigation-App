//
//  ViewController.swift
//  MapX
//
//  Created by Piyush Kant on 2021/05/19.
//

import UIKit
import MapKit
import CoreLocation

class NavSelectionViewController: UIViewController {
    
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
        setupTextFields()
        setupGestures()
        setupNotifications()
        hideSuggestionView(animated: false)
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
//        editingTextField = nil
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
