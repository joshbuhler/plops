import Fluent
import Vapor

func routes(_ app: Application) throws {
    
    // TODO: move routes into RouteCollections (see TodoController.swift)
    app.get { req in
        req.redirect(to:"/checkpoints/m/inbound2")
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
    
    runners.get(":bib", "events") { req -> [RunnerEvent] in
        
        guard let bib = req.parameters.get("bib") else {
            throw Abort(.badRequest)
        }
        
        let events = try await RunnerEvent.query(on: req.db)
            .with(\.$runner)
            .with(\.$checkpoint)
            .all()
            .filter({ event in
                event.runner.bib == bib
            })
        
        return events
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
    
    checkpoints.get(":callsign", "inbound2") { req -> String in
//        let call = req.parameters.get("callsign") ?? "NOT FOUND"
        
        
        let logFileURL = URL(fileURLWithPath: "/Users/josh/Projects/plops/jyn/Tests/jynTests/Resources/big.log")
        guard let fileContents = try? String(contentsOf: logFileURL) else {
            return "Unable to load file"
        }
        
        let parser = LogParser()
        guard let runnerBlocks = parser.findIncomingRunnerBlocks(logString: fileContents),
              let lastUpdate = runnerBlocks.last,
              let runners = parser.findIncomingRunners(newLogs: lastUpdate),
              let station = runners.first?.station,
              let updateTime = runners.first?.updateTime else {
            return "No runners found"
        }
        
        var displayString = "Runners Currently Inbound to \(station) \n"
        displayString += "----------------------------------------------- \n"
        displayString += " Bib | Projected | Name \n"
        displayString += "----------------------------------------------- \n"
        for i in runners {
            var bibString = i.bib
            while bibString.count < 3 {
                bibString += " "
            }
            
            displayString += " \(bibString) |   \(i.projectedTime)    | \(i.name) \n"
        }
        displayString += "----------------------------------------------- \n"
        
        let currentTime = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm:ss"
        displayString += "Last update: \(updateTime) Current time: \(dateFormatter.string(from: currentTime))"
        
        return displayString
    }
    
    checkpoints.post(":callsign", "runevent") { req -> HTTPStatus in
        
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
        
        // Simplistic, but this is a simple event for now
        if let _ = try await RunnerEvent.query(on: req.db)
            .with(\.$runner)
            .group(.and, { group in
                group.filter(\.$time == eventJSON.time)
                    .filter(\.$runner.$id == runner.id!)
                    .filter(\.$eventType == eventJSON.eventType)
            })
                .first()
        {
            req.logger.info("Found existing event - ignoring")
            
            // We have an event based on the time, so ignore it. Eventually we can audit these, but we're keeping it simple for now.
            
            return HTTPStatus.ok
        }
        
        try await RunnerEvent(runnerID: runner.requireID(),
                              checkpointID: checkpoint.requireID(),
                              time: eventJSON.time,
                              eventType: eventJSON.eventType)
        .create(on: req.db)
        
        return HTTPStatus.created
    }
    
    checkpoints.post(":callsign", "incomingrunners") { req -> HTTPStatus in
        
        guard let callsign = req.parameters.get("callsign") else {
            throw Abort(.badRequest)
        }
        
        let eventJSON = try req.content.decode(IncomingRunnersUpdate.self)
        
        req.logger.info("EventJSON: \(eventJSON)")
        
        // How to best serve this?
        return HTTPStatus.created
    }
    
    // MARK: Runner Events
    
    let runevents = app.grouped("runevents")
    
    runevents.get("all") { req -> [RunnerEvent] in
        let events = try await RunnerEvent.query(on: req.db)
            .with(\.$runner)
            .with(\.$checkpoint)
            .all()
        return events
    }
    
//    try app.register(collection: TodoController())
}
