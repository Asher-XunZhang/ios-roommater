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

class SessionManager{
    private static let imageCache = AutoPurgingImageCache()
    static let AvatarManager = ImageDownloader(
        configuration: APIAction.getDefaultURLSessionConfig(),
        downloadPrioritization: .fifo,
        maximumActiveDownloads: 4,
        imageCache: imageCache
    )
    var user : UserInfo?
    var dorm : DormInfo?
    
    func initUser(data: [String : Any]){
        user = UserInfo(data: data)
        print("[Session Manager]Successfully Init User")
    }
    
    func initDorm(data: [String : Any]){
        dorm = DormInfo(data: data)
    }
    
    func getAvatar(callback: @escaping(UIImage?, Int) -> Void){
        if let thisUser = user {
            if thisUser.avatarImage == nil {
                if let req = user?.getAvatarRequest() {
                    SessionManager.AvatarManager.download(req, completion: {[self] response in
                        if case .success(let image) = response.result {
                            self.user?.avatarImage = image
                            callback(user?.avatarImage, 0)
                        }else{
                            callback(nil,1)
                        }
                    })
                }
            }else{
                callback(self.user?.avatarImage, 0)
            }
        }else{
            callback(nil,2)
        }
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
