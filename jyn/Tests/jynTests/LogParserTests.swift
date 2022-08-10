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
>#312,   OK @ 2301MDT

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

>#175,   OK @ 2304MDT
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
        // NEED TO ACCOUNT FOR LINE BREAKS
        let parser = LogParser()
        let actualString = try? XCTUnwrap(parser.findIncomingRunners(newLogs: sample))
        
        XCTAssertEqual(actualString, expected)
    }
    
    func test_findReportedTemps() throws {
        let sample = """
>> Pole Line Pass Temp reported 53 at 0104

>Reported Temperatures
 Alexander Ridge  Temp. = 84 at 1606
 Lamb's Canyon  Temp. = 89 at 1624
 Scott's Peak  Temp. = 48 at 2302
 Brighton Lodge  Temp. = 49 at 2104
 Pole Line Pass  Temp. = 53 at 0104
 Decker Canyon  Temp. = 57 at 2147

>At 0106 hours, Runner 404  no times reported
"""
        let expected = """
>Reported Temperatures
 Alexander Ridge  Temp. = 84 at 1606
 Lamb's Canyon  Temp. = 89 at 1624
 Scott's Peak  Temp. = 48 at 2302
 Brighton Lodge  Temp. = 49 at 2104
 Pole Line Pass  Temp. = 53 at 0104
 Decker Canyon  Temp. = 57 at 2147

"""
        // NEED TO ACCOUNT FOR LINE BREAKS
        let parser = LogParser()
        let actualString = try? XCTUnwrap(parser.findReportedTemps(newLogs:sample))
        
        XCTAssertEqual(actualString, expected)
    }
    
//    func testPerformanceExample() throws {
//        // This is an example of a performance test case.
//        self.measure {
//            // Put the code you want to measure the time of here.
//        }
//    }
    
}
