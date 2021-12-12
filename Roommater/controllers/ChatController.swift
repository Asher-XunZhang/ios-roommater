//
//  ChatController.swift
//  Roommater
//
//  Created by KAMIKU on 11/10/21.
//

import UIKit
import StreamChat
import StreamChatUI
import SwiftEventBus

class ChatNavigationVC : UINavigationController {
    var channelVC : ChatViewController? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        SwiftEventBus.onBackgroundThread(self, name: "room-binded"){ _ in
            self.initChatVC()
        }
        SwiftEventBus.onBackgroundThread(self, name: "room-unbinded"){ _ in
            self.channelVC?.removeFromParent()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        initChatVC()
    }
    
    func initChatVC(){
        if SessionManager.instance.dorm != nil {
            if let cid = SessionManager.instance.dorm?.roomChatId {
                do{
                    Appearance.default.colorPalette.background6 = .green
                    Appearance.default.images.sendArrow = UIImage(systemName: "arrowshape.turn.up.right")!
                    Components.default.channelVC = ChatViewController.self
                    channelVC = ChatViewController()
                    channelVC!.channelController = ChatClient.shared.channelController(for: try .init(cid: cid))
                    self.addChild(channelVC!)
                }catch{
                    fatalError("Failed to init the chat view!")
                }
            }
        }
    }
}

class ChatViewController : ChatChannelVC {
    var numMsg : Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func eventsController(_ controller: EventsController, didReceiveEvent event: Event) {
        switch event {
            case let e as MessageNewEvent:
                numMsg += (e.unreadCount?.messages ?? 0)
                let content = UNMutableNotificationContent()
                content.title = "Room Chat"
                content.subtitle = SessionManager.instance.dorm?.roomName ?? "???"
                content.body = e.message.textContent ?? ""
                content.badge = NSNumber(value: numMsg)
                let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0, repeats: false)
                let request = UNNotificationRequest(identifier: "Notification", content: content, trigger: trigger)
                UNUserNotificationCenter.current().add(request)
            case let e as MessageReadEvent:
                numMsg -= (e.unreadCount?.messages ?? 0)
                UIApplication.shared.applicationIconBadgeNumber -= numMsg
            default:
                break
        }
    }
}
