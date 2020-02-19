//
//  DetailViewController.swift
//  RotaCloud
//
//  Created by Richard Henry on 17/02/2020.
//  Copyright © 2020 Dogstar Industries Ltd. All rights reserved.
//

import UIKit

class DetailViewController : UITableViewController {

    var rocket: Rocket?
    
    // Overview
    @IBOutlet weak var descriptionTextView: UITextView!
    
    // Information
    @IBOutlet var informationCells: [UITableViewCell]!
    
    // Statistics
    @IBOutlet var statisticsCells: [UITableViewCell]!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()

        self.title = rocket?.name ?? "Unknown"
        
        if let rocket = rocket {
            
            // Fill in all the details from the fetched data
            descriptionTextView.text = rocket.description
            
            informationCells[0].detailTextLabel?.text = rocket.active ? "Yes" : "No"
            informationCells[1].detailTextLabel?.text = DateFormatter.localizedString(from: rocket.firstFlight, dateStyle: .short, timeStyle: .none)
            informationCells[2].detailTextLabel?.text = rocket.country
            
            statisticsCells[0].detailTextLabel?.text = String(rocket.stages)
            statisticsCells[1].detailTextLabel?.text = String(rocket.boosters)
            
            // TODO: Replace this with a system based on MeasurementFormatter
            let useMetric = Locale.current.usesMetricSystem
            statisticsCells[2].detailTextLabel?.text = rocket.height.description(useMetric: useMetric)
            statisticsCells[3].detailTextLabel?.text = rocket.diameter.description(useMetric: useMetric)
            statisticsCells[4].detailTextLabel?.text = rocket.mass.description(useMetric: useMetric)
        }
    }
}
