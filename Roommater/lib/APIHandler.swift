//
//  APIHandler.swift
//  Roommater
//
//  Created by KAMIKU on 10/12/21.
//

import Foundation
import Alamofire

let API_Root = "https://roommater-server.herokuapp.com/api/v1"

func login(username: String, pass:String){
    AF.request(
        "\(API_Root)/user/login",
        method: .post,
        parameters: [
            "user": username,
            "pass": pass
        ],
        encoder: JSONParameterEncoder.default)
        .responseJSON() {
        res in print(res)
    }
}

func signup(username: String, pass:String, email : String){
    AF.request(
        "\(API_Root)/user/register",
        method: .post,
        parameters: [
            "user": username,
            "pass": pass,
            "email" : email
        ],
        encoder: JSONParameterEncoder.default)
        .responseJSON() {
        res in print(res)
    }
}

func forgot(email:String){
    AF.request(
        "\(API_Root)/user/recover",
        method: .post,
        parameters: [
            "email" : email
        ],
        encoder: JSONParameterEncoder.default)
        .responseJSON() {
        res in print(res)
    }
}


