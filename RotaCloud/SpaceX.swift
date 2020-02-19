//
//  SpaceX.swift
//  RotaCloud
//
//  Created by Richard Henry on 17/02/2020.
//  Copyright © 2020 Dogstar Industries Ltd. All rights reserved.
//

import Foundation

struct Dimension : Decodable {
    
    let meters: Float
    let feet: Float
    
    func description(useMetric: Bool = true) -> String { return useMetric ? "\(self.meters)m" : "\(self.feet) feet" }
}

struct Mass : Decodable {
    
    let kg: Float
    let lb: Float
    
    func description(useMetric: Bool = true) -> String { return useMetric ? "\(self.kg)kg" : "\(self.lb)lb" }
}

struct Rocket : Decodable {
    
    let name: String
    let firstFlight: Date
    let description: String
    let active: Bool
    let country: String

    let stages: Int
    let boosters: Int
    let height: Dimension
    let diameter: Dimension
    let mass: Mass
    
    enum CodingKeys : String, CodingKey {
        
        case name = "rocket_name"
        case firstFlight = "first_flight"
        
        case description, active, country, stages, boosters
        case height, diameter, mass
    }
}
