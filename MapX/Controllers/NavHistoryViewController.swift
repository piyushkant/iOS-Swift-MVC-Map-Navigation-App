//
//  NavHistoryViewController.swift
//  MapX
//
//  Created by Piyush Kant on 2021/05/23.
//

import UIKit
import CoreData

class NavHistoryViewController: UIViewController {
    
    private let cellIdentifier = "PathCell"
    
    @IBOutlet weak var tableView: UITableView!
 
    var paths: [NSManagedObject] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellIdentifier)
        
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Path")
        
        do {
            paths = try managedContext.fetch(fetchRequest)
            print("fetching success")
            print(paths)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    
    private func setupUI() {
        self.title = "Navigation History"
        self.tableView.tableFooterView = UIView()
    }
}

// MARK: - UITableViewDataSource
extension NavHistoryViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return paths.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let path = paths[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        cell.textLabel?.text = path.value(forKeyPath: "label") as? String
        return cell
    }
}
