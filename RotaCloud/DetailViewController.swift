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
    @IBOutlet weak var activeLabel: UILabel!
    @IBOutlet weak var firstFlightLabel: UILabel!
    @IBOutlet weak var countryLabel: UILabel!
    
    // Statistics
    @IBOutlet weak var stagesLabel: UILabel!
    @IBOutlet weak var boosterLabel: UILabel!
    @IBOutlet weak var heightLabel: UILabel!
    @IBOutlet weak var diameterLabel: UILabel!
    @IBOutlet weak var massLabel: UILabel!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()

        self.title = rocket?.name ?? "Unknown"
        
        if let rocket = rocket {
            
            // Fill in all the details from the fetched data
            descriptionTextView.text = rocket.description
            
            activeLabel.text = rocket.active ? "Yes" : "No"
            firstFlightLabel.text = DateFormatter.localizedString(from: rocket.firstFlight, dateStyle: .short, timeStyle: .none)
            countryLabel.text = rocket.country
            
            stagesLabel.text = String(rocket.stages)
            boosterLabel.text = String(rocket.boosters)
            
            // TODO: Replace this with a system based on MeasurementFormatter
            let useMetric = Locale.current.usesMetricSystem
            
            heightLabel.text = useMetric ? "\(rocket.height.meters)m" : "\(rocket.height.feet) feet"
            diameterLabel.text = useMetric ? "\(rocket.diameter.meters)m" : "\(rocket.diameter.feet) feet"
            massLabel.text = useMetric ? "\(rocket.mass.kg)kg" : "\(rocket.mass.lb)lb"

            print(rocket)
        }
    }
}
