//
//  Temperature.swift
//  
//
//  Created by Joshua Buhler on 8/10/22.
//

import Foundation

public struct Temperature:Equatable, Codable {
    let station:String
    let temp:Int
    let time:String
}
