//
//  User.swift
//  Roommater
//
//  Created by KAMIKU on 10/8/21.
//

import Foundation
import ObjectMapper
import UIKit

class TsetUser : Mappable {
    var uid: String?
    var username: String?
    var token: String?
    required init?(map: Map) {}
    
    func mapping(map: Map) {
        uid <- map["uid"]
        username <- map["username"]
        token <- map["username"]
    }
}

class User: Mappable {
    var uid: String?
    var username: String?
    var email: String?
    var avatar: UIImage?
    var contacts: [Contact]?
    var rating: Float?
    var status: Status?
    var dorm: Dorm?

    required init?(map: Map) {
    }

    func mapping(map: Map) {
        uid <- map["uid"]
        username <- map["username"]
        email <- map["email"]
        rating <- map["rating"]
        status <- (map["status"], EnumTransform<Status>())
    }
}

enum Status: String {
    case inactive = "i"
    case active = "a"
    case banned = "b"
    case admin = "p"
}

struct Contact: Mappable {
    var name: String?
    var identity: String?
    var scheme: String?
    var host: String?
    var url: URL?

    init?(map: Map) {
    }

    mutating func mapping(map: Map) {
        name <- map["username"]
        identity <- map["username"]
        scheme <- map["username"]
        host <- map["username"]
        url = URL(string: "\(scheme)://\(host)\(identity)")
    }

    func redirect() {
        if !UIApplication.shared.canOpenURL(url!) {
            return
        }
        UIApplication.shared.open(url!, options: [:]) { (success) in
            if (success) {
                print("Success")
            } else {
                print("Fail")
            }
        }
    }
}
