//
//  CreateRunners.swift
//  
//
//  Created by Joshua Buhler on 4/14/22.
//

import Foundation
import Vapor
import Fluent

struct CreateRunners: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema(Runner.schema)
            .id()
            .field("bib", .string, .required)
            .field("firstName", .string, .required)
            .field("lastName", .string, .required)
            .field("gender", .string)
            .field("age", .int)
            .field("city", .string)
            .field("state", .string)
            .field("country", .string)
            .field("events", .uuid)
            .create()
                
        let dirConfig = DirectoryConfiguration.detect()
        
        database.logger.info("resources: \(dirConfig.resourcesDirectory)")

        var csvURL = URL(fileURLWithPath: dirConfig.resourcesDirectory)
        csvURL.appendPathComponent("runners_2022.csv")
        let csvContents = try? String(contentsOf: csvURL)
        
        database.logger.info("Loading: \(csvURL.path)")
//        database.logger.info("csvContents: \(csvContents)")
        
        var bib = 0
        if let rows = csvContents?.components(separatedBy: .newlines) {
            database.logger.info("rows: \(rows.count)")
            let _ = rows.map { row in
                
                if (row.isEmpty) {
                    return
                }
                
                let props = row.components(separatedBy: ",")
                database.logger.info ("----------")
                
                let bibString = String(format: "%03ld", bib)
                database.logger.info("Bib: \(bibString)")
                database.logger.info("Last: \(props[0])")
                database.logger.info("First: \(props[1])")
                database.logger.info("Gender: \(props[2])")
                database.logger.info("Age: \(props[3])")
                database.logger.info("City: \(props[4])")
                database.logger.info("State: \(props[5])")
                database.logger.info("Country: \(props[6])")
                
                let runner = Runner(bib: bibString,
                                    firstName: props[1],
                                    lastName: props[0],
                                    gender: props[2],
                                    age: (Int(props[3])) ?? 0,
                                    city: props[4],
                                    state: props[5],
                                    country: props[6])
                
                let _ = runner.create(on: database)
                
                bib += 1
            }
        }
    }

    func revert(on database: Database) async throws {
        try await database.schema(Checkpoint.schema).delete()
    }
}


