//
//  APIHandler.swift
//  Roommater
//
//  Created by KAMIKU on 10/12/21.
//

import Foundation
import AlamofireObjectMapper
import Alamofire
import ObjectMapper
import StreamChat

enum Result {
    case Success(AnyObject?)
    case Fail(String)
    case Timeout(String)
    case Error(String)
    case NONE
    
    static func handleCode(_ code: Int, msg: String, Obj: AnyObject?)-> Result {
        switch code{
            case 0...100:
                return .Success(Obj)
            case 101...400:
                return .Fail(msg)
            case 401...600:
                return .Error(msg)
            default:
                return .NONE
        }
    }
}

enum AuthRoute: URLRequestConvertible {
    var baseURL: URL {
//        return URL(string: "https://roommater-server.herokuapp.com/api/v1")!
        return URL(string: "http://localhost:1337/api/v1")!
    }
    
    // case
    case login(username: String, pass: String)
    case loginWithToken(token: String)
    case signup(username: String, pass: String, email: String)
    case recover(email: String)
    case fetchUser(token: String)
    case fetchToken(username: String)
    case fetchDormInfo(roomID: String)
    case logout
    
    var method: HTTPMethod {
        switch self {
        case .login:
            return .post
        case .loginWithToken:
            return .post
        case .signup:
            return .put
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
            case .fetchDormInfo(roomID: let roomID):
                return (path, ["room": roomID])
            case .loginWithToken:
                return (path, [:])
            case .logout:
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
    //login request with post
    @discardableResult private static func initChat(id: String, nickname: String) -> Bool{
        let config = ChatClientConfig(apiKey: .init("pp5v5t8hksh7"))
        ChatClient.shared = ChatClient(config: config)
        var res = true
        ChatClient.shared.connectUser(userInfo: .init(id: id, name: nickname), token: .development(userId: id), completion: {err in
            if ChatClient.shared.connectionStatus != .connected {
                print("Failed to connected to the chat service!")
                res = false
            }
        })
        return res
    }
    
    static func login(username: String, pass: String, callback: @escaping (Result) -> Void) {
        DispatchQueue.global().async {
            AF.request(AuthRoute.login(username: username, pass: pass))
                .responseJSON { res in
                    switch (res.response?.statusCode) {
                        case 200:
                            if let json = res.value as? [String:Any] {
                                DispatchQueue.main.async {
                                    // TODO: Obj should be implemented in next version
                                    
                                    if json["err"] as! Int == 0{
                                        UserDefaults.standard.set((json["res"] as? [String:Any])?["token"] as? String, forKey: "token")
                                        if let _id = (json["res"] as? [String:Any])?["uid"] as? String, let _name = (json["res"] as? [String:Any])?["nickname"] as? String{
                                            if initChat(id: _id, nickname: _name) {
                                                callback(Result.handleCode(json["err"] as? Int ?? 600, msg: json["msg"] as? String ?? "Error Phase the data", Obj: json["res"] as AnyObject?))
                                            }else{
                                                callback(.Error("Failed to init chat account!"))
                                            }
                                        }else{
                                            callback(.Error("Failed to init account!"))
                                        }
                                    }else{
                                        callback(Result.handleCode(json["err"] as? Int ?? 600, msg: json["msg"] as? String ?? "Error Phase the data", Obj: json["res"] as AnyObject?))
                                    }
                                }
                            }
                        default:
                            DispatchQueue.main.async {
                                callback(.Fail("Error API Response code: \(res.response?.statusCode ?? 500)"))
                            }
                    }
                }
        }
    }
    
    static func login(token: String, callback: @escaping (Result) -> Void){
        DispatchQueue.global().async {
            AF.request(AuthRoute.loginWithToken(token: token))
                .responseJSON { res  in
                    switch (res.response?.statusCode) {
                        case 200:
                            if let json = res.value as? [String:Any] {
                                DispatchQueue.main.async {
                                    // TODO: Obj should be implemented in next version
                                    if let _id = (json["res"] as? [String:Any])?["uid"] as? String, let _name = (json["res"] as? [String:Any])?["nickname"] as? String{
                                        if initChat(id: _id, nickname: _name) {
                                            callback(Result.handleCode(json["err"] as? Int ?? 600, msg: json["msg"] as? String ?? "Error Phase the data", Obj: json["res"] as AnyObject?))
                                        }else{
                                            callback(.Error("Failed to init chat account!"))
                                        }
                                    }else{
                                        callback(.Error("Failed to init account!"))
                                    }
                                }
                            }
                        default:
                            DispatchQueue.main.async {
                                callback(.Fail("Error API Response code: \(res.response?.statusCode ?? 500)"))
                            }
                    }
                }
        }
    }
    
    //signuo request with put
    static func signup(username: String, pass: String, email: String, callback: @escaping (Result) -> Void) {
        DispatchQueue.global().async {
            AF.request(AuthRoute.signup(username: username, pass: pass, email: email))
                .responseJSON { res in
                    switch (res.response?.statusCode) {
                        case 200:
                            if let json = res.value as? [String:Any] {
                                DispatchQueue.main.async {
                                    // TODO: Obj should be implemented in next version
                                    callback(Result.handleCode(json["err"] as? Int ?? 600, msg: json["msg"] as? String ?? "Error Phase the data", Obj: json["msg"] as AnyObject?))
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
    
    //forgot request with post
    static func forgot(email: String, callback: @escaping (Result) -> Void) {
        DispatchQueue.global().async {
            AF.request(AuthRoute.recover(email: email))
                .responseJSON() { res in
                    switch (res.response?.statusCode) {
                        case 200:
                            if let json = res.value as? [String:Any] {
                                DispatchQueue.main.async {
                                    // TODO: Obj should be implemented in next version
                                    callback(Result.handleCode(json["err"] as? Int ?? 600, msg: json["msg"] as? String ?? "Error Phase the data", Obj: nil))
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

    //fetch testuser with get
    static func fetchUser(token: String, callback: @escaping (Result) -> Void) {
        DispatchQueue.global().async {
            AF.request(AuthRoute.fetchUser(token: token))
                .responseJSON() { res in
                    switch (res.response?.statusCode) {
                        case 200:
                            if let json = res.value as? [String:Any] {
                                DispatchQueue.main.async {
                                    callback(Result.handleCode(json["err"] as? Int ?? 600, msg: json["msg"] as? String ?? "Error Phase the data", Obj: nil))
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
    
    //fetch token with post
    static func fetchNewtoken(user: String, callback: @escaping (Result) -> Void){
        DispatchQueue.global().async {
            AF.request(AuthRoute.fetchToken(username: user))
                .responseJSON() { res in
                    switch (res.response?.statusCode) {
                        case 200:
                            if let json = res.value as? [String:Any] {
                                DispatchQueue.main.async {
                                    callback(Result.handleCode(json["err"] as? Int ?? 600, msg: json["msg"] as? String ?? "Error Phase the data", Obj: json["new-token"] as AnyObject))
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
    
    //fetch dorm info
    static func fetchDormInfo(callback: @escaping (Result) -> Void){
        if let roomID = UserDefaults.standard.string(forKey: "room_id"){
            DispatchQueue.global().async {
                AF.request(AuthRoute.fetchDormInfo(roomID: roomID))
                    .responseJSON() { res in
                        switch (res.response?.statusCode) {
                            case 200:
                                if let json = res.value as? [String:Any] {
                                    DispatchQueue.main.async {
                                        callback(Result.handleCode(json["err"] as? Int ?? 600, msg: json["msg"] as? String ?? "Error Phase the data", Obj: json["new-token"] as AnyObject))
                                    }
                                }
                            default:
                                DispatchQueue.main.async {
                                    callback(.Fail("Error API Response code: \(res.response?.statusCode ?? 500)"))
                                }
                        }
                    }
            }
        }
        
        
    }
    
    //log out
    static func logout(callback: @escaping (Result) -> Void){
        DispatchQueue.global().async {
            AF.request(AuthRoute.logout)
                .responseJSON() { res in
                    switch (res.response?.statusCode) {
                        case 200:
                            if let json = res.value as? [String:Any] {
                                if json["err"] as! Int == 0 {
                                    UserDefaults.standard.removeObject(forKey: "token")
                                    ChatClient.shared.disconnect()
                                }
                                DispatchQueue.main.async {
                                    callback(Result.handleCode(json["err"] as? Int ?? 600, msg: json["msg"] as? String ?? "Error Phase the data", Obj: json["new-token"] as AnyObject))
                                }
                            }
                        default:
                            DispatchQueue.main.async {
                                callback(.Fail("Error API Response code: \(res.response?.statusCode ?? 500)"))
                            }
                    }
                }
        }
    }
}
