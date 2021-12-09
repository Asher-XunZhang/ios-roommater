//
//  APIHandler.swift
//  Roommater
//
//  Created by KAMIKU on 10/12/21.
//

import Foundation
import Alamofire
import AlamofireImage
import StreamChat
import UIKit
import SwiftEventBus

enum Result {
    case Success(AnyObject?)
    case Fail(String)
    case Timeout(String)
    case Error(String)
    case NONE(String)
    
    static func handleCode(_ code: Int, msg: String, Obj: AnyObject?)-> Result {
        switch code{
            case 0...100:
                return .Success(Obj)
            case 101...400:
                return .Fail(msg)
            case 401...600:
                return .Error(msg)
            default:
                return .NONE("Unknown Error")
        }
    }
}

enum Router : URLRequestConvertible {
    var baseURL: URL {
        return URL(string: "https://roommater-server.herokuapp.com/api/v1")!
//        return URL(string: "http://localhost:1337/api/v1")!
    }
    
    // cases
    // user
    case login(username: String, pass: String)
    case loginWithToken(token: String)
    case signup(username: String, pass: String, email: String)
    case recover(email: String)
    case fetchUser(token: String)
    case fetchToken(username: String)
    case updateInfo(update: [String: Any])
    case updateAvatar
    case logout
    
    //dorm
    case bindDorm(code: String)
    case unbindDorm
    case createDorm(roomName: String, max: Int)
    case deleteDorm(roomID: String)
    case fetchDormInfo
    case fetchEvent(roomID: String)
    case fetchBill(roomID: String)
    case fetchAffair(roomID: String)
    case updateDormInfo(update: [String: Any])
    case postBill
    case postAffair(data : [String: Any])
    case updateAffair(update: [String: Any])
    case updateBill(update: [String: Any])
    case deleteBill(bid: String)
    case deleteAffair(aid: String)
    
    var method: HTTPMethod {
        switch self {
        case .login:
            return .post
        case .loginWithToken:
            return .post
        case .signup:
            return .post
        case .recover:
            return .post
        case .fetchUser:
            return .get
        case .fetchToken:
            return .post
        case .fetchDormInfo:
            return .post
        case .logout:
            return .post
        case .updateInfo:
            return .patch
        case .fetchEvent:
            return .get
        case .fetchBill:
            return .get
        case .fetchAffair:
            return .get
        case .updateDormInfo:
            return .patch
        case .postBill:
            return .post
        case .postAffair:
            return .post
        case .updateAffair:
            return .patch
        case .bindDorm:
            return .put
        case .createDorm:
            return .post
        case .deleteDorm:
            return .delete
        case .deleteBill:
            return .delete
        case .deleteAffair:
            return .delete
        case .unbindDorm:
            return .delete
        case .updateAvatar:
            return .patch
        case .updateBill:
            return .patch
        }
    }
    
    var path: String {
        switch self {
        case .login:
            return "/user/login"
        case .loginWithToken:
            return "/user/login"
        case .signup:
            return "/user/signup"
        case .recover:
            return "/user/recover"
        case .fetchUser:
            return "/user/fetch"
        case .fetchToken:
            return "/user/renewToken"
        case .fetchDormInfo:
            return "/room/fetch"
        case .logout:
            return "/user/logout"
        case .updateInfo:
            return "/user/update"
        case .fetchEvent:
            return "/dorm/events"
        case .fetchBill:
            return "/dorm/bills"
        case .fetchAffair:
            return "/dorm/affairs"
        case .updateDormInfo:
            return "/affair/update"
        case .postBill:
            return "/bill/new"
        case .postAffair:
            return "/affair/add"
        case .bindDorm:
            return "/room/bind"
        case .unbindDorm:
            return "/room/unbind"
        case .createDorm:
            return "/room/host"
        case .deleteDorm:
            return "/room/destroy"
        case .updateAffair:
            return "/affair/update"
        case .deleteBill:
            return "/bill/destroy"
        case .deleteAffair:
            return "/affair/destroy"
        case .updateAvatar:
            return "/user/updateAvatar"
        case .updateBill:
            return "/bill/update"
        }
    }

