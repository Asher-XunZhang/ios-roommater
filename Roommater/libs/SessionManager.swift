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
    fileprivate enum ObjectPath {
        case user
        case rooom
        
        fileprivate static var data = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first! as NSURL
        
        var path : URL {
            switch self {
                case .user:
                    return SessionManager.ObjectPath.data.appendingPathComponent("userdata")!
                case .rooom:
                    return SessionManager.ObjectPath.data.appendingPathComponent("roomdata")!
            }
        }
    }
    fileprivate static let imageCache = AutoPurgingImageCache()
    var user : UserInfo?
    var dorm : DormInfo?
    
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
    
    func preCheck() -> Bool {
        if UserDefaults.standard.string(forKey: "token") != nil, FileManager.default.fileExists(atPath: ObjectPath.user.path.path){
            if let value = NSKeyedUnarchiver.unarchiveObject(withFile: ObjectPath.user.path.path) as? UserInfo {
                ImageDownloader.instance = ImageDownloader(
                    configuration: APIAction.getDefaultURLSessionConfig(),
                    downloadPrioritization: .fifo,
                    maximumActiveDownloads: 4,
                    imageCache: SessionManager.imageCache
                )
                self.user = value
                return true
            }
        }
        return false
    }
    
    func initUser(data: [String : Any]){
        user = UserInfo(data: data)
        print("[Session Manager]Successfully Init User")
        if user != nil {
            do{
                let user_encoded = try NSKeyedArchiver.archivedData(withRootObject: user!, requiringSecureCoding: false)
                try user_encoded.write(to: ObjectPath.user.path)
                DormInfo.users[user!.uid] = user
            }catch (let e){
                print(e)
                print("Save User failed Failed")
            }
        }
    }
    
    func initDorm(data: [String : Any]){
        dorm = DormInfo(data: data)
        print("[Session Manager]Successfully Init Dorm")
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


