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

class RoommateInfo: NSObject, NSSecureCoding {
    static var supportsSecureCoding: Bool {
        return true
    }

    func encode(with coder: NSCoder) {
        coder.encode(nickname, forKey: "Nickname")
        coder.encode(uid, forKey: "UID")
        coder.encode(avatar, forKey: "Avatar")
    }

    required convenience init?(coder: NSCoder) {
        self.init()
        nickname = coder.decodeObject(forKey: "Nickname") as? String
        uid = coder.decodeObject(forKey: "UID") as? String
        avatar = coder.decodeObject(forKey: "Avatar") as? String
        if let req = getAvatarRequest() {
            if let image = SessionManager.imageCache.image(withIdentifier: "avatar_\(nickname!)") {
                self.avatarImage = image
            }
            AF.request(req).responseImage { res in
                if case .success(let image) = res.result {
                    self.avatarImage = image
                    SessionManager.imageCache.add(image, withIdentifier: "avatar_\(self.nickname!)")
                }else{
                    self.avatarImage = UIImage(named: "DefaultAvatar")
                }
            }
        }
    }

    var nickname: String!
    var uid: String!
    var avatar: String!
    var avatarImage: UIImage?

    override init() {
        super.init()
    }

    @discardableResult init(data: [String: Any]) {
        super.init()
        if let value = data["uid"] as? String {
            uid = value
        }
        if let value = data["nickname"] as? String {
            nickname = value
        }
        if let value = data["avatar"] as? String {
            self.avatar = value
        }
        if let req = getAvatarRequest() {
            if let image = SessionManager.imageCache.image(withIdentifier: "avatar_\(nickname!)") {
                self.avatarImage = image
            }
            AF.request(req).responseImage { res in
                if case .success(let image) = res.result {
                    self.avatarImage = image
                    SessionManager.imageCache.add(image, withIdentifier: "avatar_\(self.nickname!)")
                }else{
                    self.avatarImage = UIImage(named: "DefaultAvatar")
                }
            }
        }
    }

    @discardableResult init(nickname: String, uid: String, rating: Float, avatar: String) {
        super.init()
        self.nickname = nickname
        self.uid = uid
        self.avatar = avatar
    }

    func update(data: [String: Any]) {
        if let value = data["uid"] as? String {
            uid = value
        }
        if let value = data["nickname"] as? String {
            nickname = value
        }
        if let value = data["avatar"] as? String {
            self.avatar = value
        }
    }

    // MARK: CustomStringConvertible
    var des: String {
        return "RoommateInfo(nickname: \(nickname), uid: \(uid), avatar: \(avatar))"
    }

    @discardableResult func commit() -> Bool {
        do {
            let user_encoded = try NSKeyedArchiver.archivedData(withRootObject: self, requiringSecureCoding: false)
            try user_encoded.write(to: SessionManager.ObjectPath.user.path)
            if uid != SessionManager.instance.user?.uid {
                RoomInfo.users[uid] = self
            }
            return true
        } catch (let e) {
            print(e)
            print("[Session Manager]Update roommate info failed")
            return false
        }
    }
    
    func getAvatarRequest() -> URLRequest? {
        if avatar == nil || avatar == "" {
            return nil
        }
        return URLRequest(url: URL(string: avatar)!, timeoutInterval: 5)
    }

}

class UserInfo: RoommateInfo {
    override func encode(with coder: NSCoder) {
        super.encode(with: coder)
        coder.encode(username, forKey: "Username")
        coder.encode(email, forKey: "Email")
    }

    required convenience init?(coder: NSCoder) {
        self.init()
        username = coder.decodeObject(forKey: "Username") as? String
        email = coder.decodeObject(forKey: "Email") as? String
        nickname = coder.decodeObject(forKey: "Nickname") as? String
        uid = coder.decodeObject(forKey: "UID") as? String
        avatar = coder.decodeObject(forKey: "Avatar") as? String
        if let req = getAvatarRequest() {
            if let image = SessionManager.imageCache.image(withIdentifier: "avatar_\(nickname!)") {
                self.avatarImage = image
            }
            AF.request(req).responseImage { res in
                if case .success(let image) = res.result {
                    self.avatarImage = image
                    SessionManager.imageCache.add(image, withIdentifier: "avatar_\(self.nickname!)")
                }else{
                    self.avatarImage = UIImage(named: "DefaultAvatar")
                }
            }
        }
        print("UserInfo init local")
        print(self.des)
    }

    override init() {
        super.init()
        SwiftEventBus.onBackgroundThread(self, name: "update") { res in
            if let update: [String: Any] = res?.object as? [String: Any] {
                self.update(data: update)
            }
        }
        SwiftEventBus.onBackgroundThread(self, name: "destroy") { res in

        }
    }

    var username: String!
    var email: String!

    override init(data: [String: Any]) {
        super.init(data: data)
        if let value = data["username"] as? String {
            self.username = value
        }
        if let value = data["email"] as? String {
            self.email = value
        }
        print("UserInfo init online")
        print(self.des)
        RoomInfo.users[uid] = self
        if let value = data["dorm"] as? Int, value > 0 {
            APIAction.fetchDormInfo { res in
                switch res {
                case .Success(let data):
                    SessionManager.instance.initDorm(data: data as! [String: Any])
                case .Timeout(let msg), .Fail(let msg), .Error(let msg), .NONE(let msg):
                    print(msg)
                }
            }
        }
        commit()
    }

    override func update(data: [String: Any]) {
        super.update(data: data)
        if let value = data["email"] as? String {
            self.email = value
        }
        if let value = data["username"] as? String {
            self.username = value
        }
        RoomInfo.users[uid] = self
    }

    // MARK: CustomStringConvertible
    override var des: String {
        return "UserInfo(username: \(username), email: \(email), nickname: \(nickname), uid: \(uid), avatar: \(avatar))"
    }

    @discardableResult override func commit() -> Bool {
        do {
            let user_encoded = try NSKeyedArchiver.archivedData(withRootObject: self, requiringSecureCoding: false)
            try user_encoded.write(to: SessionManager.ObjectPath.user.path)
            RoomInfo.users[uid] = self
            return true
        } catch (let e) {
            print(e)
            print("[Session Manager]Save user info failed")
            return false
        }
    }
}
