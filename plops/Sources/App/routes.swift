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
    

    try app.register(collection: TodoController())
}
