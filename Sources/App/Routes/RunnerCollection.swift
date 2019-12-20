//
//  RunnerCollection.swift
//  PLOpS
//
//  Created by Joshua Buhler on 12/19/19.
//

import Vapor

final class RunnerCollection: RouteCollection {
    func boot(router: Router) throws {
        let runner = router.grouped("runner")
        
        runner.get ("all") { req -> String in
            return "All runners"
        }
        
        runner.get (Int.parameter) { req -> String in
            let bib = try req.parameters.next(Int.self)
            return "Runner: \(bib)"
        }
    }
    
    
}
