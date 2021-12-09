//
//  ChatController.swift
//  Roommater
//
//  Created by KAMIKU on 11/10/21.
//

import UIKit
import StreamChat
import StreamChatUI

class ChatNavigationVC : UINavigationController{
    var channelVC : ChatViewController? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if SessionManager.instance.dorm != nil {
            if let cid = SessionManager.instance.dorm?.roomChatId {
                do{
                    Appearance.default.colorPalette.background6 = .lightGray
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
    
}