    func asURLRequest() throws -> URLRequest {
        let result: (path: String, parameters: Parameters) = {
            switch self {
            case .login(username: let username, pass: let pass):
                return (path, ["user": username, "pass": pass])
            case .signup(username: let username, pass: let pass, email: let email):
                return (path, ["user": username, "pass": pass, "email": email])
            case .recover(email: let email):
                return (path, ["email": email])
            case .fetchUser(token: let token):
                return (path, ["token": token])
            case .fetchToken(username: let username):
                return (path, ["user": username])
            case .fetchDormInfo:
                return (path, [:])
            case .loginWithToken:
                return (path, [:])
            case .logout:
                return (path, [:])
            case .updateInfo(update: let update):
                return (path, update)
            case .bindDorm(code : let code):
                return (path, ["code": code])
            case .unbindDorm:
                return (path, [:])
            case .createDorm(roomName: let roomName, max: let max):
                return (path, ["room": roomName, "max":max])
            case .deleteDorm(roomID: let roomID):
                return (path, ["room": roomID])
            case .fetchEvent(roomID: let roomID):
                return (path, ["room": roomID])
            case .fetchBill(roomID: let roomID):
                return (path, ["room": roomID])
            case .fetchAffair(roomID: let roomID):
                return (path, ["room": roomID])
            case .updateDormInfo(update: let update):
                return (path, update)
            case .postBill:
                return (path, [:])
            case .postAffair(data: let data):
                return (path, data)
            case .updateAffair:
                return (path, [:])
            case .deleteBill(bid: let bid):
                return (path, ["billID": bid])
            case .deleteAffair(aid: let aid):
                return (path, ["affairID": aid])
            case .updateAvatar:
                return (path, [:])
            case .updateBill(update: let update):
                return (path, [:])
            }
        }()
        
        var req = URLRequest(url: baseURL.appendingPathComponent(result.path))
        req.httpMethod = method.rawValue
        let token = UserDefaults.standard.string(forKey: "token")
        if(token != nil){
            req.setValue(token , forHTTPHeaderField: "Access-Token")
        }
        // TODO: add header and query or params
        return try JSONEncoding.default.encode(req, with: result.parameters)
    }
}

class APIAction {
    
    static func getDefaultURLSessionConfig()-> URLSessionConfiguration {
        let configuration = URLSessionConfiguration.default
        configuration.headers = .default
        if let token = UserDefaults.standard.string(forKey: "token") {
            print("Found Token: \(token)")
            configuration.headers.add(name: "Access-Token", value: token)
        }
        
        configuration.httpShouldSetCookies = true
        configuration.httpShouldUsePipelining = false
        
        configuration.requestCachePolicy = .useProtocolCachePolicy
        configuration.allowsCellularAccess = true
        configuration.timeoutIntervalForRequest = 60
        
        configuration.urlCache = URLCache(
            memoryCapacity: 20 * 1024 * 1024,
            diskCapacity: 150 * 1024 * 1024,
            diskPath: "com.pixmeow.roommater"
        )
        return configuration
    }
    
    //MARK: StreamChat Init
    @discardableResult private static func initChat() -> Bool{
        let config = ChatClientConfig(apiKey: .init("pp5v5t8hksh7"))
        ChatClient.shared = ChatClient(config: config)
        var res = true
        guard let user = SessionManager.instance.user else {return false}
        ChatClient.shared.connectUser(userInfo: .init(id: user.uid, name: user.nickname, imageURL: URL.init(string: user.avatar)), token: .development(userId: user.uid)){err in
            if ChatClient.shared.connectionStatus != .connected {
                print("Failed to connected to the chat service!")
                res = false
            }
        }
        return res
    }
    
