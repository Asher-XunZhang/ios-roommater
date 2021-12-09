//
//  User.swift
//  Roommater
//
//  Created by KAMIKU on 11/26/21.
//

import Foundation
import UIKit
import Alamofire
import AlamofireImage
import SwiftEventBus

class RoommateInfo : NSObject, NSSecureCoding {
    static var supportsSecureCoding: Bool { return true }
    
    func encode(with coder: NSCoder) {
        coder.encode(nickname, forKey: "Nickname")
        coder.encode(uid, forKey: "UID")
        coder.encode(rating, forKey: "Rating")
        coder.encode(avatar, forKey: "Avatar")
    }
    
    required convenience init?(coder: NSCoder) {
        self.init()
        nickname = coder.decodeObject(forKey: "Nickname") as? String
        uid = coder.decodeObject(forKey: "UID") as? String
        rating = coder.decodeObject(forKey: "Rating") as? Float
        avatar = coder.decodeObject(forKey: "Avatar") as? String
    }
    
    var nickname: String!
    var uid: String!
    var rating: Float!
    var avatar: String!
    var avatarImage : UIImage?
    
    override init() {
        super.init()
    }
    
    @discardableResult init(data: [String : Any]) {
        super.init()
        if let value = data["uid"] as? String{uid = value}
        if let value = data["nickname"] as? String{nickname = value}
        if let value = data["avatar"] as? String{self.avatar = value}
        if let value = data["rating"] as? Float {rating = value}
    }
    
    @discardableResult init(nickname : String, uid : String, rating : Float, avatar : String) {
        super.init()
        self.nickname = nickname
        self.uid = uid
        self.rating = rating
        self.avatar = avatar
    }
    
    func update(data: [String : Any], r : Bool){
        if let value = data["uid"] as? String{uid = value}
        if let value = data["nickname"] as? String{nickname = value}
        if let value = data["avatar"] as? String{self.avatar = value}
        if let value = data["rating"] as? Float {rating = value}
        
        if r {
            do{
                let user_encoded = try NSKeyedArchiver.archivedData(withRootObject: self, requiringSecureCoding: false)
                try user_encoded.write(to: SessionManager.ObjectPath.user.path)
                if uid != SessionManager.instance.user?.uid {
                    RoomInfo.users[uid] = self
                }
            }catch (let e){
                print(e)
                print("[Session Manager]Update roommate info failed")
            }
        }
    }
}

class UserInfo : RoommateInfo {
    override func encode(with coder: NSCoder) {
        super.encode(with: coder)
        coder.encode(username, forKey: "Username")
        coder.encode(email, forKey: "Email")
        SwiftEventBus.unregister(self)
    }
    
    required convenience init?(coder: NSCoder) {
        self.init()
        username = coder.decodeObject(forKey: "Username") as? String
        email = coder.decodeObject(forKey: "Email") as? String
    }
    
    override init() {
        super.init()
        SwiftEventBus.onBackgroundThread(self, name: "update"){ res in
            if let update : [String: Any] = res?.object as? [String: Any] {
                self.update(data: update, r: false)
            }
        }
        
        SwiftEventBus.onBackgroundThread(self, name: "destroy"){ res in
            
        }
    }
    
    var username : String!
    var email : String!
    
    override init(data: [String : Any]) {
        super.init(data: data)
        if let value = data["username"] as? String{self.username = value}
        if let value = data["email"] as? String{self.email = value}
        RoomInfo.users[uid] = RoommateInfo(nickname: self.nickname, uid: self.uid, rating: self.rating, avatar: self.avatar)

        if let value = data["dorm"] as? Int, value > 0 {
            APIAction.fetchDormInfo{ res in
                switch res {
                    case .Success(let data):
                        SessionManager.instance.initDorm(data: data as! [String : Any])
                    case .Timeout(let msg), .Fail(let msg), .Error(let msg), .NONE(let msg):
                        print(msg)
                }
            }
        }
    }
    
    override func update(data: [String : Any], r: Bool){
        super.update(data: data, r: r)
        if let value = data["email"] as? String{self.email = value}
        if let value = data["username"] as? String{self.nickname = value}
        do{
            let user_encoded = try NSKeyedArchiver.archivedData(withRootObject: self, requiringSecureCoding: false)
            try user_encoded.write(to: SessionManager.ObjectPath.user.path)
            RoomInfo.users[uid] = self
        }catch (let e){
            print(e)
            print("[Session Manager]Update user info failed")
        }
        RoomInfo.users[uid] = self
    }
    
    func getAvatarRequest()->URLRequest?{
        let token = UserDefaults.standard.string(forKey: "token")
        if avatar == "" || token == nil {return nil}
        return URLRequest(url: URL(string: avatar)!)
    }
}
