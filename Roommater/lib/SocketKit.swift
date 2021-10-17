//
//  SocketKit.swift
//  Roommater
//
//  Created by KAMIKU on 10/8/21.
//
import Foundation
import SocketIO

class SocketInstance {
    static let socketOrigin = "https://roommater-server.herokuapp.com"
    static var socket : SocketIOClient?
    static let manager = SocketManager(
        socketURL: URL(string: socketOrigin)!,
        config: [
            .log(true),
            .compress,
            .connectParams(["__sails_io_sdk_version":"1.0.2"]),
            .forceWebsockets(true)
        ])
    
    static func setup(){
        socket = manager.defaultSocket
        /*========================
         * Register Socket Event Handler
         ========================*/
        if let client = socket {
            client.on(clientEvent: .connect) {data, ack in
                // Handle connected
                print("socket connected")
            }
            client.on(clientEvent: .disconnect) {data, ack in
                // Handle disconnected
                print("socket disconnected")
            }
            client.on(clientEvent: .error) {data, ack in
                // Handle error
                print("socket error")
            }
            client.on("handshake"){res, ack in print(res)}
        }
    }
    
    static func connect(){
        if let client = socket{
            if client.status != .connected {
                print("connecting...")
                client.connect()
                get(path: "testuser/socket", data: ["platform": "iOS"]){ res in print(res)}
                post(path: "testuser/socket", data: ["platform": "iOS"]){ res in print(res)}
            }
        }else{
            print("Socket is not inited!")
        }
    }
    
    static func disconnect(){
        socket?.disconnect()
    }
    
    static func get(path:String, data:[String:String], callback: @escaping ([Any])-> Void){
        if let client = socket {
            print(["url": "/\(path)"].merging(data, uniquingKeysWith: {(_, curr) in curr}))
            client.emitWithAck("get", ["url": "/\(path)"].merging(data, uniquingKeysWith: {(_, curr) in curr})).timingOut(after: 1) {res in
                print(res)
                callback(res)
            }
        }
    }
    
    static func post(path:String, data:[String:String], callback: @escaping ([Any])-> Void){
        if let client = socket {
            client.emitWithAck("post", ["url": "/\(path)"].merging(data, uniquingKeysWith: {(_, curr) in curr})).timingOut(after: 1) {res in
                print(res)
                callback(res)
            }
        }
    }
}