    //MARK:  ********************* User API *********************
    static func login(username: String, pass: String, callback: @escaping (Result) -> Void) {
        DispatchQueue.global().async {
            AF.request(Router.login(username: username, pass: pass)).responseJSON { res in
                    switch (res.response?.statusCode) {
                        case 200: if let json = res.value as? [String:Any] {
                            DispatchQueue.main.async {
                                if json["err"] as! Int == 0 , let data = json["res"] as? [String:Any] {
                                    UserDefaults.standard.set(data["token"] as? String, forKey: "token")
                                    SwiftEventBus.post("login")
                                    SessionManager.instance.initUser(data: data)
                                    if initChat() {
                                            callback(
                                                Result.handleCode(
                                                    json["err"] as? Int ?? 600,
                                                    msg: json["msg"] as? String ?? "Error Phase the data",
                                                    Obj: json["res"] as AnyObject?
                                                )
                                            )
                                    }else{ callback(.Fail("Failed to init account!")) }
                                }else { callback(.Error("Failed to init account!")) }
                            }
                        }
                        default: DispatchQueue.main.async {callback(.Fail("Error API request: \(res.response?.statusCode ?? 500)!"))}
                    }
            }
        }
    }
    
    static func loginToken(callback: @escaping (Result) -> Void){
        DispatchQueue.global().async {
            AF.request(Router.loginWithToken(token: UserDefaults.standard.string(forKey: "token") ?? "")).responseJSON { res  in
                    switch (res.response?.statusCode) {
                        case 200: if let json = res.value as? [String:Any] {
                            DispatchQueue.main.async {
                                if json["err"] as! Int == 0 , let data = json["res"] as? [String:Any] {
                                    UserDefaults.standard.set(data["token"] as? String, forKey: "token")
                                    SwiftEventBus.post("login")
                                    SessionManager.instance.initUser(data: data)
                                    if initChat() {
                                        callback(
                                            Result.handleCode(
                                                json["err"] as? Int ?? 600,
                                                msg: json["msg"] as? String ?? "Error Phase the data",
                                                Obj: json["res"] as AnyObject?
                                            )
                                        )
                                    }else{ callback(.Fail("Failed to init account!"))}
                                }else { callback(.Error("Failed to init account!")) }
                            }
                        }
                        default: DispatchQueue.main.async {callback(.Fail("Error API request: \(res.response?.statusCode ?? 500)!"))}
                    }
                }
        }
    }
    
    static func signup(username: String, pass: String, email: String, callback: @escaping (Result) -> Void) {
        DispatchQueue.global().async {
            AF.request(Router.signup(username: username, pass: pass, email: email)).responseJSON { res in
                    switch (res.response?.statusCode) {
                        case 200: if let json = res.value as? [String:Any] {
                            DispatchQueue.main.async {
                                callback(
                                    Result.handleCode(
                                        json["err"] as? Int ?? 600,
                                        msg: json["msg"] as? String ?? "Error Phase the data",
                                        Obj: json["msg"] as AnyObject?
                                    )
                                )
                            }
                        }
                        default: DispatchQueue.main.async {callback(.Fail("Error API request: \(res.response?.statusCode ?? 500)!"))}
                    }
                }
        }
    }
    
    static func forgot(email: String, callback: @escaping (Result) -> Void) {
        DispatchQueue.global().async {
            AF.request(Router.recover(email: email))
                .responseJSON() { res in
                    switch (res.response?.statusCode) {
                        case 200:
                            if let json = res.value as? [String:Any] {
                                DispatchQueue.main.async {
                                    // TODO: Obj should be implemented in next version
                                    callback(
                                        Result.handleCode(
                                            json["err"] as? Int ?? 600,
                                            msg: json["msg"] as? String ?? "Error Phase the data",
                                            Obj: nil
                                        )
                                    )
                                }
                            }
                        default:
                            print("Fail")
                            DispatchQueue.main.async {
                                callback(.Fail("Error API Response code: \(res.response?.statusCode ?? 500)"))
                            }
                    }
                }
        }
    }

