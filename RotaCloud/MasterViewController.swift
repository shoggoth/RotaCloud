//
//  ViewController.swift
//  RotaCloud
//
//  Created by Richard Henry on 17/02/2020.
//  Copyright © 2020 Dogstar Industries Ltd. All rights reserved.
//

import UIKit
import NetComms

class MasterViewController: UIViewController, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        // Load SpaceX rocket data from their API
        let spaceXUrl  = URL(string: "https://api.spacexdata.com/v3/rockets?")
        
        RESTSession().makeGETRequest(fromURL: spaceXUrl) { (result: [Rocket]?, error: Error?) in
            
            // Check and assign the result of the API call
            // TODO: Handle the error
            guard let result = result else { return }
            self.rockets = result
            
            // Data won't be delivered on the main thread: dispatch back to reload the UITableView
            DispatchQueue.main.async { self.tableView.reloadData() }
        }
    }
    
    deinit {
        
        RESTSession().cancelAllTasks()
    }
    
    // MARK: Segues
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "showDetail" {
            
            if let indexPath = tableView.indexPathForSelectedRow, let detailController = segue.destination as? DetailViewController {
                
                // Inject the selected dependency into the detail view
                detailController.rocket = rockets?[indexPath.row]
            }
        }
    }

    // MARK: UITableView data source

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

