//
//  RunnerCollection.swift
//  PLOpS
//
//  Created by Joshua Buhler on 12/19/19.
//

import Vapor

/** Runner Ops:
    - all runners
    - single runner
        - times
        - check-in
        - check-out
        - dnf
**/
final class RunnerCollection: RouteCollection {
    func boot(router: Router) throws {
        let runnerGroup = router.grouped("runner")
        
        runnerGroup.get ("all") { req -> Future<[Runner]> in
            let runner = Runner(id: nil)
            return Future.map(on: req) {
                return [runner]
            }
        }
        
        runnerGroup.get (Int.parameter) { req -> String in
            let bib = try req.parameters.next(Int.self)
            return "Runner: \(bib)"
        }
        
        
        runnerGroup.post(Runner.self, at: "create") { req, runner -> Future<Runner> in
            
            return runner.save(on: req)
        }
        
        
        
        
        runnerGroup.post(Int.parameter, "in") { req -> String in
            let bib = try req.parameters.next(Int.self)
            return "Runner: \(bib) - IN"
        }
        
        runnerGroup.post(Int.parameter, "out") { req -> String in
            let bib = try req.parameters.next(Int.self)
            return "Runner: \(bib) - OUT"
        }
    }
    
    
}
