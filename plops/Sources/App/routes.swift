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
    
    runners.get(":bib") { req -> String in
        let bib = req.parameters.get("bib") ?? "NOT FOUND"
        return "Info about runner with bib: \(bib)"
    }
    
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
    
    checkpoints.get(":callsign") { req -> String in
        let call = req.parameters.get("callsign") ?? "NOT FOUND"
        return "Info about checkpoint with callsign: \(call)"
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
        let runnerEvent = try req.content.decode(RunnerEvent.self)
        
        switch runnerEvent.eventType {
        case .checkIn:
            print ("☕️ Runner checking IN: \(runnerEvent)")
        case .checkOut:
            print ("🛫 Runner checking OUT: \(runnerEvent)")
        case .flyby:
            print ("🚀 Runner FLYBY: \(runnerEvent)")
        }
        
        return HTTPStatus.ok
    }
    
    
    try app.register(collection: TodoController())
}

struct RunnerEvent: Content {
    
    enum EventType {
        case checkIn
        case checkOut
        case flyby
    }
    
    var bib:Int
    var inTime:Int?
    var outTime:Int?
    
    init(bib:Int, inTime:Int?, outTime:Int) {
        self.bib = bib
        self.inTime = inTime
        self.outTime = outTime
    }
    
    var eventType:EventType {
        get {
            if (inTime != nil && outTime != nil) {
                return .flyby
            }
            
            if (inTime != nil) {
                return .checkIn
            }
            
            return .checkOut
        }
    }
}
