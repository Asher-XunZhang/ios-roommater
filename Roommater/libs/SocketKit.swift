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
            .log(false),
            .compress,
            .connectParams(["__sails_io_sdk_version":"1.2.1"]),
            .forceWebsockets(true)
        ])
    
    static func setup(){
        socket = manager.defaultSocket
        /*========================
         * Register Socket Event Handler
         ========================*/
        if let client = socket {
            // Baisc events
            client.on(clientEvent: .connect) {data, ack in
                // Handle connected
                print("[Socket Instance] Connected | session id:\(client.sid)")
            }
            client.on(clientEvent: .disconnect) {data, ack in
                // Handle disconnected
                print("[Socket Instance] Disconnected")
            }
            client.on(clientEvent: .error) {data, ack in
                // Handle error
                print("[Socket Instance] Connect Error")
            }
            client.on(clientEvent: .reconnect) {data, ack in
                // Handle error
                print("[Socket Instance] Reconnecting...")
            }
            client.on("handshake"){res, ack in print(res)}
            client.on("testuser"){ res, ack in
                print("[Socket Instance](Test User): \(res) | \(ack)")
            }
        }
    }
    
    static func connect(){
        if let client = socket{
            if client.status != .connected {
                client.connect()
                print("connecting...")
            }
        }else{
            print("Socket is not inited!")
        }
    }
    
    static func test(){
        if let client = socket, client.status == .connected {
            client.emit("start", ["Name":"Kamiku"])
        }
    }
    
    static func disconnect(){
        socket?.disconnect()
    }
    
    static func GET(path:String, data:[String:String], callback: @escaping ([Any])-> Void){
        if let client = socket, client.status == .connected {
            let arg = ["method": "get", "params": [], "header": [], "url": "/api/v1/testuser/\(path)", "data": data] as [String : Any]
            print(arg)
            client.emitWithAck("get", arg).timingOut(after: 10) {res in
                print(res)
//                callback(res)
            }
        }
    }
    
    static func POST(path:String, data:[String:String], callback: @escaping ([Any])-> Void){
        if let client = socket, client.status == .connected {
            client.emitWithAck("post", ["url": "/\(path)"].merging(data, uniquingKeysWith: {(_, curr) in curr})).timingOut(after: 10) {res in
                print(res)
//                callback(res)
            }
        }
    }
}
