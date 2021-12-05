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
}

extension SessionManager {
    static var instance = SessionManager()
}
