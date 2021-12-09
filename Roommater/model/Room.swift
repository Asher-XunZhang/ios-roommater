//
//  Room.swift
//  Roommater
//
//  Created by KAMIKU on 11/26/21.
//

import Foundation

class RoomInfo : NSObject, NSSecureCoding {
    static var supportsSecureCoding: Bool{
        return true
    }
    
    func encode(with coder: NSCoder) {
        coder.encode(roomID, forKey: "RoomID")
        coder.encode(roomName, forKey: "RoomName")
        coder.encode(inviteCode, forKey: "InviteCode")
        coder.encode(maxMemeber, forKey: "Max")
        coder.encode(roomChatId, forKey: "CID")
        coder.encode(residents, forKey: "Residents")
        coder.encode(owner, forKey: "Owner")
        coder.encode(bills, forKey: "Bills")
        coder.encode(affairs, forKey: "Affairs")
    }
    
    required init?(coder: NSCoder) {
        super.init()
        roomID = coder.decodeObject(forKey: "RoomID") as? String
        inviteCode = coder.decodeObject(forKey: "RoomName") as? String
        roomName = coder.decodeObject(forKey: "InviteCode") as? String
        maxMemeber = coder.decodeObject(forKey: "Max") as? Int
        owner = coder.decodeObject(forKey: "Owner") as? RoommateInfo
        roomChatId = coder.decodeObject(forKey: "CID") as? String
        affairs = coder.decodeObject(forKey: "Affairs") as? [Affair]
        bills = coder.decodeObject(forKey: "Bills") as? [Bill]
    }
    
    static var users : [String : RoommateInfo] = [:]
    var roomID : String!
    var inviteCode : String!
    var roomName : String!
    var maxMemeber : Int!
    var owner : RoommateInfo!
    var residents : [RoommateInfo]!
    var bills : [Bill]!
    var roomChatId : String?
    var affairs : [Affair]!
    
    init(data : [String:Any]) {
        super.init()
        if let value = data["roomID"] as? String{roomID = value}
        if let value = data["inviteCode"] as? String{inviteCode = value}
        if let value = data["roomName"] as? String{roomName = value}
        if let value = data["maxRsidents"] as? Int{maxMemeber = value}
        if let value = data["owner"] as? [String:Any]{owner = RoommateInfo(data: value)}
        roomChatId = data["cid"] as? String
        if let residents = data["residents"] as? [[String:Any]]{
            for res in residents {
                self.residents.append(RoommateInfo(data: res))
            }
        }
    }
    
    func update(data : [String:Any]){
        if let value = data["roomID"] as? String{roomID = value}
        if let value = data["inviteCode"] as? String{inviteCode = value}
        if let value = data["roomName"] as? String{roomName = value}
        if let value = data["maxRsidents"] as? Int{maxMemeber = value}
        if let value = data["owner"] as? [String:Any]{owner = RoommateInfo(data: value)}
        residents = []
        if let residents = data["residents"] as? [[String:Any]]{
            for res in residents {
                self.residents.append(RoommateInfo(data: res))
            }
        }
        do{
            let room_encoded = try NSKeyedArchiver.archivedData(withRootObject: self, requiringSecureCoding: false)
            try room_encoded.write(to: SessionManager.ObjectPath.room.path)
        }catch (let e){
            print(e)
            print("[Session Manager]Update room info failed")
        }
    }
}

class Bill : NSObject, NSSecureCoding {
    static var supportsSecureCoding: Bool{
        return true
    }
    
    func encode(with coder: NSCoder) {
        coder.encode(name, forKey: "Name")
        coder.encode(due, forKey: "Due")
        coder.encode(des, forKey: "Description")
        coder.encode(spread, forKey: "Spread")
        coder.encode(amount, forKey: "Amount")
        coder.encode(isDone, forKey: "Done")
    }
    
    required init?(coder: NSCoder) {
        super.init()
        name = coder.decodeObject(forKey: "Name") as? String
        due  = coder.decodeObject(forKey: "Due") as? Date
        des  = coder.decodeObject(forKey: "Description") as? String
        amount  = coder.decodeDouble(forKey: "Amount")
        isDone  = coder.decodeBool(forKey: "Done")
        spread = coder.decodeObject(forKey: "Spread") as? Dictionary
    }
    
    init(data: [String:Any]) {
        if let value = data["name"] as? String{name = value}
        if let value = data["des"] as? String{des = value}
        if let value = data["isDone"] as? Bool{isDone = value}
        if let value = data["amount"] as? Double{amount = value}
        if let value = data["due"] as? Double{amount = value}
        
    }
    
    var name: String!
    var due : Date!
    var des : String!
    var spread : [RoommateInfo : Double]!
    var amount : Double!
    var isDone : Bool!
    
    func commit(){
        
    }
}

class Affair : NSObject, NSSecureCoding {
    var testData : [Affair] {
        let a = Affair(data: [:])
        a.title = "Affair 1"
        a.des = "This is a test of affair"
        a.participant = [SessionManager.instance.user!]
        a.date = Date()
        return [a]
    }
    
    static var supportsSecureCoding: Bool{
        return true
    }
    
    func encode(with coder: NSCoder) {
        coder.encode(title, forKey: "Name")
        coder.encode(des, forKey: "Description")
        coder.encode(date, forKey: "Date")
        coder.encode(participant, forKey: "Participant")
    }
    
    required init?(coder: NSCoder) {
        title = coder.decodeObject(forKey: "Name") as? String
        des = coder.decodeObject(forKey: "Name") as? String
        participant = coder.decodeObject(forKey: "Participant") as? [RoommateInfo]
        date = coder.decodeObject(forKey: "Date") as? Date
    }
    
    init(data: [String:Any]) {
        
    }
    
    var title : String!
    var des : String!
    var date : Date!
    var participant : [RoommateInfo]!
    
    func commit(){
        
    }
}
