//
//  CreateCheckpoints.swift
//  
//
//  Created by Joshua Buhler on 4/13/22.
//

import Fluent

struct CreateCheckpoints: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema(Checkpoint.schema)
            .id()
            .field("name", .string, .required)
            .field("callsign", .string, .required)
            .create()
        
        try await Checkpoint(name:"Start", callsign:"A").create(on: database)
        try await Checkpoint(name:"Bountiful \"B\"", callsign:"B").create(on: database)
        try await Checkpoint(name:"Sessions Lift Off", callsign:"C").create(on: database)
        try await Checkpoint(name:"Swallow Rocks", callsign:"D").create(on: database)
        try await Checkpoint(name:"Big Mountain", callsign:"E").create(on: database)
        try await Checkpoint(name:"Alexander Ridge", callsign:"F").create(on: database)
        try await Checkpoint(name:"Lamb's Canyon", callsign:"G").create(on: database)
        try await Checkpoint(name:"Upper Big Water", callsign:"H").create(on: database)
        try await Checkpoint(name:"Desolation Lake", callsign:"I").create(on: database)
        try await Checkpoint(name:"Scott's Peak", callsign:"J").create(on: database)
        try await Checkpoint(name:"Brighton Lodge", callsign:"K").create(on: database)
        try await Checkpoint(name:"Ant Knolls", callsign:"L").create(on: database)
        try await Checkpoint(name:"Pole Line Pass", callsign:"M").create(on: database)
        try await Checkpoint(name:"Rock Springs", callsign:"N").create(on: database)
        try await Checkpoint(name:"Pot Hollow", callsign:"O").create(on: database)
        try await Checkpoint(name:"Staton", callsign:"P").create(on: database)
        try await Checkpoint(name:"Decker Canyon", callsign:"Q").create(on: database)
        try await Checkpoint(name:"Soldier Hollow", callsign:"R").create(on: database)
    }

    func revert(on database: Database) async throws {
        try await database.schema(Checkpoint.schema).delete()
    }
}


