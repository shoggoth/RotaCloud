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
        let spaceXUrl  = URL(string: "https://api.spacexdata.com/v3/rockets")
        
        // Dates have a special format
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .formatted(.spaceXDate)

        RESTSession().sendRequest(fromURL: spaceXUrl, decoder: decoder) { (result: Result<[Rocket]?, RESTSession.RequestError>) in
            
            // Check and assign the result of the API call
            // TODO: Handle the error properly
            if case .success(let rockets) = result {
                
                self.rockets = rockets
                
                // Data won't be delivered on the main thread: dispatch back to reload the UITableView
                DispatchQueue.main.async { self.tableView.reloadData() }

            } else { fatalError("Error fetching the rockets \(result)") }
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
        }
        
        return cell
    }
    
    // MARK: Properties
    
    var rockets: [Rocket]?
}

private extension DateFormatter {
    
    static let spaceXDate: DateFormatter = {
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        
        return formatter
    }()
}
