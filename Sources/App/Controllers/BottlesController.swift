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
        //localhost:8080/bottles/showall
        bottles.get("showall", use: showAllRecords)
        
        //MARK: 레코드 검색해서 조회
        //localhost:8080/bottles/search?name={검색어}
        bottles.get("search", use: searchRecords)

        //MARK: Insert : Post 로 body에 스키마에 맞춘 json 을 담아서 쏘면 됨
        //localhost:8080/bottles/insert
        bottles.post("insert"){ req in
            try req.content
                .decode(Bottleshop.self)
                .save(on: req.db)
                .transform(to: Response(status: .created))
        }
        
        //MARK: Update : Patch 로 body에 스키마에 맞춘 json 을 담아서 쏘면 됨 (id값은 where 절에 대응)
        //localhost:8080/bottles/update
        
        //Router 에서 바로 실행하는 예제
        bottles.put("update") { req in
            let updatedBottleshop = try req.content.decode(Bottleshop.self) //데이터모델
            
            return Bottleshop.find(updatedBottleshop.id, on: req.db) //모델의 id를 찾아서~
                .unwrap(or: Abort(.notFound)) //없으면 not found
                .flatMap { bottleshop in //json 에 실려오는 키값들로 update하기
                    bottleshop.name = updatedBottleshop.name
                    bottleshop.address = updatedBottleshop.address
                    bottleshop.grade = updatedBottleshop.grade
                    bottleshop.openhour = updatedBottleshop.openhour
                    return bottleshop.update(on: req.db).transform(to: Response(status: .ok)) //response OK
                }
        }
        
        //함수로 update 실행하는 예제
        bottles.put("update2", use: updateRecords)
        
        //MARK: Delete : Url 에 id 값을 담아 쏘면 해당 레코드 삭제
        //localhost:8080/bottles/delete/{IDX}
        bottles.group("delete") { bottleshop in
            bottleshop.delete(":idx", use: deleteRecord)
        }
    }
    
    func index(req: Request) async throws -> String {
        return "Hello Bottles!"
    }
    
    //MARK: id 혹은 name 으로 데이터 레코드를 검색할 수 있는 예제
    func searchRecords(req: Request) async throws -> String {
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
    
    //레코드 업데이트하기
    func updateRecords(req: Request) throws -> EventLoopFuture<HTTPStatus>{
        let bottleshop = try req.content.decode(Bottleshop.self)
        
        return Bottleshop.find(bottleshop.id, on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMap { shop in
                shop.name = bottleshop.name
                shop.address = bottleshop.address
                shop.grade = bottleshop.grade
                shop.openhour = bottleshop.openhour
                return bottleshop.update(on: req.db).transform(to: .ok)
            }
    }
    
    //레코드 삭제하기
    func deleteRecord(req: Request) throws -> EventLoopFuture<HTTPStatus>{
        Bottleshop.find(req.parameters.get("idx"), on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMap{ shop in
                shop.delete(on: req.db)
            }
            .transform(to: .ok)
    }
}
