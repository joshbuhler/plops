//
//  LogParserTests.swift
//  
//
//  Created by Joshua Buhler on 8/9/22.
//

import XCTest
@testable import jyn

class LogParserTests: XCTestCase {
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func test_findIncomingRunners() throws {
        let sample = """
>Next 10 runners inbound to  Pole Line Pass as of 2304 hours
209 Brian Culmo Projected in at 2302 hours
175 Andy Lefriec Projected in at 2310 hours
321 Grant Barnette Projected in at 2324 hours
143 Jessi Morton-Langehaug Projected in at 2326 hours
335 Nathan Williams Projected in at 2329 hours
281 Tyler Waterhouse Projected in at 2339 hours
322 Jonathan Crawley Projected in at 2339 hours
264 Neil Campbell Projected in at 2341 hours
285 Jay Aldous Projected in at 2353 hours
"""
        let expected = """
>Next 10 runners inbound to  Pole Line Pass as of 2304 hours
209 Brian Culmo Projected in at 2302 hours
175 Andy Lefriec Projected in at 2310 hours
321 Grant Barnette Projected in at 2324 hours
143 Jessi Morton-Langehaug Projected in at 2326 hours
335 Nathan Williams Projected in at 2329 hours
281 Tyler Waterhouse Projected in at 2339 hours
322 Jonathan Crawley Projected in at 2339 hours
264 Neil Campbell Projected in at 2341 hours
285 Jay Aldous Projected in at 2353 hours
"""
        
        let parser = LogParser()
        let actualString = try? XCTUnwrap(parser.findIncomingRunners(newLogs: sample))
        
        XCTAssertEqual(actualString, expected)
    }
    
    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
