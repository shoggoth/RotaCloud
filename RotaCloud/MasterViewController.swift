//
//  ViewController.swift
//  RotaCloud
//
//  Created by Richard Henry on 17/02/2020.
//  Copyright © 2020 Dogstar Industries Ltd. All rights reserved.
//

import UIKit

class MasterViewController: UIViewController, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        // Load dummy data
        rockets = [Rocket(name: "Test Rocket"), Rocket(name: "Test Rocket 2"), Rocket(name: "Test Rocket 3")]
    }
    
    // MARK: - UITableView data source

    func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.rockets?.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "DefaultCell", for: indexPath)
        
        if let object = self.rockets?[indexPath.row] {
            
            cell.textLabel?.text = object.name
                //cell.detailTextLabel?.text = "Cloth : \(object.cloth_number) Odds : \(object.current_odds) Form : \(object.formsummary)"
        }
        
        return cell
    }
    
    // MARK: Properties
    
    var rockets: [Rocket]?
}

