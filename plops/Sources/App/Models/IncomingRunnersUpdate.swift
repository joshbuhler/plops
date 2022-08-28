//
//  File.swift
//  
//
//  Created by Joshua Buhler on 8/20/22.
//

import Foundation
import Vapor
//import Fluent

struct IncomingRunnersUpdate: Content {
    var incoming:[IncomingRunner]
}

//final class IncomingRunner: Content {
//    var bib:String
//    var name:String
//    var updateTime:String
//    var projectedTime:String
//    var station:String
//    
//    init(bib:String, name:String, updateTime:String, projectedTime:String, station:String) {
//        self.bib = bib
//        self.name = name
//        self.updateTime = updateTime
//        self.projectedTime = projectedTime
//        self.station = station
//    }
//}
