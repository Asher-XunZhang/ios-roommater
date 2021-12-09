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

class SessionManager{
    enum ObjectPath {
        case user
        case room
        fileprivate static var data = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first! as NSURL
        var path : URL {
            switch self {
                case .user:
                    return SessionManager.ObjectPath.data.appendingPathComponent("userdata")!
                case .room:
                    return SessionManager.ObjectPath.data.appendingPathComponent("roomdata")!
            }
        }
    }
    fileprivate static let imageCache = AutoPurgingImageCache()
    var user : UserInfo?
    var dorm : RoomInfo?
    
    init() {
        SwiftEventBus.onBackgroundThread(self, name: "login"){ _ in
            ImageDownloader.instance = ImageDownloader(
                configuration: APIAction.getDefaultURLSessionConfig(),
                downloadPrioritization: .fifo,
                maximumActiveDownloads: 4,
                imageCache: SessionManager.imageCache
            )
        }
        
        SwiftEventBus.onBackgroundThread(self, name: "logout"){ _ in
            ImageDownloader.instance = nil
        }
    }
    
    func userPreCheck() -> Bool {
        if UserDefaults.standard.string(forKey: "token") != nil, FileManager.default.fileExists(atPath: ObjectPath.user.path.path){
            if let value = NSKeyedUnarchiver.unarchiveObject(withFile: ObjectPath.user.path.path) as? UserInfo {
                ImageDownloader.instance = ImageDownloader(
                    configuration: APIAction.getDefaultURLSessionConfig(),
                    downloadPrioritization: .fifo,
                    maximumActiveDownloads: 4,
                    imageCache: SessionManager.imageCache
                )
                self.user = value
                print("[Session Manager]Successfully Init User(local)")
                if FileManager.default.fileExists(atPath: ObjectPath.room.path.path) {
                    if let value = NSKeyedUnarchiver.unarchiveObject(withFile: ObjectPath.room.path.path) as? RoomInfo {
                        self.dorm = value
                        print("[Session Manager]Successfully Init Room(local)")
                    }
                }
                return true
            }
        }
        
        return false
    }
    
    func initUser(data: [String : Any]){
        user = UserInfo(data: data)
        print("[Session Manager]Successfully Init User(json)")
        if user != nil {
            do{
                let user_encoded = try NSKeyedArchiver.archivedData(withRootObject: user!, requiringSecureCoding: false)
                try user_encoded.write(to: ObjectPath.user.path)
                RoomInfo.users[user!.uid] = user
            }catch (let e){
                print(e)
                print("[Session Manager]Save User failed Failed")
            }
        }
    }
    
    func initDorm(data: [String : Any]){
        dorm = RoomInfo(data: data)
        if dorm != nil {
            do{
                let room_encoded = try NSKeyedArchiver.archivedData(withRootObject: dorm!, requiringSecureCoding: false)
                try room_encoded.write(to: ObjectPath.room.path)
            }catch (let e){
                print(e)
                print("[Session Manager]Save room info failed!")
            }
        }
        print("[Session Manager]Successfully Init Room(json)")
    }
    
    func getAvatar(callback: @escaping(UIImage?, Int) -> Void){
        if let thisUser = user {
            if thisUser.avatarImage == nil {
                if let req = user?.getAvatarRequest() {
                    if ImageDownloader.instance == nil {
                        print("Image down")
                        callback(nil,2)
                        return}
                    ImageDownloader.instance?.download(req, completion: {[self] response in
                        if case .success(let image) = response.result {
                            self.user?.avatarImage = image
                            callback(user?.avatarImage, 0)
                        }else{callback(nil,1)}
                    })
                }
            }else{callback(self.user?.avatarImage, 0)}
        }else{callback(nil,2)}
    }
    
    func updateAvatar(callback: @escaping(UIImage?, Int) -> Void){
        if let req = user?.getAvatarRequest() {
            SessionManager.imageCache.removeImages(matching: req)
        }
        user?.avatarImage = nil
        getAvatar(callback: callback)
    }
}

extension SessionManager {
    static var instance = SessionManager()
}
