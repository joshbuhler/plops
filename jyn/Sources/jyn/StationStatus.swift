//
//  File.swift
//  
//
//  Created by Joshua Buhler on 8/25/22.
//

import Foundation

struct StationStatus:Codable {
    var incomingRunners:[IncomingRunner]
    var temperatures:[Temperature]
}
