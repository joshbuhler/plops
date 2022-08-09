//
//  LogParser.swift
//  
//
//  Created by Joshua Buhler on 8/9/22.
//

import Foundation

public protocol LogParserProtocol {
    func findIncomingRunners (newLogs:String) throws -> String?
}

public class LogParser:LogParserProtocol {
    
    /// Finds incoming runners.
    /// - Parameter newLogs: The string to parse for incoming runner info.
    public func findIncomingRunners (newLogs:String) throws -> String? {
        
        // TODO: This should probably instead spit out a list of Runners
        var returnString:String?
        
        let pattern = #"""
        (?<header>(>Next 10 runners inbound to .* as of \d{1,4} hours))
        (?<runner>(^\d{1,4}(.+ ){1,3}Projected in at \d{1,4} hours\n?)){0,10}
        """#
        let regex = try NSRegularExpression(pattern: pattern, options: [.anchorsMatchLines])
        //let range = NSRange(0..<logOutput.count)
        let range = NSRange(location: 0, length: newLogs.count)
        regex.enumerateMatches(in: newLogs, options: [], range: range) { (match, _, stop) in
            guard let match = match else {
                print("no match")
                return
            }
            if (match.numberOfRanges > 0) {
                print ("numberOfRanges: \(match.numberOfRanges)")
                if let foundRange = Range(match.range(at:0), in: newLogs) {
                    print ("foundRange: \(foundRange.lowerBound)..<\(foundRange.upperBound)")
                    let matchText = newLogs[foundRange]
                    print ("✅ match: \(matchText)")
                    returnString = String(matchText)
                }
            }
        }
        
        return returnString
    }
}
