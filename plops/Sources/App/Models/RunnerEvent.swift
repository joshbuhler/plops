//
//  RunnerEvent.swift
//  
//
//  Created by Joshua Buhler on 4/14/22.
//

import Vapor
import Fluent

final class RunnerEvent: Model, Content {
    
    static let schema = "runnerEvents"
    
    enum EventType:String {
        case checkIn
        case checkOut
        case dnf
    }
    
    @ID(key: .id)
    var id:UUID?
    
    @Parent(key:"runner_id")
    var runner:Runner
    
    @Parent(key:"checkpoint_id")
    var checkpoint:Checkpoint
    
    @Field(key: "time")
    var time:Date
    
    @Field(key: "eventType")
    var eventType:EventType.RawValue
    
    init() {}
    
    init(runner:Runner, checkpoint:Checkpoint, time:Date, eventType:EventType) {
        self.runner = runner
        self.checkpoint = checkpoint
        self.time = time
        self.eventType = eventType.rawValue
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
