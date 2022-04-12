//
//  Checkpoint.swift
//  
//
//  Created by Joshua Buhler on 4/11/22.
//

import Fluent
import Vapor

final class Checkpoint: Model, Content {
    static let schema = "checkpoint"
    
    @ID(key: .id)
    var id: UUID?

    @Field(key: "name")
    var name: String
    
    @Field(key: "code")
    var code: String

    init() { }

    init(id: UUID? = nil, name: String, code:String) {
        self.id = id
        self.name = name
        self.code = code
    }
}
