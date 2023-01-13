//
//  MainModel.swift
//  
//
//  Created by Minyoung Yoo on 2023/01/11.
//

import Foundation
import Vapor
import Fluent
import FluentMySQLDriver

//테이블마다 스키마
final class Bottleshop : Model{
    //Defining Bottleshop schema
    static let schema: String = "bottleshop"

//    @ID(key: .id)
//    var id: Int?
    @ID(custom: .id)
    var id: Int?

    @Field(key: "name")
    var name: String

    @Field(key: "grade")
    var grade: Int

    @Field(key: "address")
    var address: String

    @Field(key: "openhour")
    var openhour: String

    init() {}

    init(id: Int?, name: String, grade: Int, address: String, openhour: String){
        self.id = id
        self.name = name
        self.grade = grade
        self.address = address
        self.openhour = openhour
    }
}
