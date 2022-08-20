//
//  JynCommands.swift
//  
//
//  Created by Joshua Buhler on 8/18/22.
//
// https://apple.github.io/swift-argument-parser/documentation/argumentparser/gettingstarted/

import Foundation
import ArgumentParser

@main
final class Jyn: ParsableCommand, Decodable {
    init() {
       
    }
    
    //@Flag(help: "The path to the file monitor for changes.")
    @Option var logFile:String
    @Option var interval:TimeInterval = 10.0
    
    enum CodingKeys:String, CodingKey {
        case logFile
        case interval
    }
    
    private var fileMonitor:FileMonitorProtocol?
    private var logParser:LogParser?
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        logFile = try container.decode(String.self, forKey: .logFile)
        interval = try container.decode(Double.self, forKey: .interval)
    }
    
    func run() throws {
        let fileMan = FileManager.default
        guard fileMan.fileExists(atPath: logFile) else {
            throw RuntimeError("File not found: \(logFile)")
        }
        
        try? startLogParser(logPath: logFile)
        
        RunLoop.current.run()
    }
    
    func startLogParser (logPath:String) throws {
        let fileURL = URL(fileURLWithPath: logPath)
        guard let fileMon = try? FileMonitor(url: fileURL, monitorInterval: interval) else {
            throw RuntimeError("Unable to create FileMonitor")
        }
        
        logParser = LogParser()
        
        fileMonitor = fileMon
        fileMonitor?.delegate = logParser
    }
}


struct RuntimeError: Error, CustomStringConvertible {
    var description: String
    
    init(_ description: String) {
        self.description = description
    }
}

