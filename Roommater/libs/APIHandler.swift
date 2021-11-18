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
            case .loginWithToken(token: let token):
                return (path + "?token=\(token)", [:])
            }
        }()
        var req = URLRequest(url: baseURL.appendingPathComponent(result.path))
        req.httpMethod = method.rawValue
        // TODO: add header and query or params
        return try JSONEncoding.default.encode(req, with: result.parameters)
    }
}

class APIAction {
    //login request with post
    static func login(username: String, pass: String, callback: @escaping (Result, Error?) -> Void) {
        DispatchQueue.global().async {
            AF.request(AuthRoute.login(username: username, pass: pass))
                .responseJSON { res in
                    switch (res.response?.statusCode) {
                        case 200:
                            if let json = res.value as? [String:Any] {
                                DispatchQueue.main.async {
                                    // TODO: Obj should be implemented in next version
                                    callback(Result.handleCode(json["err"] as? Int ?? 600, msg: json["msg"] as? String ?? "Error Phase the data", Obj: json["msg"] as AnyObject?), nil)
                                }
                            }
                        default:
                            print("Fail")
                            DispatchQueue.main.async {
                                callback(.Fail("Error API Response code: \(res.response?.statusCode ?? 500)"), nil)
                            }
                    }
                }
        }
    }
    
    static func login(token: String, callback: @escaping (Result, Error?) -> Void){
        DispatchQueue.global().async {
            AF.request(AuthRoute.loginWithToken(token: token))
                .responseJSON { res  in
                    switch (res.response?.statusCode) {
                        case 200:
                            if let json = res.value as? [String:Any] {
                                DispatchQueue.main.async {
                                    // TODO: Obj should be implemented in next version
                                    callback(Result.handleCode(json["err"] as? Int ?? 600, msg: json["msg"] as? String ?? "Error Phase the data", Obj: json["msg"] as AnyObject?), nil)
                                }
                            }
                        default:
                            print("Fail")
                            DispatchQueue.main.async {
                                callback(.Fail("Error API Response code: \(res.response?.statusCode ?? 500)"), nil)
                            }
                    }
                }
        }
    }
    
    //signuo request with put
    static func signup(username: String, pass: String, email: String, callback: @escaping (Result, Error?) -> Void) {
        DispatchQueue.global().async {
            AF.request(AuthRoute.signup(username: username, pass: pass, email: email))
                .responseJSON { res in
                    switch (res.response?.statusCode) {
                        case 200:
                            if let json = res.value as? [String:Any] {
                                DispatchQueue.main.async {
                                    // TODO: Obj should be implemented in next version
                                    callback(Result.handleCode(json["err"] as? Int ?? 600, msg: json["msg"] as? String ?? "Error Phase the data", Obj: json["msg"] as AnyObject?), nil)
                                }
                            }
                        default:
                            print("Fail")
                            DispatchQueue.main.async {
                                callback(.Fail("Error API Response code: \(res.response?.statusCode ?? 500)"), nil)
                            }
                    }
                }
        }
    }
    
    //forgot request with post
    static func forgot(email: String, callback: @escaping (Result, Error?) -> Void) {
        DispatchQueue.global().async {
            AF.request(AuthRoute.recover(email: email))
                .responseJSON() { res in
                    switch (res.response?.statusCode) {
                        case 200:
                            if let json = res.value as? [String:Any] {
                                DispatchQueue.main.async {
                                    // TODO: Obj should be implemented in next version
                                    callback(Result.handleCode(json["err"] as? Int ?? 600, msg: json["msg"] as? String ?? "Error Phase the data", Obj: nil), nil)
                                }
                            }
                        default:
                            print("Fail")
                            DispatchQueue.main.async {
                                callback(.Fail("Error API Response code: \(res.response?.statusCode ?? 500)"), nil)
                            }
                    }
                }
        }
    }

    //fetch testuser with get
    static func fetchUser(token: String, callback: @escaping (Result, Error?) -> Void) {
        DispatchQueue.global().async {
            AF.request(AuthRoute.fetchUser(token: token))
                .responseJSON() { res in
                    switch (res.response?.statusCode) {
                        case 200:
                            if let json = res.value as? [String:Any] {
                                DispatchQueue.main.async {
                                    callback(Result.handleCode(json["err"] as? Int ?? 600, msg: json["msg"] as? String ?? "Error Phase the data", Obj: nil), nil)
                                }
                            }
                        default:
                            print("Fail")
                            DispatchQueue.main.async {
                                callback(.Fail("Error API Response code: \(res.response?.statusCode ?? 500)"), nil)
                            }
                    }
                }
        }
    }
    
    //fetch token with post
    static func fetchNewtoken(user: String, callback: @escaping (Result, Error?) -> Void){
        DispatchQueue.global().async {
            AF.request(AuthRoute.fetchToken(username: user))
                .responseJSON() { res in
                    switch (res.response?.statusCode) {
                        case 200:
                            if let json = res.value as? [String:Any] {
                                DispatchQueue.main.async {
                                    callback(Result.handleCode(json["err"] as? Int ?? 600, msg: json["msg"] as? String ?? "Error Phase the data", Obj: json["new-token"] as AnyObject), nil)
                                }
                            }
                        default:
                            print("Fail")
                            DispatchQueue.main.async {
                                callback(.Fail("Error API Response code: \(res.response?.statusCode ?? 500)"), nil)
                            }
                    }
                }
        }
    }
    
    //fetch dorm info
    static func fetchDormInfo(callback: @escaping (Result, Error?) -> Void){
        if let roomID = UserDefaults.standard.string(forKey: "room_id"){
            DispatchQueue.global().async {
                AF.request(AuthRoute.fetchDormInfo(roomID: roomID))
                    .responseJSON() { res in
                        switch (res.response?.statusCode) {
                            case 200:
                                if let json = res.value as? [String:Any] {
                                    DispatchQueue.main.async {
                                        callback(Result.handleCode(json["err"] as? Int ?? 600, msg: json["msg"] as? String ?? "Error Phase the data", Obj: json["new-token"] as AnyObject), nil)
                                    }
                                }
                            default:
                                print("Fail")
                                DispatchQueue.main.async {
                                    callback(.Fail("Error API Response code: \(res.response?.statusCode ?? 500)"), nil)
                                }
                        }
                    }
            }
        }
        
        
    }
}
