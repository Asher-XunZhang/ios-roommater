//
//  SettingController.swift
//  Roommater
//
//  Created by KAMIKU on 10/23/21.
//

import Foundation
import UIKit
import SPIndicator

class SettingController : UITableViewController {
    @IBOutlet var usernameLabel : UILabel!
    @IBOutlet var roomConigCell : UITableViewCell!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if true {
            var bindBtn = UIButton()
            bindBtn.setTitle("Bind Room", for: .normal)
            roomConigCell.addSubview(bindBtn)
        }
    }
    
    @IBAction func logout(){
        APIAction.logout(callback: {res in
            switch res {
                case .Success(_):
                    self.navigationController?.navigationController?.popViewController(animated: true);
                case .Fail(let msg), .Timeout(let msg), .Error(let msg):
                    SPIndicator.present(title: "Error", message: msg, preset: .error)
                case .NONE:
                    SPIndicator.present(title: "Error", message: "Unknown Error", preset: .error)
            }
        })
    }
}
