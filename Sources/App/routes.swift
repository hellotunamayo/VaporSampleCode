import Vapor

func routes(_ app: Application) throws {
    app.get { req async in
        "It works!"
    }

    app.get("name") { req async -> String in
        //URL Query
        let familyname : String? = req.query["familyname"]
        let lastname : String? = req.query["lastname"]
        
        return "Your Name is \(familyname ?? "") \(lastname ?? "")"
    }
    
//    app.post("api") { req in
//        try req.content
//            .decode(Bottleshop.self)
//            .save(on: req.db)
//            .transform(to: Response(status: .created))
//    }
    
    try app.register(collection: BottlesController())
}
