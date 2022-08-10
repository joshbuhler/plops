//
//  LogParser.swift
//  
//
//  Created by Joshua Buhler on 8/9/22.
//

import Foundation

public protocol LogParserProtocol {
    func findIncomingRunners (newLogs:String) throws -> String?
    func findReportedTemps (newLogs:String) -> [Temperature]?
}

public class LogParser:LogParserProtocol {
    
    /// Finds incoming runners.
    /// - Parameter newLogs: The string to parse for incoming runner info.
    public func findIncomingRunners (newLogs:String) throws -> String? {
        
        // TODO: This should probably instead spit out a list of Runners
        
        let pattern = #"""
        (?<header>(>Next 10 runners inbound to .* as of \d{1,4} hours))
        (?<runner>(^\d{1,4}(.+ ){1,3}Projected in at \d{1,4} hours\n?)){0,10}
        """#
        
        return try? runRegEx(pattern: pattern, onString: newLogs) ?? nil
    }
    
    @discardableResult
    public func findReportedTemps (newLogs:String) -> [Temperature]? {
        let tempBlockPattern = #"""
            (?<header>(>Reported Temperatures))
            (?<temps>(^ (.+)  Temp. = \d{1,3} at \d{1,4}\n?))+
            """#
        guard let tempBlock = try? runRegEx(pattern: tempBlockPattern, onString: newLogs) else {
            return nil
        }
        
        var temps = [Temperature]()
        
        let tempLinePattern = #"(^ (.+)  Temp. = \d{1,3} at \d{1,4})"#
        guard let tempLineStrings = try? runRegEx2(pattern: tempLinePattern, onString: tempBlock) else {
            return nil
        }
        temps = tempLineStrings.map({ (tempLineString:String) -> Temperature in
            guard var nameString = try? runRegEx(pattern: #"^ (.+)  Temp"#, onString: tempLineString),
                  let tempString = try? runRegEx(pattern: #"Temp. = \d{1,3}"#, onString: tempLineString),
                  let timeString = try? runRegEx(pattern: #"at \d{1,4}"#, onString: tempLineString) else {
                return Temperature(station: "EMPTY", temp: -1, time: "0000")
            }
            
            // Lose the space at the beginning of the line
            nameString.removeFirst()
            
            let stationValue = nameString.replacingOccurrences(of: "  Temp", with: "")
            let tempValue = Int(tempString.replacingOccurrences(of: "Temp. = ", with: "")) ?? -1
            let timeValue = timeString.replacingOccurrences(of: "at ", with: "")
            return Temperature(station: stationValue,
                               temp: tempValue,
                               time: timeValue)
        })
        
        
        return temps
    }
    
    private func runRegEx (pattern:String, onString:String) throws -> String? {
        var returnString:String?
        
        let regex = try NSRegularExpression(pattern: pattern, options: [.anchorsMatchLines])
        //let range = NSRange(0..<logOutput.count)
        let range = NSRange(location: 0, length: onString.count)
        regex.enumerateMatches(in: onString, options: [], range: range) { (match, _, stop) in
            guard let match = match else {
                print("no match")
                return
            }
            if (match.numberOfRanges > 0) {
                if let foundRange = Range(match.range(at:0), in: onString) {
                    let matchText = onString[foundRange]
                    print ("✅ \(matchText)")
                    returnString = String(matchText)
                }
            }
        }
        
        return returnString
    }
    
    private func runRegEx2 (pattern:String, onString:String) throws -> [String]? {
        var returnStrings = [String]()
        
        let regex = try NSRegularExpression(pattern: pattern, options: [.anchorsMatchLines])
        let range = NSRange(location: 0, length: onString.count)
        regex.enumerateMatches(in: onString, options: [], range: range) { (match, _, stop) in
            guard let match = match else {
                print("no match")
                return
            }
            if (match.numberOfRanges > 0) {
                if let foundRange = Range(match.range(at:0), in: onString) {
                    let matchText = onString[foundRange]
                    print ("✅ \(matchText)")
                    returnStrings.append(String(matchText))
                }
            }
        }
        
        return returnStrings
    }
}

extension LogParser: FileMonitorDelegate {
    func didReceive(changes: String) {
        try? self.findIncomingRunners(newLogs: changes)
        self.findReportedTemps(newLogs: changes)
    }
}
