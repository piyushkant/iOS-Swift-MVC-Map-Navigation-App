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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
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
            
            //        if completer.isSearching {
            //          completer.cancel()
            //        }
            return
        }
        
        //      completer.queryFragment = query
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
        editingTextField = nil
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
}

// MARK: - UITextFieldDelegate

extension NavSelectionViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        hideSuggestionView(animated: true)
        
        //        if completer.isSearching {
        //            completer.cancel()
        //        }
        
        editingTextField = textField
    }
}
