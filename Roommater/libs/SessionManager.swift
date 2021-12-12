//
//  SessionManager.swift
//  Roommater
//
//  Created by KAMIKU on 11/26/21.
//

import Foundation
import UIKit
import Alamofire
import AlamofireImage
import SwiftEventBus
import StreamChat

class SessionManager {
    enum ObjectPath {
        case user
        case room
        fileprivate static var data = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first! as NSURL
        var path: URL {
            switch self {
            case .user: return SessionManager.ObjectPath.data.appendingPathComponent("userdata")!
            case .room: return SessionManager.ObjectPath.data.appendingPathComponent("roomdata")!
            }
        }
    }

    static let imageCache = AutoPurgingImageCache()

    var user: UserInfo?
    var dorm: RoomInfo?

    func userPreCheck() -> Bool {
        if UserDefaults.standard.string(forKey: "token") != nil,
           FileManager.default.fileExists(atPath: ObjectPath.user.path.path),
           let value = NSKeyedUnarchiver.unarchiveObject(withFile: ObjectPath.user.path.path) as? UserInfo {
            self.user = value
            if FileManager.default.fileExists(atPath: ObjectPath.room.path.path) {
                if let value = NSKeyedUnarchiver.unarchiveObject(withFile: ObjectPath.room.path.path) as? RoomInfo {
                    self.dorm = value
                }
            }
            return true
        }
        return false
    }

    func initUser(data: [String: Any]) {
        user = UserInfo(data: data)
    }

    func initDorm(data: [String: Any]) {
        dorm = RoomInfo(data: data)
    }

    func getAvatar(callback: @escaping (UIImage?, Int) -> Void) {
        if let thisUser = user {
            if thisUser.avatarImage == nil, let req = user?.getAvatarRequest() {
                if let image = SessionManager.imageCache.image(withIdentifier: thisUser.username!) {
                    self.user?.avatarImage = image
                    callback(image, 0)
                    return
                }
                AF.request(req).responseImage { res in
                    if case .success(let image) = res.result {
                        thisUser.avatarImage = image
                        SessionManager.imageCache.add(image, withIdentifier: thisUser.username!)
                        callback(image, 0)
                    }else{
                        callback(UIImage(named: "DefaultAvatar"), 1)
                    }
                }
            } else {
                callback(self.user?.avatarImage, 0)
            }
        } else {
            callback(UIImage(named: "DefaultAvatar"), 1)
        }
    }

    func updateAvatar(callback: @escaping (UIImage?, Int) -> Void) {
        if let req = user?.getAvatarRequest() {
            SessionManager.imageCache.removeImages(matching: req)
        }
        user?.avatarImage = nil
        getAvatar(callback: callback)
    }
}

extension SessionManager {
    static var instance = SessionManager()

    func close() {
        UserDefaults.standard.removeObject(forKey: "token")
        clearUser()
        clearRoom()
    }
    
    func clearRoom(){
        self.dorm = nil
        if FileManager.default.fileExists(atPath: ObjectPath.room.path.path) {
            do {
                try FileManager.default.removeItem(atPath: ObjectPath.room.path.path)
            } catch let error as NSError {
                print("error: \(error.localizedDescription)")
            }
        }
    }
    
    func clearUser(){
        self.user = nil
        if FileManager.default.fileExists(atPath: ObjectPath.user.path.path) {
            do {
                try FileManager.default.removeItem(atPath: ObjectPath.user.path.path)
            } catch let error as NSError {
                print("error: \(error.localizedDescription)")
            }
        }
    }
}

extension ChatClient {
    static var shared: ChatClient!
}