    static func fetchUser(token: String, callback: @escaping (Result) -> Void) {
        DispatchQueue.global().async {
            AF.request(Router.fetchUser(token: token))
                .responseJSON() { res in
                    switch (res.response?.statusCode) {
                        case 200:
                            if let json = res.value as? [String:Any] {
                                DispatchQueue.main.async {
                                    
                                    
                                    callback(
                                        Result.handleCode(
                                            json["err"] as? Int ?? 600,
                                            msg: json["msg"] as? String ?? "Error Phase the data",
                                            Obj: nil
                                        )
                                    )
                                }
                            }
                        default: DispatchQueue.main.async {callback(.Fail("Error API request: \(res.response?.statusCode ?? 500)!"))}
                    }
                }
        }
    }
    
    static func updateAvatar(image: UIImage, callback: @escaping (Result) -> Void) {
        DispatchQueue.global().async {
            let request = Router.updateAvatar
            AF.upload(
                multipartFormData: { form in
                form.append(image.jpegData(compressionQuality: 1)!, withName: "avatar", fileName: "new_avatar.jpg", mimeType: "image/jpg")},
                to: request.baseURL.appendingPathComponent(request.path),
                headers: request.urlRequest?.headers)
                .responseJSON() {res in
                    switch (res.response?.statusCode) {
                        case 200:
                            if let json = res.value as? [String:Any] {
                                DispatchQueue.main.async {
                                    callback(Result.handleCode(json["err"] as? Int ?? 600, msg: json["msg"] as? String ?? "Error Phase the data", Obj: json["res"] as AnyObject?))
                                }
                            }
                        default: DispatchQueue.main.async {callback(.Fail("Error API request: \(res.response?.statusCode ?? 500)!"))}
                    }
                }
        }
    }
    
    static func fetchNewtoken(user: String, callback: @escaping (Result) -> Void){
        DispatchQueue.global().async {
            AF.request(Router.fetchToken(username: user))
                .responseJSON() { res in
                    switch (res.response?.statusCode) {
                        case 200:
                            if let json = res.value as? [String:Any] {
                                DispatchQueue.main.async {
                                    callback(Result.handleCode(json["err"] as? Int ?? 600, msg: json["msg"] as? String ?? "Error Phase the data", Obj: json["new-token"] as AnyObject))
                                }
                            }
                        default: DispatchQueue.main.async {callback(.Fail("Error API request: \(res.response?.statusCode ?? 500)!"))}
                    }
                }
        }
    }
    
    static func logout(callback: @escaping (Result) -> Void){
        DispatchQueue.global().async {
            AF.request(Router.logout)
                .responseJSON() { res in
                    switch (res.response?.statusCode) {
                        case 200:
                            SwiftEventBus.post("logout")
                            if let json = res.value as? [String:Any] {
                                if json["err"] as! Int == 0 {
                                    SessionManager.instance.close()
                                    ChatClient.shared.disconnect()
                                }
                                DispatchQueue.main.async {
                                    callback(
                                        Result.handleCode(
                                            json["err"] as? Int ?? 600,
                                            msg: json["msg"] as? String ?? "Error Phase the data",
                                            Obj: json["new-token"] as AnyObject
                                        )
                                    )
                                }
                            }
                        default: DispatchQueue.main.async {callback(.Fail("Error API request: \(res.response?.statusCode ?? 500)!"))}
                    }
                }
        }
    }
    
    static func updateUserInfo(data: [String: Any], callback: @escaping (Result) -> Void){
        DispatchQueue.global().async {
            AF.request(Router.updateInfo(update: data)).responseJSON() { res in
                switch (res.response?.statusCode) {
                    case 200:
                        if let json = res.value as? [String:Any] {
                            DispatchQueue.main.async {
                                callback(
                                    Result.handleCode(
                                        json["err"] as? Int ?? 600,
                                        msg: json["msg"] as? String ?? "Error Phase the data",
                                        Obj: json["res"] as AnyObject
                                    )
                                )
                            }
                        }
                    default: DispatchQueue.main.async {callback(.Fail("Error API request: \(res.response?.statusCode ?? 500)!"))}
                }
            }
        }
        
    }
    
