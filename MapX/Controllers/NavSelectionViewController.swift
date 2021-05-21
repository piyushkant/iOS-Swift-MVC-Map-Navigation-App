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

    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

