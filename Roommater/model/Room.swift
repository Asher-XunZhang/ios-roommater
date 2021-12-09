//
//  Room.swift
//  Roommater
//
//  Created by KAMIKU on 11/26/21.
//

import Foundation

struct DormInfo{
    static var users : [String : RoommateInfo] = [:]
    var roomID : String = ""
    var inviteCode : String = ""
    var roomName : String = ""
    var maxMemeber : Int = 1
    var owner : RoommateInfo!
    var residents : [RoommateInfo] = []
    var announcements : [Event] = []
    var bills : [Bill] = []
    var roomChatId : String?
    var affair : [Affair] = []
    
    init(data : [String:Any]) {
        if let value = data["roomID"] as? String{
            roomID = value
        }
        
        if let value = data["inviteCode"] as? String{
            inviteCode = value
        }
        
        if let value = data["roomName"] as? String{
            roomName = value
        }
        
        if let value = data["maxRsidents"] as? Int{
            maxMemeber = value
        }
        
        if let value = data["owner"] as? [String:Any]{
            owner = RoommateInfo(data: value)
        }
        
        roomChatId = data["cid"] as? String
        
        if let residents = data["residents"] as? [[String:Any]]{
            for res in residents {
                self.residents.append(RoommateInfo(data: res))
            }
        }
    }
}

struct Bill {
    var name: String
    var due : Date
    var des : String
    var spread : [String : Double]
    var amount : Double
    var isDone : Bool
}

enum EventPriority : Int{
    case Low = 0
    case Normal = 1
    case High = 2
}

struct Event {
    var title : String
    var Description : String
    var schedule : DateComponents
    var participants : [RoommateInfo]
    var priority : EventPriority
}

struct Affair {
    var title : String
    var Description : String
    var schedule : DateComponents
    var participant : RoommateInfo
    var priority : EventPriority
}
