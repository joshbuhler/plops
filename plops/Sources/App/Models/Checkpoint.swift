//
//  Checkpoint.swift
//  
//
//  Created by Joshua Buhler on 4/11/22.
//

import Fluent
import Vapor

final class Checkpoint: Model, Content {
    static let schema = "checkpoints"
    
    @ID(key: .id)
    var id: UUID?

    @Field(key: "name")
    var name: String
    
    @Field(key: "callsign")
    var callsign: String

    init() { }

    init(id: UUID? = nil, name: String, callsign:String) {
        self.id = id
        self.name = name
        self.callsign = callsign
    }
}


