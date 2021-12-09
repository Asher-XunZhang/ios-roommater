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

class RoommateInfo : NSObject, NSSecureCoding {
    static var supportsSecureCoding: Bool {
        return true
    }
    
    func encode(with coder: NSCoder) {
        coder.encode(nickname, forKey: "Nickname")
        coder.encode(uid, forKey: "UID")
        coder.encode(rating, forKey: "Rating")
        coder.encode(avatar, forKey: "Avatar")
    }
    
    required convenience init?(coder: NSCoder) {
        self.init()
        nickname = coder.decodeObject(forKey: "Nickname") as! String
        uid = coder.decodeObject(forKey: "UID") as! String
        rating = coder.decodeObject(forKey: "Rating") as! Float
        avatar = coder.decodeObject(forKey: "Avatar") as! String
        
    }
    
    static func == (lhs: RoommateInfo, rhs: RoommateInfo) -> Bool {
        return lhs.uid == rhs.uid
    }
    
    var nickname: String = ""
    var uid: String = ""
    var rating: Float = 0.0
    var avatar: String = ""
    var avatarImage : UIImage? = nil
    
    override init() {
        super.init()
    }
    
    @discardableResult init(data: [String : Any]) {
        super.init()
        if let value = data["uid"] as? String{
            uid = value
        }
        
        if let value = data["nickname"] as? String{
            nickname = value
        }
        
        if let value = data["avatar"] as? String{
            self.avatar = value
        }
        
        if let value = data["rating"] as? Float {
            rating = value
        }
    }
    
    @discardableResult init(nickname : String, uid : String, rating : Float, avatar : String) {
        super.init()
        self.nickname = nickname
        self.uid = uid
        self.rating = rating
        self.avatar = avatar
    }
    
    func update(data: [String : Any]){
        if let value = data["uid"] as? String{
            uid = value
        }
        
        if let value = data["nickname"] as? String{
            nickname = value
        }
        
        if let value = data["avatar"] as? String{
            self.avatar = value
        }
        
        if let value = data["rating"] as? Float {
            rating = value
        }
        
    }
}

class UserInfo : RoommateInfo {
    override func encode(with coder: NSCoder) {
//        super.encode(with: coder)
        print("1")
        coder.encode(nickname, forKey: "Nickname")
        print("2")
        coder.encode(uid, forKey: "UID")
        print("3")
        coder.encode(rating, forKey: "Rating")
        print("4")
        coder.encode(avatar, forKey: "Avatar")
        print("5")
        coder.encode(username, forKey: "Username")
        print("6")
        coder.encode(email, forKey: "Email")
        print("7")
    }
    
    required convenience init?(coder: NSCoder) {
        self.init()
        username = coder.decodeObject(forKey: "Username") as! String
        email = coder.decodeObject(forKey: "Email") as! String
    }
    
    override init() {super.init()}
    
    static func == (lhs: UserInfo, rhs: UserInfo) -> Bool {
        return lhs.uid == rhs.uid
    }
    
    var username : String = ""
    var email : String = ""
    
    override init(data: [String : Any]) {
        super.init(data: data)
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
        
        if let value = data["username"] as? String{
            self.username = value
        }
        
        if let value = data["uid"] as? String{
            self.uid = value
        }
        
        if let value = data["email"] as? String{
            self.email = value
        }
        
        if let value = data["nickname"] as? String{
            self.nickname = value
        }
        
        if let value = data["avatar"] as? String{
            self.avatar = value
        }
        
        if let value = data["rating"] as? Float {
            self.rating = value
        }
        
        if DormInfo.users.contains(where: {$0.value.uid != uid}){DormInfo.users[uid] = RoommateInfo(nickname: self.nickname, uid: self.uid, rating: self.rating, avatar: self.avatar)}
    }
    
    override func update(data: [String : Any]){
        if let value = data["username"] as? String{
            self.username = value
        }
        
        if let value = data["uid"] as? String{
            self.uid = value
        }
        
        if let value = data["email"] as? String{
            self.email = value
        }
        
        if let value = data["nickname"] as? String{
            self.nickname = value
        }
        
        if let value = data["avatar"] as? String{
            self.avatar = value
        }
        
        if let value = data["rating"] as? Float {
            self.rating = value
        }
        
    }
    
    func getAvatarRequest()->URLRequest?{
        let token = UserDefaults.standard.string(forKey: "token")
        if avatar == "" || token == nil {
            return nil
        }
        return URLRequest(url: URL(string: avatar)!)
    }
}
