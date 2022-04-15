//
//  RunnerEvent.swift
//  
//
//  Created by Joshua Buhler on 4/14/22.
//

import Vapor
import Fluent

struct RunnerPostModel: Content {
    
    enum EventType:String {
        case checkIn
        case checkOut
        case dnf
    }
    
    var bib:String
    var time:String
    var eventType:String
    var checkpoint:String?
    
    init(bib:String, time:String, eventType:String) {
        self.bib = bib
        self.time = time
        self.eventType = eventType
    }
}

final class RunnerEvent: Model, Content {
    
    static let schema = "runnerEvents"
    
//    enum EventType:String {
//        case checkIn
//        case checkOut
//        case dnf
//    }
    
    @ID(key: .id)
    var id:UUID?
    
    @Parent(key:"runner_id")
    var runner:Runner
    
    @Parent(key:"checkpoint_id")
    var checkpoint:Checkpoint
    
    // TODO: Can we use an actual date here?
    @Field(key: "time")
    var time:String
    
    @Field(key: "eventType")
    var eventType:String
    
    init() {}
    
    init(runnerID:Runner.IDValue, checkpointID:Checkpoint.IDValue, time:String, eventType:String) {
        self.$runner.id = runnerID
        self.$checkpoint.id = checkpointID
        self.time = time // TODO: be safe here and format w/ leading zeros
        self.eventType = eventType
    }
    
//    var eventType:EventType {
//        get {
//            if (inTime != nil && outTime != nil) {
//                return .flyby
//            }
//
//            if (inTime != nil) {
//                return .checkIn
//            }
//
//            return .checkOut
//        }
//    }
}
