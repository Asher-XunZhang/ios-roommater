//
//  SocketKit.swift
//  Roommater
//
//  Created by KAMIKU on 10/8/21.
//
import Foundation
import SocketIO

struct SocketInstance {
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
        print(manager.socketURL)
        
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
            
            client.on("currentAmount") {data, ack in
                guard let cur = data[0] as? Double else { return }
                client.emitWithAck("canUpdate", cur).timingOut(after: 0) {data in
                    if (data.first as? String ?? "passed") == SocketAckStatus.noAck.rawValue {
                        // Handle ack timeout
                    }
                    client.emit("update", ["amount": cur + 2.50])
                }
                ack.with("Got your currentAmount", "dude")
            }
        }
    }
    
    static func connect(){
        if socket?.status == .connected {
            socket?.connect()
        }
    }
    
    static func disconnect(){
        socket?.disconnect()
    }
    
    static func auth(identity:String, passEncrypted :String) -> Bool {
        if let client = socket {
            client.emitWithAck("login", 0).timingOut(after: 1) {data in
                
            }
        }
        return false
    }
}
