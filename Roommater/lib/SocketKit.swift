//
//  SocketKit.swift
//  Roommater
//
//  Created by KAMIKU on 10/8/21.
//

import Foundation
import SocketIO

struct SocketInstance {
    static let socketOrigin = "http://localhost:1337"
    
    static let manager = SocketManager(
        socketURL: URL(string: socketOrigin)!,
        config: [
            .log(true),
            .compress,
            .connectParams(["__sails_io_sdk_version":"1.0.2"]),
            .forceWebsockets(true)
        ])
    
    static func setup(){
        let socket = manager.defaultSocket
        print(manager.socketURL)
        
        /*========================
         * Register Socket Event Handler
         ========================*/
        socket.on(clientEvent: .connect) {data, ack in
            // Handle connected
            print("socket connected")
        }
        
        socket.on(clientEvent: .disconnect) {data, ack in
            // Handle disconnected
            print("socket disconnected")
        }
        
        socket.on(clientEvent: .error) {data,ack in
            // Handle error
            print("socket error")
        }
        
        socket.on("currentAmount") {data, ack in
            guard let cur = data[0] as? Double else { return }
            
            socket.emitWithAck("canUpdate", cur).timingOut(after: 0) {data in
                if (data.first as? String ?? "passed") == SocketAckStatus.noAck.rawValue {
                    // Handle ack timeout
                }
                socket.emit("update", ["amount": cur + 2.50])
            }

            ack.with("Got your currentAmount", "dude")
        }
        
        /*========================
         * Register Socket Instance
         ========================*/
        socket.connect()
    }
}


