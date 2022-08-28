//
//  LogParser.swift
//  
//
//  Created by Joshua Buhler on 8/9/22.
//

import Foundation
//import SKQueue

public protocol LogParserProtocol {
    func findIncomingRunners (newLogs:String) -> [IncomingRunner]?
    func findReportedTemps (newLogs:String) -> [Temperature]?
}

public class LogParser:LogParserProtocol {
    
    /// Finds incoming runner blocks in a string.
    /// - Parameter newLogs: The string to parse for incoming runner info.
    @discardableResult
    public func findIncomingRunnerBlocks (logString:String) -> [String]? {
        let runnerBlockPattern = #"""
        (?<header>(>Next 10 runners inbound to .* as of \d{1,4} hours))
        (?<runner>(^\d{1,4}(.+ )Projected in at \d{1,4} hours\n?))+
        """#
        
        return try? runRegEx(pattern: runnerBlockPattern, onString: logString)
    }
    
    
    /// Finds incoming runners in a block. Will return the first results found.
    /// - Parameter newLogs: The string to parse for incoming runner info.
    @discardableResult
    public func findIncomingRunners (newLogs:String) -> [IncomingRunner]? {
        
        guard let runnerBlock = findIncomingRunnerBlocks(logString: newLogs)?.first,
              let stationString = try? runRegEx(pattern: #"(inbound to  .*) as of"#, onString: runnerBlock)?.first,
              let updateTimeString = try? runRegEx(pattern: #"\d{1,4} hours"#, onString: runnerBlock)?.first else {
            return nil
        }
        
        var runners = [IncomingRunner]()
        
        let runnerLinePattern = #"(^\d{1,4}(.+ )Projected in at \d{1,4} hours)+"#
        guard let runnerLineStrings = try? runRegEx(pattern: runnerLinePattern, onString: runnerBlock) else {
            return nil
        }
        runners = runnerLineStrings.map({ (tempLineString:String) -> IncomingRunner in
            guard let bibString = try? runRegEx(pattern: #"^\d{1,4}"#, onString: tempLineString)?.first,
                  let nameString = try? runRegEx(pattern: #"(?=[^\d ])(.+ )Projected"#, onString: tempLineString)?.first,
                  let projectedString = try? runRegEx(pattern: #"at \d{1,4}"#, onString: tempLineString)?.first else {
                return IncomingRunner(station: "",
                                      updateTime: "0000",
                                      bib: "-1",
                                      name: "",
                                      projectedTime: "0000")
            }
                        
            let stationValue = stationString.replacingOccurrences(of: "inbound to  ", with: "")
                .replacingOccurrences(of: " as of", with: "")
            let updateTimeValue = updateTimeString.replacingOccurrences(of: " hours", with: "")
            let bibValue = bibString
            let nameValue = nameString.replacingOccurrences(of: " Projected", with: "")
            let projectedTimeValue = projectedString.replacingOccurrences(of: "at ", with: "")
            return IncomingRunner(station: stationValue,
                                  updateTime: updateTimeValue,
                                  bib: bibValue,
                                  name: nameValue,
                                  projectedTime: projectedTimeValue)
        })
        
        return runners
    }
    
    @discardableResult
    public func findReportedTemps (newLogs:String) -> [Temperature]? {
        let tempBlockPattern = #"""
            (?<header>(>Reported Temperatures))
            (?<temps>(^ (.+)  Temp. = \d{1,3} at \d{1,4}\n?))+
            """#
        guard let tempBlock = try? runRegEx(pattern: tempBlockPattern, onString: newLogs)?.first else {
            return nil
        }
        
        var temps = [Temperature]()
        
        let tempLinePattern = #"(^ (.+)  Temp. = \d{1,3} at \d{1,4})"#
        guard let tempLineStrings = try? runRegEx(pattern: tempLinePattern, onString: tempBlock) else {
            return nil
        }
        temps = tempLineStrings.map({ (tempLineString:String) -> Temperature in
            guard var nameString = try? runRegEx(pattern: #"^ (.+)  Temp"#, onString: tempLineString)?.first,
                  let tempString = try? runRegEx(pattern: #"Temp. = \d{1,3}"#, onString: tempLineString)?.first,
                  let timeString = try? runRegEx(pattern: #"at \d{1,4}"#, onString: tempLineString)?.first else {
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
    
    private func runRegEx (pattern:String, onString:String) throws -> [String]? {
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
                    //print ("✅ \(matchText)")
                    returnStrings.append(String(matchText))
                }
            }
        }
        
        return returnStrings
    }
    
    func postData (postURL:URL, data:Data) {
        
        var request = URLRequest(url: postURL)
        request.httpMethod = "POST"
        request.httpBody = data
        
        // TODO: async/await
        let task = URLSession.shared.dataTask(with: request) { data, httpResponse, error in
            if let error = error {
                print ("Error posting URL: \(error)")
                return
            }
            
            guard let data = data,
                  let responseString = String(data: data, encoding: .utf8) else {
                print ("Error getting data")
                return
            }
            
            print ("Response: \(responseString)")
        }
        task.resume()
    }
}

//extension LogParser: FileMonitorDelegateProtocol {
//    func didReceive(changes: String) {
//        
//        print ("---------- didReceiveChanges ----------")
//        let foundRunners = self.findIncomingRunners(newLogs: changes) ?? [IncomingRunner]()
//        let foundTemps = self.findReportedTemps(newLogs: changes) ?? [Temperature]()
//        
//        // TODO: if verbose - use a logger w/ log levels. verbose will need to only change the logger setting
//        for i in foundRunners {
//            print ("Runner: \(i)\n")
//        }
//        
//        // TODO: store vars for the last runners found.
//        /// This way, we always have a StationStatus that could be written out
//        /// to the server with the last known status, not just the most recent.
//        /// Will probably just write a simple HTML file to have Apache serve up.
//        let status = StationStatus(incomingRunners: foundRunners,
//                                   temperatures: foundTemps)
//        let jsonEncoder = JSONEncoder()
//        if let updateJSON = try? jsonEncoder.encode(status),
//           let postURL = URL(string: "http://127.0.0.1:8080/checkpoints/m/incomingrunners"),
//           let jsonData = String(data: updateJSON , encoding: String.Encoding.utf8) {
//            print("updateJSON: \(jsonData)")
//            self.postData(postURL: postURL,
//                          data: updateJSON)
//        }
//        
//        // TODO: if verbose
//        let _ = foundTemps.map { temp in
//            print ("Temp: \(temp)")
//        }
//        print ("---------------------------------------")
//    }
//}
