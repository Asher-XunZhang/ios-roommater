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
    private static var userData : String {
        let manager = FileManager.default
        let url = manager.urls(for: .documentDirectory, in: .userDomainMask).first! as NSURL
        return url.appendingPathComponent("userdata")!.path
    }
    private static let imageCache = AutoPurgingImageCache()
    static var AvatarManager : ImageDownloader?
    var user : UserInfo?
    var dorm : DormInfo?
    
    init() {
        SwiftEventBus.onBackgroundThread(self, name: "login"){ _ in
            SessionManager.AvatarManager = ImageDownloader(
                configuration: APIAction.getDefaultURLSessionConfig(),
                downloadPrioritization: .fifo,
                maximumActiveDownloads: 4,
                imageCache: SessionManager.imageCache
            )
        }
        
        SwiftEventBus.onBackgroundThread(self, name: "logout"){ _ in
            SessionManager.AvatarManager = nil
        }
    }
    
    func preCheck() -> Bool {
        if FileManager.default.fileExists(atPath: SessionManager.userData){
            do {
                // storage the user data locally
            }catch {
                // logout
            }
        }
        return false
    }
    
    func initUser(data: [String : Any]){
        user = UserInfo(data: data)
        print("[Session Manager]Successfully Init User")
    }
    
    func initDorm(data: [String : Any]){
        dorm = DormInfo(data: data)
        print("[Session Manager]Successfully Init Dorm")
    }
    
    func getAvatar(callback: @escaping(UIImage?, Int) -> Void){
        if let thisUser = user {
            if thisUser.avatarImage == nil {
                if let req = user?.getAvatarRequest() {
                    if SessionManager.AvatarManager == nil {callback(nil,2);return}
                    SessionManager.AvatarManager?.download(req, completion: {[self] response in
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
