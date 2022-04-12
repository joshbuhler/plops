import Fluent
import Vapor

func routes(_ app: Application) throws {
    app.get { req in
        return "It works!"
    }

    app.get("hello") { req -> String in
        return "Hello, world!"
    }
    
    let runners = app.grouped("runners")
    
    // TODO: should this just be "/runners/" ?
    runners.get("all") { req -> String in
        return "A list of all runners in the system"
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
        let bib = req.parameters.get("bib")
        print ("Deleting runner for bib: \(bib)")
        
        // TODO: should return some sort of error if the delete fails
        return HTTPStatus.ok
    }
    
    runners.get("dnf", "all") { req -> String in
        return "A list of all runners that DNF"
    }
    
    try app.register(collection: TodoController())
}
