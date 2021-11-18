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
    override func viewDidLoad() {
        super.viewDidLoad()
        do{
            Appearance.default.colorPalette.background6 = .blue
            Appearance.default.images.sendArrow = UIImage(systemName: "arrowshape.turn.up.right")!
            Components.default.channelVC = ChatViewController.self
            let channelVC = ChatViewController()
            channelVC.channelController = ChatClient.shared.channelController(for: try .init(cid: "team:dev_ad284e8a-baff-4ada-b009-595e7ef68c82"))
            self.addChild(channelVC)
        }catch{
            fatalError("Fail to init the chat view!")
        }
    }
}

class ChatViewController : ChatChannelVC {
    
}
