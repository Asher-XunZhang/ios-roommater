//
//  Response.swift
//  Roommater
//
//  Created by KAMIKU on 10/16/21.
//

import Foundation

struct Response {
    var status : Int
    var msg : String
    var body : AnyObject?
    
    init(json : Dictionary<String, AnyObject>) {
        print(type(of: json))
        if let status = json["status"] as? Int {
            self.status = status
        }else {
            self.status = 501
            self.msg = "Phrase status Error"
        }
        
        if let msg = json["msg"] as? String {
            self.msg = msg
        }else {
            self.status = 502
            self.msg = "Phrase msg Error"
        }
    }
}
