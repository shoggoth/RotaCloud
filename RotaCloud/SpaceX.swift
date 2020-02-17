//
//  SpaceX.swift
//  RotaCloud
//
//  Created by Richard Henry on 17/02/2020.
//  Copyright © 2020 Dogstar Industries Ltd. All rights reserved.
//

import Foundation

struct Rocket : Codable {
    
    let name: String
//    let id: Int
//    let active: Bool
//    let stages: Int
    
    enum CodingKeys : String, CodingKey {
        
        case name = "rocket_name"
    }
}
