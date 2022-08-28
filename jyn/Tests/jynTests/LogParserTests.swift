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
000 Brian Culmo Projected in at 2302 hours
001 Andy Lefriec Projected in at 2310 hours
002 Grant Barnette Projected in at 2324 hours
003 I Have ThreeNames Projected in at 2326 hours
004 And I Have Four Projected in at 0004 hours
005 Tyler Waterhouse Projected in at 2339 hours
006 Jonathan Crawley Projected in at 2339 hours
007 Neil Campbell Projected in at 2341 hours
008 Jay Aldous Projected in at 2353 hours
009 Groot Projected in at 1234 hours
0010 Donkey Kong Projected in at 2345 hours

>#175,   OK @ 2304MDT
"""
        let parser = LogParser()
        let actualRunners:[IncomingRunner] = try XCTUnwrap(parser.findIncomingRunners(newLogs: sample))
        XCTAssertEqual(actualRunners.count, 11)
        
        let _ = actualRunners.map { temp in
            print ("Runner: \(temp)")
        }
        
        guard actualRunners.count >= 9 else {
            XCTFail()
            return
        }
        
        let poleLine_expected = IncomingRunner(station: "Pole Line Pass",
                                               updateTime: "2304",
                                               bib: "008",
                                               name: "Jay Aldous",
                                               projectedTime: "2353")
        let poleLine_actual = actualRunners[8]
        XCTAssertEqual(poleLine_actual, poleLine_expected)
        
        let poleLine_expected_singleName = IncomingRunner(station: "Pole Line Pass",
                                                          updateTime: "2304",
                                                          bib: "009",
                                                          name: "Groot",
                                                          projectedTime: "1234")
        let poleLine_actual_singleName = actualRunners[9]
        XCTAssertEqual(poleLine_actual_singleName, poleLine_expected_singleName)
        
        let poleLine_expected_threeNames = IncomingRunner(station: "Pole Line Pass",
                                                          updateTime: "2304",
                                                          bib: "003",
                                                          name: "I Have ThreeNames",
                                                          projectedTime: "2326")
        let poleLine_actual_threeNames = actualRunners[3]
        XCTAssertEqual(poleLine_actual_threeNames, poleLine_expected_threeNames)
        
        let poleLine_expected_fourNames = IncomingRunner(station: "Pole Line Pass",
                                                          updateTime: "2304",
                                                          bib: "004",
                                                          name: "And I Have Four",
                                                          projectedTime: "0004")
        let poleLine_actual_fourNames = actualRunners[4]
        XCTAssertEqual(poleLine_actual_fourNames, poleLine_expected_fourNames)
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
        let parser = LogParser()
        let actualTemps:[Temperature] = try XCTUnwrap(parser.findReportedTemps(newLogs: sample))
        XCTAssertEqual(actualTemps.count, 6)
        
        let _ = actualTemps.map { temp in
            print ("Temp: \(temp)")
        }
        
        guard actualTemps.count >= 5 else {
            XCTFail()
            return
        }
        
        let poleLine_expected = Temperature(station: "Pole Line Pass",
                                            temp: 53,
                                            time: "0104")
        let poleLine_actual = actualTemps[4]
        XCTAssertEqual(poleLine_actual, poleLine_expected)
    }
    
//    func testPerformanceExample() throws {
//        // This is an example of a performance test case.
//        self.measure {
//            // Put the code you want to measure the time of here.
//        }
//    }
    
    func test_findAllUpdates () throws {
//        let logFilePath = Bundle.main.path(forResource: "big", ofType: "log")
//        XCTAssertNotNil(logFilePath)
        
        // https://stackoverflow.com/a/58034307/52566
        let thisSourceFile = URL(fileURLWithPath: #file)
        let thisDirectory = thisSourceFile.deletingLastPathComponent()
        let testDir = thisDirectory.appendingPathComponent("Resources")
        let resourceURL = testDir.appendingPathComponent("big.log")
        print ("resourceURL: \(resourceURL)")
        
        let logString = try XCTUnwrap(String(contentsOf: resourceURL))
    }
}
