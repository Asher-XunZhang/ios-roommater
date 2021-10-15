//
//  User.swift
//  Roommater
//
//  Created by KAMIKU on 10/8/21.
//

import Foundation
import UIKit
//import JWTKit

//struct UserPayload: JWTPayload, Equatable {
//    enum CodingKeys: String, CodingKey {
//        case subject = "sub"
//        case expiration = "exp"
//        case isAdmin = "admin"
//    }
//    // The "sub" (subject) claim identifies the principal that is the
//    // subject of the JWT.
//    var subject: SubjectClaim
//    var expiration: ExpirationClaim
//    var uid : String
//    var username : String
//    var email : String
//    var rating : Float
//    var status : Status
//
//    func verify(using signer: JWTSigner) throws {
//        try self.expiration.verifyNotExpired()
//    }
//}

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
    
//    init(data: String){
//        let signers = JWTSigners()
//        signers.use(.hs256(key: "secret"))
//        if let user = try? signers.verify(data, as: UserPayload.self){
//            print(user)
//            self.uid = user.uid
//            self.username = user.username
//            self.email = user.email
//            self.rating = user.rating
//            self.status = user.status
//        }
//
//    }
}

enum Status : String {
    case inactive = "i"
    case active = "a"
    case banned = "b"
    case admin = "p"
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
