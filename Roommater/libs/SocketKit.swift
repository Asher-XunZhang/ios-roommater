//
//  SocketKit.swift
//  Roommater
//
//  Created by KAMIKU on 10/8/21.
//
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
        ==========================*/
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
    
    static func disconnect(){
        socket?.disconnect()
    }
    
    static func get(path:String, data:[String:String], callback: @escaping ([Any])-> Void){
        if let client = socket, client.status == .connected {
            let arg = ["method": "get", "params": [], "header": [], "url": "/api/v1/testuser/\(path)", "data": data] as [String : Any]
            print(arg)
            client.emitWithAck("get", arg).timingOut(after: 10) {res in
                callback(res)
            }
        }
    }
    
    static func post(path:String, data:[String: Any], callback: @escaping ([Any])-> Void){
        if let client = socket, client.status == .connected {
            let arg = ["method": "post", "params": [], "header": [], "url": "/api/v1/testuser/\(path)", "data": data] as [String : Any]
            print(arg)
            client.emitWithAck("post", arg).timingOut(after: 10) {res in
                callback(res)
            }
        }
    }
    
    static func put(path:String, data:[String: Any], callback: @escaping ([Any])-> Void){
        if let client = socket, client.status == .connected {
            let arg = ["method": "put", "params": [], "header": [], "url": "/api/v1/testuser/\(path)", "data": data] as [String : Any]
            print(arg)
            client.emitWithAck("put", arg).timingOut(after: 10) {res in
                callback(res)
            }
        }
    }
    
    static func delete(path:String, data:[String: Any], callback: @escaping ([Any])-> Void){
        if let client = socket, client.status == .connected {
            let arg = ["method": "delete", "params": [], "header": [], "url": "/api/v1/testuser/\(path)", "data": data] as [String : Any]
            client.emitWithAck("delete", arg).timingOut(after: 10) {res in
                callback(res)
            }
        }
    }
    
    static func patch(path:String, data:[String: Any], callback: @escaping ([Any])-> Void){
        if let client = socket, client.status == .connected {
            let arg = ["method": "patch", "params": [], "header": [], "url": "/api/v1/testuser/\(path)", "data": data] as [String : Any]
            client.emitWithAck("patch", arg).timingOut(after: 10) { res in
                callback(res)
            }
        }
    }
}
