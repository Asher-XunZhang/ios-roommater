//
//  SessionManager.swift
//  Roommater
//
//  Created by KAMIKU on 11/26/21.
//

import Foundation
import UIKit
import Alamofire

class SessionManager{
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
                if let token = UserDefaults.standard.string(forKey: "token"), let avatar = user?.avatar, avatar != ""{
                    AF.request(avatar, headers: ["Access-Token": token]).responseImage {[self] response in
                        if case .success(let image) = response.result {
                            user?.avatarImage = image
                            callback(user?.avatarImage, 0)
                        }else{
                            callback(nil,1)
                        }
                    }
                }
            }
        }else{
            callback(nil,2)
        }
    }
    
    func updateAvatar(callback: @escaping(UIImage?, Int) -> Void){
        user?.avatarImage = nil
        getAvatar(callback: callback)
    }
}

extension SessionManager {
    static var instance = SessionManager()
}
