//
//  User.swift
//  Roommater
//
//  Created by KAMIKU on 10/8/21.
//

import Foundation
import ObjectMapper
import UIKit

class User : Mappable {
    var uid : String?
    var username : String?
    var email : String?
    var avatar : UIImage?
    var contacts : [Contact]?
    var rating : Float?
    var status : Status?
    var dorm : Dorm?
    
    required init?(map: Map) {}
    
    func mapping(map: Map) {
        self.uid <- map["uid"]
        self.username <- map["username"]
        self.email <- map["email"]
        self.rating <- map["rating"]
        self.status <- (map["status"], EnumTransform<Status>())
    }
}

enum Status : String {
    case inactive = "i"
    case active = "a"
    case banned = "b"
    case admin = "p"
}

struct Contact : Mappable {
    var name : String?
    var identity : String?
    var scheme : String?
    var host : String?
    var url : URL?
    
    init?(map: Map) {}
    
    mutating func mapping(map: Map) {
        self.name <- map["username"]
        self.identity <- map["username"]
        self.scheme <- map["username"]
        self.host <- map["username"]
        
        url = URL(string: "\(scheme)://\(host)\(identity)")
    }
    
    func redirect(){
        if !UIApplication.shared.canOpenURL(url!) {
             return
        }
        
        UIApplication.shared.open(url!, options: [:]) { (success) in
           if (success) {
                print("Success")
           }else{
                print("Fail")
           }
        }
    }
}
