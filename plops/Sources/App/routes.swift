import Fluent
import Vapor

func routes(_ app: Application) throws {
    
    // TODO: move routes into RouteCollections (see TodoController.swift)
    app.get { req in
        return "It works!"
    }

    app.get("hello") { req -> String in
        return "Hello, world!"
    }
    
    // MARK: Runners
    let runners = app.grouped("runners")
    
    // TODO: should this just be "/runners/" ?
    runners.get("all") { req -> [Runner] in
        let runners = try await Runner.query(on: req.db).all()
        return runners
    }
    
    runners.get(":bib") { req -> Runner in
        guard let bib = req.parameters.get("bib") else {
            req.logger.info("bib param missing")
            throw Abort(.badRequest)
        }
        
        guard let runner = try await Runner.query(on: req.db)
            .filter(\.$bib == bib)
            .first() else {
            throw Abort(.notFound)
        }
        
        return runner
    }
    
    // TODO: need a method to fetch runner by name
    
    runners.get(":bib", "lastlocation") { req -> String in
        let bib = req.parameters.get("bib") ?? "NOT FOUND"
        return "Info about a runner's last location with bib: \(bib)"
    }
    
    runners.post("create") { req -> HTTPStatus in
        // a JSON object describing the runner to add to the system
        let runner = try req.content.decode(Runner.self)
        print ("Creating runner: \(runner)")
        return HTTPStatus.ok
    }
    
    runners.delete(":bib") { req -> HTTPStatus in
        guard let bib = req.parameters.get("bib") else {
            return HTTPStatus.badRequest
        }
        print ("Deleting runner for bib: \(bib)")
        
        // TODO: should return some sort of error if the delete fails
        return HTTPStatus.ok
    }
    
    runners.get("dnf", "all") { req -> String in
        return "A list of all runners that DNF"
    }
    
    // MARK: Checkpoints
    
    let checkpoints = app.grouped("checkpoints")
    
    checkpoints.get("all") { req -> [Checkpoint] in
        let points = try await Checkpoint.query(on: req.db).all()
        return points
    }
    
    checkpoints.get(":callsign") { req -> Checkpoint in
        guard let callsign = req.parameters.get("callsign") else {
            throw Abort(.badRequest)
        }
        
        guard let checkpoint = try await Checkpoint.query(on: req.db)
            .filter(\.$callsign, .custom("ilike"), callsign)
            .first() else {
            throw Abort(.notFound)
        }
        return checkpoint
    }
    
    checkpoints.get(":callsign", "runners") { req -> String in
        let call = req.parameters.get("callsign") ?? "NOT FOUND"
        return "List of runners currently at checkpoint with callsign: \(call)"
    }
    
    checkpoints.get(":callsign", "inbound") { req -> String in
        let call = req.parameters.get("callsign") ?? "NOT FOUND"
        return "List of runners currently inbound to checkpoint with callsign: \(call)"
    }
    
    checkpoints.post(":callsign", "runevent") { req -> HTTPStatus in
//        let runnerEvent = try req.content.decode(RunnerEvent.self)
//
//        switch runnerEvent.eventType {
//        case .checkIn:
//            print ("☕️ Runner checking IN: \(runnerEvent)")
//        case .checkOut:
//            print ("🛫 Runner checking OUT: \(runnerEvent)")
//        case .flyby:
//            print ("🚀 Runner FLYBY: \(runnerEvent)")
//        }
        
        guard let callsign = req.parameters.get("callsign") else {
            throw Abort(.badRequest)
        }
        
        let eventJSON = try req.content.decode(RunnerPostModel.self)
        
        req.logger.info("EventJSON: \(eventJSON)")
        
        guard let runner = try await Runner.query(on: req.db)
            .filter(\.$bib == eventJSON.bib).first() else {
            throw Abort(.notFound)
        }
        
        guard let checkpoint = try await Checkpoint.query(on: req.db)
            .filter(\.$callsign, .custom("ilike"), callsign).first() else {
            throw Abort(.notFound)
        }
        
        try await RunnerEvent(runnerID: runner.requireID(),
                              checkpointID: checkpoint.requireID(),
                              time: eventJSON.time,
                              eventType: eventJSON.eventType)
        .create(on: req.db)
        
        // TODO: update events as needed if the times match
        
        return HTTPStatus.ok
    }
    
    // MARK: Runner Events
    
    let runevents = app.grouped("runevents")
    
    runevents.get("all") { req -> [RunnerEvent] in
        let events = try await RunnerEvent.query(on: req.db).all()
        return events
    }
    
    runevents.get("all") { req -> [RunnerEvent] in
        let events = try await RunnerEvent.query(on: req.db).all()
        
//        let response = events.map { event -> RunnerPostModel in
//
//            let runner = try await Runner.query(on: req.db)
//                .filter(\.$id == event.runner.id!)
//                .first()
//
//            let checkpoint = try await Checkpoint.query(on: req.db)
//                .filter(\.$id == event.checkpoint.id!)
//                .first()
//
//            return RunnerPostModel(bib: runner.,
//                                   time: event.time,
//                                   eventType: event.eventType)
//        }
        
        return events
    }
    
//    try app.register(collection: TodoController())
}
