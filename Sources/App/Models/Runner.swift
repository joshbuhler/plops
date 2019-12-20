//
//  Runner.swift
//  PLOpS
//
//  Created by Joshua Buhler on 12/19/19.
//

import FluentSQLite
import Vapor

enum Gender:String, Codable {
    case male = "m"
    case female = "f"
    case unknown = "u"
}

final class Runner: SQLiteModel {
    /// The bib number of the runner
    var id: Int?

    var firstName:String?
    var lastName:String?
    
    var gender:Gender = .unknown
    
    var age:Int = 0
    
    var city:String?
    var state:String?
    var country:String?

    init(id: Int? = nil) {
        self.id = id
    }
}

/// Allows `Runner` to be used as a dynamic migration.
extension Runner: Migration { }

/// Allows `Runner` to be encoded to and decoded from HTTP messages.
extension Runner: Content { }

/// Allows `Runner` to be used as a dynamic parameter in route definitions.
extension Runner: Parameter { }
