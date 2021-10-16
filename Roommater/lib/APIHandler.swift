//
//  APIHandler.swift
//  Roommater
//
//  Created by KAMIKU on 10/12/21.
//

import Foundation
import Alamofire

enum AuthRoute : URLRequestConvertible {
    static let consumerKey = "secret api key" //todo get form socket io
    
    var baseURL: URL {
        return URL(string: "https://roommater-server.herokuapp.com/api/v1")!
    }
    
    case login(username: String, pass:String)
    case signup(username: String, pass:String, email : String)
    case recover(email:String)
    
    var method: HTTPMethod {
        switch self {
        case .login:
            return .post
        case .signup:
            return .put
        case .recover:
            return .post
        }
    }
    
    var path: String {
        switch self {
        case .login:
            return "/testuser/login"
        case .signup:
            return "/testuser/signup"
        case .recover:
            return "/testuser/recover"
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
            }
        }()
        var req = URLRequest(url: baseURL.appendingPathComponent(result.path))
        req.httpMethod = method.rawValue
        // TODO: add header and query or params
        print(req)
        return try JSONEncoding.default.encode(req, with: result.parameters)
    }
}

func login(username: String, pass:String) -> AFDataResponse<Any>? {
    
    AF.request(AuthRoute.login(username: username, pass: pass))
    .responseJSON() { res in
        if let status = res.response?.statusCode {
            switch(status){
            case 201:
                print("example success")
            default:
                print("error with response status: \(status)")
            }
        }
        
        if let result = res.data {
        
            
        }
        
        print(res)
    }
    return nil
}

func signup(username: String, pass:String, email : String) -> AFDataResponse<Any>? {
    AF.request(AuthRoute.signup(username: username, pass: pass, email: email))
    .responseJSON() {
        res in print(res)
    }
    return nil
}

func forgot(email:String) -> AFDataResponse<Any>?{
    AF.request(AuthRoute.recover(email: email))
    .responseJSON() {
        res in print(res)
    }
    return nil
}
