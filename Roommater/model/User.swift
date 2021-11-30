//
//  User.swift
//  Roommater
//
//  Created by KAMIKU on 11/26/21.
//

import Foundation
import UIKit
import Alamofire

protocol UserDes : Hashable {
    var nickname: String { get }
    var uid: String { get set}
    var rating : Float {get set}
    var avatar : UIImage? {get set}
}

struct RoommateInfo : UserDes {
    var nickname: String = ""
    var uid: String = ""
    var rating: Float = 0.0
    var avatar: UIImage?
    
    init(data: [String : Any]) {
        if let value = data["uid"] as? String{
            uid = value
        }
        
        if let value = data["nickname"] as? String{
            nickname = value
        }
        
        if let value = data["avatar"] as? String{
            var image : UIImage? = nil
            AF.download(value).response { response in
                if response.error == nil, let imagePath = response.fileURL?.path {
                    image = UIImage(contentsOfFile: imagePath)
                }
            }
            self.avatar = image
        }
        
        if let value = data["rating"] as? Float {
            rating = value
        }
    }
    
    init(nickname : String, uid : String, rating : Float, avatar : UIImage?) {
        self.nickname = nickname
        self.uid = uid
        self.rating = rating
        self.avatar = avatar
    }
}

struct UserInfo : UserDes {
    var nickname: String = ""
    var uid: String = ""
    
    var username : String = ""
    var email : String = ""
    var rating : Float = 0.0
    var avatar : UIImage?
    
    var userDes : RoommateInfo!
    
    init(data: [String : Any]) {
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
            var image : UIImage? = nil
            AF.download(value).response { response in
                if response.error == nil, let imagePath = response.fileURL?.path {
                    image = UIImage(contentsOfFile: imagePath)
                }
            }
            self.avatar = image
        }
        
        if let value = data["rating"] as? Float {
            self.rating = value
        }
        
        self.userDes = RoommateInfo(nickname: self.nickname, uid: self.uid, rating: self.rating, avatar: self.avatar)
    }
}
