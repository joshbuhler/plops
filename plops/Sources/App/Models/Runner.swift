//
//  Runner.swift
//  
//
//  Created by Joshua Buhler on 4/11/22.
//

import Fluent
import Vapor

final class Runner: Model, Content {
    static let schema = "runner"
    
    @ID(key: .id)
    var id:UUID?

    @Field(key: "bib")
    var bib:Int
    
    @Field(key: "firstName")
    var firstName:String
    
    @Field(key: "lastName")
    var lastName:String
    
    @Field(key: "gender")
    var gender:String?
    
    @Field(key: "age")
    var age:Int?
    
    @Field(key: "city")
    var city:String?
    
    @Field(key: "state")
    var state:String?
    
    @Field(key: "country")
    var country:String?

    init() { }

    init(id: UUID? = nil,
         bib:Int,
         firstName:String,
         lastName:String,
         gender:String?,
         age:Int?,
         city:String?,
         state:String?,
         country:String?) {
        
        self.id = id
        
        self.bib = bib
        self.firstName = firstName
        self.lastName = lastName
        self.gender = gender
        self.age = age
        self.city = city
        self.state = state
        self.country = country
    }
}

enum Gender:String, Codable {
    case male = "m"
    case female = "f"
    case unknown = "u"
}
