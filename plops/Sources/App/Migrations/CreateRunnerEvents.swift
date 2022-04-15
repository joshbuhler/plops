//
//  CreateRunnerEvents.swift
//  
//
//  Created by Joshua Buhler on 4/15/22.
//

import Foundation
import Vapor
import Fluent

struct CreateRunnerEvents: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema(RunnerEvent.schema)
            .id()
            .field("runner_id", .uuid, .required, .references(Runner.schema, "id"))
            .field("checkpoint_id", .uuid, .required, .references(Checkpoint.schema, "id"))
            .field("time", .string, .required)
            .field("eventType", .string, .required)
            .create()
    }

    func revert(on database: Database) async throws {
        try await database.schema(RunnerEvent.schema).delete()
    }
}
