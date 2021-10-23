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
import SwiftJWT

class MapJWT : Mappable, Claims {
    required init?(map: Map) {}
    
    func mapping(map: Map) {}
}

struct Response<T: Mappable>: Mappable {
    var error : Int?
    var msg : T?
    var data : MapJWT?
    var token : MapJWT?
    init?(map: Map) {}

    mutating func mapping(map: Map) {
        //print the map
        print(map)
        
        error <- map["error"]
        msg <- map["error"]
        data <- map["result"]
    }
}

func verify(sign: String, token: String) throws {
    if let _sign = Data(base64Encoded: sign){
        let jwtVerifier = JWTVerifier.hs256(key: _sign)
        if JWT<MapJWT>.verify(token, using: jwtVerifier) {
            let newJWT = try JWT<MapJWT>(jwtString: token, verifier: jwtVerifier)
            print(newJWT)
        }else{
            print("Verify Failed!")
        }
    }
}

enum Result {
    case Success(AnyObject?)
    case Fail(String)
    case Timeout(String)
    case Error(String)
    case NONE
}

enum AuthRoute: URLRequestConvertible {
    static let consumerKey = "secret api key" //todo get form socket io
    var baseURL: URL {
        return URL(string: "https://roommater-server.herokuapp.com/api/v1")!
    }
    case login(username: String, pass: String)
    case signup(username: String, pass: String, email: String)
    case recover(email: String)
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
        return try JSONEncoding.default.encode(req, with: result.parameters)
    }
}

func login(username: String, pass: String, callback: @escaping (Result, Error?) -> Void) {
    DispatchQueue.global().async {
        Alamofire.request(AuthRoute.login(username: username, pass: pass))
                .responseObject { (res: DataResponse<User>) in
                    switch (res.response?.statusCode) {
                        case 200:
                            if let result = response.result.value as? [String:Any] {
                                print(result["err"])
                                print(result["msg"])
                            }
                            // if let user = res.result.value {
                            //     print(user.toJSONString() ?? "None")
                            //     DispatchQueue.main.async {
                            //     callback(.Success(user), nil)
                            // }
                        default:
                            DispatchQueue.main.async {
                                callback(.Fail("Error API Response code: \(res.response?.statusCode ?? 600)"), nil)
                            }
                            return
                        }
                    }
//        Alamofire.request(AuthRoute.login(username: username, pass: pass))
//        .responseJSON() { res in
//            print(type(of: res.value))
//            if let status = res.response?.statusCode {
//                switch(status){
//                case 200:
//                    print("200")
//                default:
//                    DispatchQueue.main.async {
//                        callback(.Fail("Error API Response code: \(status)"), nil)
//                    }
//                    return
//                }
//            }
//
//            if let raw = res.value{
//                print(type(of: raw))
//                print(raw)
//            }
//
//            switch res.result {
//            case .success(let value):
//                print(value)
//            case .failure(let error):
//                print(error.localizedDescription)
//            }
//
//            if let _raw = res.value as? Dictionary<String, AnyObject> {
//                DispatchQueue.main.async {
//                    print(_raw)
//                    callback(.Success(Response(json: _raw)), nil)
//                }
//            }else{
//                DispatchQueue.main.async {
//                    callback(.Error("Fail to phrase data"), nil)
//                }
//            }
//        }
//                }
                }
    }
}

    func signup(username: String, pass: String, email: String, callback: @escaping (Result, Error?) -> Void) {
        DispatchQueue.global().async {
            Alamofire.request(AuthRoute.signup(username: username, pass: pass, email: email))
                    .responseJSON() { res in
                        if let status = res.response?.statusCode {
                            switch (status) {
                            case 200:
                                print("")
                            default:
                                DispatchQueue.main.async {
                                    callback(.Fail("Error API Response code: \(status)"), nil)
                                }
                                return
                            }
                        }
                        switch res.result {
                        case .success(let raw):
                            if raw is Dictionary<String, AnyObject> {
                                DispatchQueue.main.async {

                                }
                            }
                        case .failure(_):
                            DispatchQueue.main.async {
                                callback(.Error("Fail to phrase data"), nil)
                            }
                        }
                    }
        }
    }

    func forgot(email: String, callback: @escaping (Result, Error?) -> Void) {
        DispatchQueue.global().async {
            Alamofire.request(AuthRoute.recover(email: email))
                    .responseJSON() { res in
                        if let status = res.response?.statusCode {
                            switch (status) {
                            case 200:
                                switch res.result {
                                    case .success(let raw):
                                        if raw is Dictionary<String, AnyObject> {
                                            DispatchQueue.main.async {

                                            }
                                        }
                                    case .failure(_):
                                        DispatchQueue.main.async {
                                            callback(.Error("Fail to phrase data"), nil)
                                        }
                                    }
                            default:
                                DispatchQueue.main.async {
                                    callback(.Fail("Error API Response code: \(status)"), nil)
                                }
                                return
                            }
                        }
                    }
        }
    }
