//
//  Room.swift
//  Roommater
//
//  Created by KAMIKU on 11/26/21.
//

import Foundation
import SwiftEventBus

class RoomInfo: NSObject, NSSecureCoding {
    static var supportsSecureCoding: Bool {
        return true
    }

    func encode(with coder: NSCoder) {
        coder.encode(roomID, forKey: "RoomID")
        coder.encode(roomName, forKey: "RoomName")
        coder.encode(inviteCode, forKey: "InviteCode")
        coder.encode(maxMember, forKey: "Max")
        coder.encode(roomChatId, forKey: "CID")
        coder.encode(residents, forKey: "Residents")
        coder.encode(owner, forKey: "Owner")
        coder.encode(affairs, forKey: "Affairs")
    }

    required init?(coder: NSCoder) {
        super.init()
        roomID = coder.decodeObject(forKey: "RoomID") as? String
        inviteCode = coder.decodeObject(forKey: "InviteCode") as? String
        roomName = coder.decodeObject(forKey: "RoomName") as? String
        maxMember = coder.decodeObject(forKey: "Max") as? Int
        owner = coder.decodeObject(forKey: "Owner") as? RoommateInfo
        roomChatId = coder.decodeObject(forKey: "CID") as? String
        affairs = coder.decodeObject(forKey: "Affairs") as? [Affair] ?? []
        print("Init RoomInfo Local")
    }

    static var users: [String: RoommateInfo] = [:]
    var roomID: String!
    var inviteCode: String!
    var roomName: String!
    var maxMember: Int!
    var owner: RoommateInfo!
    var residents: [RoommateInfo]! = []
    var roomChatId: String? = ""
    var affairs: [Affair] = []

    init(data: [String: Any]) {
        super.init()
        if let value = data["roomID"] as? String {
            roomID = value
        }
        if let value = data["inviteCode"] as? String {
            inviteCode = value
        }
        if let value = data["name"] as? String {
            roomName = value
        }
        if let value = data["maxResidents"] as? Int {
            maxMember = value
        }
        if let value = data["cid"] as? String {
            roomChatId = value
        }
        if let residents = data["residents"] as? [[String: Any]] {
            for res in residents {
                if res["uid"] as? String == SessionManager.instance.user?.uid {
                    self.residents.append(SessionManager.instance.user!)
                } else {
                    self.residents.append(RoommateInfo(data: res))
                }
            }
            self.residents.forEach{
                RoomInfo.users[$0.uid] = $0
            }
        }
        if let value = data["owner"] as? [String: Any] {
            if let uid = value["uid"] as? String {
                owner = RoomInfo.users[uid]
            }
        }
        if let value = data["affairs"] as? [[String: Any]] {
            affairs = []
            for aff in value {
                affairs.append(Affair(data: aff))
            }
        }
        commit()
        SwiftEventBus.postToMainThread("updateRoom")
    }

    func update(data: [String: Any]) {
        if let value = data["roomID"] as? String {
            roomID = value
        }
        if let value = data["inviteCode"] as? String {
            inviteCode = value
        }
        if let value = data["roomName"] as? String {
            roomName = value
        }
        if let value = data["maxResidents"] as? Int {
            maxMember = value
        }
        if let value = data["cid"] as? String {
            roomChatId = value
        }

        if let value = data["owner"] as? [String: Any] {
            if value["uid"] as? String == SessionManager.instance.user?.uid {
                owner = SessionManager.instance.user
            } else {
                owner = RoomInfo.users[value["uid"] as! String] ?? RoommateInfo(data: value)
            }
        }
        if let residents = data["residents"] as? [[String: Any]] {
            self.residents = []
            for res in residents {
                if res["uid"] as? String == SessionManager.instance.user?.uid {
                    self.residents.append(SessionManager.instance.user!)
                } else {
                    self.residents.append(RoomInfo.users[res["uid"] as! String] ?? RoommateInfo(data: res))
                }
            }
        }
        if let value = data["affairs"] as? [[String: Any]] {
            affairs = []
            for aff in value {
                affairs.append(Affair(data: aff))
            }
        }
        commit()
    }

    @discardableResult func commit() -> Bool {
        do {
            let room_encoded = try NSKeyedArchiver.archivedData(withRootObject: self, requiringSecureCoding: false)
            try room_encoded.write(to: SessionManager.ObjectPath.room.path)
            return true
        } catch (_) {
            print("[Session Manager]Update room info failed")
            return false
        }
    }

    // MARK: - CustomStringConvertible
    override var description: String {
        return "RoomInfo(roomID: \(roomID), inviteCode: \(inviteCode), roomName: \(roomName), maxMember: \(maxMember), owner: \(owner), residents: \(residents), roomChatId: \(roomChatId), affairs: \(affairs))"
    }
}

class Affair: NSObject, NSSecureCoding {
    static var supportsSecureCoding: Bool {
        return true
    }

    func encode(with coder: NSCoder) {
        coder.encode(title, forKey: "Name")
        coder.encode(des, forKey: "Description")
        coder.encode(date, forKey: "Date")
        coder.encode(participant, forKey: "Participant")
        coder.encode(aid, forKey: "AID")
    }

    required init?(coder: NSCoder) {
        super.init()
        title = coder.decodeObject(forKey: "Name") as? String
        des = coder.decodeObject(forKey: "Name") as? String
        participant = coder.decodeObject(forKey: "Participant") as! [RoommateInfo]
        date = coder.decodeObject(forKey: "Date") as! Date
        aid = coder.decodeObject(forKey: "AID") as? String ?? ""

        participant.forEach{
            RoomInfo.users[$0.uid] = $0
        }
    }

    init(data: [String: Any]) {
        super.init()
        if let value = data["what"] as? String {
            title = value
        }
        if let value = data["aid"] as? String {
            aid = value
        }
        if let value = data["description"] as? String {
            des = value
        }
        if let value = data["when"] as? Double {
            date = Date(timeIntervalSince1970: value)
        }
        if let users = data["who"] as? [String] {
//            participant = users.map({ RoomInfo.users[$0]! })
        }
    }

    override init() {
        super.init()
    }

    var aid: String = ""
    var title: String!
    var des: String!
    var date: Date = Date()
    var participant: [RoommateInfo] = []

    func commit(callback: @escaping (Bool) -> Void) {
        APIAction.updateAffiar(
                aid: aid,
                updates: [
                    "what": title as Any,
                    "description": des as Any,
                    "when": date.timeIntervalSince1970,
                    "who": participant.map({ $0.uid })
                ]) { res in
            switch res {
            case .Success(_):
                callback(true)
            default:
                callback(false)
            }
        }
    }

    // MARK: - CustomStringConvertible
    override var description: String {
        return "Affair(title: \(title), des: \(des), date: \(date), participant: \(participant)), aid: \(aid)"
    }
}
