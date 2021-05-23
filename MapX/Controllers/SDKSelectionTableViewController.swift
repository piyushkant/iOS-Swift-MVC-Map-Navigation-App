//
//  SDKSelectionTableViewController.swift
//  MapX
//
//  Created by Piyush Kant on 2021/05/23.
//

import UIKit

class SDKSelectionTableViewController: UIViewController {
    
    private let data = ["MapKit", "Mapbox", "Google Maps"]
    private let cellIdentifier = "SDKCell"
    
    @IBOutlet private var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.delegate  = self
        self.tableView.dataSource = self
        
        setupUI()
    }
    
    private func setupUI() {
        self.title = "MapX"
        self.tableView.tableFooterView = UIView()
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "History"), style: .plain, target: self, action: #selector(showNavHistory))
        self.navigationItem.rightBarButtonItem?.tintColor = .lightGray
    }

    @objc func showNavHistory() {
        print("showNavHistory")
        let vc = NavHistoryViewController()
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

extension SDKSelectionTableViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = { () -> UITableViewCell in
            guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) else {
                let cell = UITableViewCell(style: .subtitle, reuseIdentifier: cellIdentifier)
                return cell
            }
            return cell
        }()
        
        cell.textLabel?.text = data[indexPath.row]
        
        return cell
    }
}

extension SDKSelectionTableViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Select SDK for navigation:"
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        var sdkType: SDKType = .mapKit
        
        switch indexPath.row {
        case 1:
            sdkType = .mapbox
        case 2:
            sdkType = .googleMaps
        default:
            sdkType = .mapKit
        }
        
        let vc = NavSelectionViewController(sdkType: sdkType)
        self.navigationController?.pushViewController(vc, animated: true)
    }
}


