//
//  CheckpointRouteTests.swift
//  
//
//  Created by Joshua Buhler on 4/14/22.
//

@testable import App
import XCTVapor
import XCTest

final class CheckpointRouteTests: XCTestCase {
    
    func test_checkpoints_all () throws {
        let app = Application(.testing)
        defer { app.shutdown() }
        try configure(app)

        try app.test(.GET, "checkpoints/all", afterResponse: { response in
            XCTAssertEqual(response.status, .ok)
            
            let checkpoints = try response.content.decode([Checkpoint].self)
            XCTAssertEqual(checkpoints.count, 18)
//            checkpoints[3].callsign == ...
        })        
    }
    
    func test_checkpoints_single () throws {
        let app = Application(.testing)
        defer { app.shutdown() }
        try configure(app)

        try app.test(.GET, "checkpoints/M", afterResponse: { response in
            XCTAssertEqual(response.status, .ok)
            
            let checkpoint = try response.content.decode(Checkpoint.self)
            
            XCTAssertEqual(checkpoint.callsign.lowercased(), "m")
            XCTAssertEqual(checkpoint.name, "Pole Line Pass")
        })
        
        // Try lower-case, just in case
        try app.test(.GET, "checkpoints/m", afterResponse: { response in
            XCTAssertEqual(response.status, .ok)
            
            let checkpoint = try response.content.decode(Checkpoint.self)
            
            XCTAssertEqual(checkpoint.callsign.lowercased(), "m")
            XCTAssertEqual(checkpoint.name, "Pole Line Pass")
        })
    }
    
    func test_checkpoints_notFound () throws {
        let app = Application(.testing)
        defer { app.shutdown() }
        try configure(app)

        try app.test(.GET, "checkpoints/Mi6", afterResponse: { response in
            XCTAssertEqual(response.status, .notFound)
        })
    }
}

