//
//  User.swift
//  Roommater
//
//  Created by KAMIKU on 10/8/21.
//

import Foundation
import UIKit

class User {
    var uid : String
    var username : String
    var email : String
    //var avatar : URL? // todo avatar storage and type
    var contacts : [Contact]
    var rating : Float
    var status : Status
    var dorm : Dorm?
    
    init(uid: String, username : String, email: String, contacts : [Contact], rating : Float, status: Status) {
        self.uid = uid
        self.username = username
        self.email = email
        self.contacts = contacts
        self.rating = rating
        self.status = status
    }
}

enum Status {
    case inactive
    case active
    case banned
    case admin
}

struct Todo {
   //todo

}

struct Contact {
    var name : String
    var identity : String
    var scheme : String
    var host : String
    var url : URL?
    
    init(name:String, host:String, identity:String, scheme:String) {
        self.name = name
        self.identity = identity
        self.scheme = scheme
        self.host = host
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