    //MARK:  ********************* Room API *********************
    static func hostDorm(roomName : String, max: Int, callback: @escaping (Result) -> Void){
        DispatchQueue.global().async {
            AF.request(Router.createDorm(roomName: roomName, max: max)).responseJSON() { res in
                    switch (res.response?.statusCode) {
                        case 200:
                            if let json = res.value as? [String:Any] {
                                DispatchQueue.main.async {
                                    callback(
                                        Result.handleCode(
                                            json["err"] as? Int ?? 600,
                                            msg: json["msg"] as? String ?? "Error Phase the data",
                                            Obj: json["res"] as AnyObject
                                        )
                                    )
                                }
                            }
                        default: DispatchQueue.main.async {callback(.Fail("Error API request: \(res.response?.statusCode ?? 500)!"))}
                    }
                }
        }
    }
    
    static func fetchDormInfo(callback: @escaping (Result) -> Void){
        DispatchQueue.global().async {
            AF.request(Router.fetchDormInfo).responseJSON() { res in
                    switch (res.response?.statusCode) {
                        case 200:
                            if let json = res.value as? [String:Any] {
                                DispatchQueue.main.async {
                                    callback(
                                        Result.handleCode(
                                            json["err"] as? Int ?? 600,
                                            msg: json["msg"] as? String ?? "Error Phase the data",
                                            Obj: json["res"] as AnyObject
                                        )
                                    )
                                }
                            }
                        default: DispatchQueue.main.async {callback(.Fail("Error API request: \(res.response?.statusCode ?? 500)!"))}
                    }
                }
        }
    }
    
    static func joinDrom(code: String, callback: @escaping (Result) -> Void){
        DispatchQueue.global().async {
            AF.request(Router.bindDorm(code: code))
                .responseJSON() { res in
                    switch (res.response?.statusCode) {
                        case 200:
                            if let json = res.value as? [String:Any] {
                                DispatchQueue.main.async {
                                    callback(
                                        Result.handleCode(
                                            json["err"] as? Int ?? 600,
                                            msg: json["msg"] as? String ?? "Error Phase the data",
                                            Obj: json["res"] as AnyObject
                                        )
                                    )
                                }
                            }
                        default: DispatchQueue.main.async {callback(.Fail("Error API request: \(res.response?.statusCode ?? 500)!"))}
                    }
                }
        }
    }
    
    static func postBill(data: [String: Any], callback: @escaping (Result) -> Void){}
    
    static func udpateBill(bid: String, updates: [String: Any], callback: @escaping (Result) -> Void){}
    
    static func deleteBill(bid: String, callback: @escaping (Result) -> Void){}
    
    static func postAffiar(data: [String: Any], callback: @escaping (Result) -> Void){}
    
    static func updateAffiar(aid: String, updates: [String: Any], callback: @escaping (Result) -> Void){}
    
    static func deleteAffiar(aid: String, callback: @escaping (Result) -> Void){
        DispatchQueue.global().async {
            AF.request(Router.deleteAffair(aid: aid)).responseJSON { res in
                switch (res.response?.statusCode) {
                    case 200: if let json = res.value as? [String:Any] {
                        DispatchQueue.main.async {
                            if json["err"] as! Int == 0 , let data = json["res"] as? [String:Any] {
                                SessionManager.instance.initUser(data: data)
                                UserDefaults.standard.set(data["token"] as? String, forKey: "token")
                                if initChat() {
                                    callback(
                                        Result.handleCode(
                                            json["err"] as? Int ?? 600,
                                            msg: json["msg"] as? String ?? "Error Phase the data",
                                            Obj: json["res"] as AnyObject?
                                        )
                                    )
                                }else{ callback(.Fail("Failed to init account!"))}
                            }else { callback(.Error("Failed to init account!")) }
                        }
                    }
                    default: DispatchQueue.main.async {callback(.Fail("Error API request: \(res.response?.statusCode ?? 500)!"))}
                }
            }
        }
    }
}
