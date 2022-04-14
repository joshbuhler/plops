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
    
    func test_allCheckpoints () throws {
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
}

