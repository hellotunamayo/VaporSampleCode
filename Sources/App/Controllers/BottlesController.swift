//
//  BottlesController.swift
//  
//
//  Created by Minyoung Yoo on 2023/01/11.
//

import Foundation
import Vapor
import Fluent
import FluentSQL


//Reference : https://www.youtube.com/watch?v=ae2JBfSFs0A

struct BottlesController : RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let bottles = routes.grouped("bottles")
        
        bottles.get(use:index)
        
        //MARK: 모든 레코드 조회
        bottles.get("showall", use: showAllRecords)

        //MARK: Insert : Post 로 body에 스키마에 맞춘 json 을 담아서 쏘면 됨
        bottles.post("insert"){ req in
            try req.content
                .decode(Bottleshop.self)
                .save(on: req.db)
                .transform(to: Response(status: .created))
        }
        
        //MARK: Update : Patch 로 body에 스키마에 맞춘 json 을 담아서 쏘면 됨 (id값은 where 절에 대응)
        bottles.patch("update") { req in
            let updatedBottleshop = try req.content.decode(Bottleshop.self) //데이터모델
            
            return Bottleshop.find(updatedBottleshop.id, on: req.db) //모델의 id를 찾아서~
                .unwrap(or: Abort(.notFound))
                .flatMap { bottleshop in //json 에 실려오는 키값들로 update!
                    bottleshop.name = updatedBottleshop.name
                    bottleshop.address = updatedBottleshop.address
                    bottleshop.grade = updatedBottleshop.grade
                    bottleshop.openhour = updatedBottleshop.openhour
                    return bottleshop.update(on: req.db).map{ "response ok" } //response OK!
                }
        }
    }
    
    //MARK: id, name 으로 데이터 레코드를 조회할 수 있는 예제
    func index(req: Request) async throws -> String {
        let id = try? req.query.get(Int.self, at:"id")
        let name = try? req.query.get(String.self, at:"name")
        let requestedQueryData = try await Bottleshop.query(on: req.db).group(.or){ group in //Model 에 질의하고 데이터 불러오는 부분
            //or 연산
            group.filter(\.$id == id ?? 0)
                .filter(\.$name == name ?? "")
        }.all()
        
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        let data = try encoder.encode(requestedQueryData)
        
        return String(data: data,encoding: .utf8) ?? "not found"
    }
    
    //모든 레코드 가져오기
    func showAllRecords(req:Request) async throws -> String{
        let requetedQueryData = try await Bottleshop.query(on: req.db).all()
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        let data = try encoder.encode(requetedQueryData)
        return String(data: data, encoding: .utf8) ?? "not found"
    }
}
