//
//  RoomController.swift
//  Roommater
//
//  Created by KAMIKU on 12/6/21.
//

import Foundation
import UIKit
import Former
import Loady
import SPIndicator
import SwiftEventBus

class RoomNavVC: UINavigationController {
    var rootController: UIViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if SessionManager.instance.dorm != nil {
            performSegue(withIdentifier: "detail", sender: nil)
        } else {
            performSegue(withIdentifier: "bind", sender: nil)
        }
    }

    func back() {
        guard self.rootController != nil else {return}
        self.rootController?.navigationController?.popToRootViewController(animated: true)
    }
}

class RoomBindVC: PrototypeViewController {
    @IBOutlet var codeFld: UITextField!

    @IBAction func join() {
        if let code = codeFld.text, code != "" {
            APIAction.joinDrom(code: code) { res in
                switch res {
                case .Success(let data):
                    if SessionManager.instance.dorm == nil {
                        SessionManager.instance.initDorm(data: data as! [String: Any])
                    }
                    self.performSegue(withIdentifier: "join", sender: nil)
                case .Error(let msg), .NONE(let msg), .Fail(let msg), .Timeout(let msg):
                    SPIndicator.present(title: msg, preset: .error)
                }
            }
        }
    }

    @IBAction func quit() {
        APIAction.logout(callback: { res in
            switch res {
            case .Success(_):
                self.dismiss(animated: true);
                (self.navigationController as! RoomNavVC).back()
            case .Fail(let msg), .Timeout(let msg), .Error(let msg):
                SPIndicator.present(title: "Error", message: msg, preset: .error)
            case .NONE:
                SPIndicator.present(title: "Error", message: "Unknown Error", preset: .error)
            }
        })
    }
}

class RoomController: UIViewController {
    @IBOutlet var inviteCode: UITextField!

    @IBAction func onJoin() {
        if let code = self.inviteCode.text, code != "" {
            APIAction.joinDrom(code: code) { res in
                switch res {
                case .Success(_):
                    SPIndicator.present(title: "Success join the room!", preset: .done)
                    guard let nav = self.navigationController as? RoomNavVC, let vc = nav.rootController else {
                        return
                    }
                    nav.present(vc, animated: true, completion: nil)
                case .Fail(let msg), .Timeout(let msg), .Error(let msg), .NONE(let msg):
                    SPIndicator.present(title: msg, preset: .error)
                }
            }
        } else {
            SPIndicator.present(title: "Empty Code", preset: .error)
        }
    }
}

class RoomHostController: PrototypeViewController {
    @IBOutlet var tableView: UITableView!
    private lazy var former: Former = Former(tableView: tableView)

    @IBAction func cancel() {
        self.dismiss(animated: true, completion: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        var max: Int = 0
        let roomName = TextFieldRowFormer<FormTextFieldCell>() {
            $0.titleLabel.text = "Room Name"
        }.configure {
            $0.placeholder = "Your Room Name"
        }
        let maxMember = InlinePickerRowFormer<FormInlinePickerCell, Any>() {
            $0.titleLabel.text = "Max Member"
        }.configure {
            $0.pickerItems = [InlinePickerItem(
                    title: "",
                    displayTitle: NSAttributedString(string: "Not set"),
                    value: 0)]
                    + (1...10).map {
                InlinePickerItem(title: "\($0 ?? "")", displayTitle: NSAttributedString(string: "\($0 ?? "No") people"), value: $0)
            }
        }.onValueChanged {
            if let value = $0.value as? Int {
                max = value
            } else {
                max = 0
            }
        }
        former.append(sectionFormer: SectionFormer(rowFormer: roomName, maxMember).set(headerViewFormer: FormLabelHeaderView.createHeader("Baisc Info")))

        lazy var submitSection: SectionFormer = {
            let updateBtn = CustomRowFormer<ButtonCell>(instantiateType: .Nib(nibName: "ButtonCell")) {
                $0.button.setTitle("Create Room", for: .normal)
            }
            .configure { row in
                row.rowHeight = 54
                row.cell.buttonHandler = { btn in
                    if let room = roomName.cell.textField.text, room != "", max > 0 {
                        btn.isEnabled = false
                        row.enabled = false
                        btn.setAnimation(LoadyAnimationType.indicator(with: .init(indicatorViewStyle: .random())))
                        btn.startLoading()
                        maxMember.enabled = false
                        roomName.enabled = false
                        APIAction.hostDorm(roomName: room, max: max) { res in
                            switch res {
                            case .Success(_):
                                self.performSegue(withIdentifier: "host_room", sender: nil)
                            case .Fail(let msg), .Timeout(let msg), .Error(let msg), .NONE(let msg):
                                SPIndicator.present(title: "Error", message: msg, preset: .error)
                                btn.stopLoading()
                                maxMember.enabled = true
                                roomName.enabled = true
                                row.enabled = true
                                btn.isEnabled = true
                            }
                        }
                    } else {
                        SPIndicator.present(title: "Invalid", message: "Please check form!", preset: .error)
                    }
                }
            }
            return SectionFormer(rowFormer: updateBtn)
        }()
        former.append(sectionFormer: submitSection)
    }
}

class RoomManageController: FormViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        initFormer()
    }

    private func initFormer() {
        let roomName = TextFieldRowFormer<FormTextFieldCell>() { row in
            row.titleLabel.text = "Room Name"
            row.titleLabel.textColor = .black
            row.titleLabel.font = .boldSystemFont(ofSize: 16)
            row.textField.textColor = .black
            row.textField.textAlignment = .right
            row.textField.font = .boldSystemFont(ofSize: 14)
            row.textField.returnKeyType = .done
            row.tintColor = .black
        }.configure { row in
            row.placeholder = "Room Name"
            row.text = SessionManager.instance.dorm?.roomName
            row.cell.textField.text = SessionManager.instance.dorm?.roomName
            if SessionManager.instance.dorm?.owner.uid != SessionManager.instance.user?.uid {
                row.enabled = false
            } else {
                row.enabled = true
            }
        }.onReturn { text in
            if text != "" {
                APIAction.updateRoom(name: text) { res in
                    switch res {
                    case .Success(_):
                        SessionManager.instance.dorm?.roomName = text
                        SPIndicator.present(title: "Rename Successfully", preset: .done)
                        self.dismiss(animated: true, completion: nil)
                    case .Fail(let msg), .Timeout(let msg), .Error(let msg), .NONE(let msg):
                        SPIndicator.present(title: msg, preset: .error)
                    }
                }
            } else {SPIndicator.present(title: "Empty the rooom name!", preset: .error)}
        }

        let roomID = LabelRowFormer<FormLabelCell>() {
            $0.subTextLabel.adjustsFontSizeToFitWidth = true
        }
                .configure { row in
                    row.text = "Room id"
                    row.subText = SessionManager.instance.dorm?.roomID
                    row.enabled = false
                    row.textDisabledColor = .black
                    row.subTextDisabledColor = .gray
                }

        let cid = LabelRowFormer<FormLabelCell>() {
            $0.subTextLabel.adjustsFontSizeToFitWidth = true
        }
                .configure { row in
                    row.text = "Chat ID"
                    row.subText = SessionManager.instance.dorm?.roomChatId
                    row.enabled = false
                    row.textDisabledColor = .black
                    row.subTextDisabledColor = .gray
                }

        let owner = LabelRowFormer<FormLabelCell>()
                .configure { row in
                    row.text = "Owner"
                    row.subText = SessionManager.instance.dorm?.owner.nickname
                    row.enabled = false
                    row.textDisabledColor = .black
                    row.subTextDisabledColor = .gray
                }

        let inviteCode = LabelRowFormer<FormLabelCell>() {
            $0.subTextLabel.font = .preferredFont(forTextStyle: .title2)
            $0.subTextLabel.textColor = .green
        }
                .configure { row in
                    row.text = "Invite Code"
                    row.subText = SessionManager.instance.dorm?.inviteCode
                    row.textDisabledColor = .black
                    row.subTextDisabledColor = .gray
                }.onSelected {
                    self.former.deselect(animated: true)
                    UIPasteboard.general.string = $0.subText
                    SPIndicator.present(title: "Copied the invite code!", preset: .done)
                }

        let memberSection = SectionFormer().set(headerViewFormer: FormLabelHeaderView.createHeader("Room Member"))
        RoomInfo.users.values.forEach { user in
            memberSection.append(rowFormer: CustomRowFormer<UserCell>(instantiateType: .Nib(nibName: "UserCell")) { _ in
            }
            .configure { row in
                row.rowHeight = 80
                row.cell.userAvatar.setImage(user.avatarImage?.af.imageAspectScaled(toFill: CGSize(
                    width: row.cell.userAvatar.bounds.width,
                    height: row.cell.userAvatar.bounds.height
                )) ?? UIImage(named: "DefaultAvatar")!)
                row.cell.userName.text = user.nickname
                if SessionManager.instance.dorm?.owner.uid == SessionManager.instance.user?.uid { // as room host
                    row.enabled = true
                    if user.uid == SessionManager.instance.user?.uid { //self
                        row.cell.asHost.isEnabled = false
                        row.cell.asHost.setTitle("Owner", for: .disabled)
                    } else { //other memeber
                        row.cell.asHost.isEnabled = true
                        row.cell.setHostAtion = { _ in
                            self.alertWithConfirm(title: "Transter Ownership", msg: "Do you want to transfer the ownership to the new user?(You will lost the controll of the room)"){_ in
                                APIAction.changeRoomOwner(newOwnerID: user.uid){
                                    switch $0 {
                                        case .Success(_):
                                            SessionManager.instance.dorm?.owner = user
                                            SessionManager.instance.dorm?.commit()
                                            SPIndicator.present(title: "Success change the room owner!", preset: .done)
                                            self.dismiss(animated: true)
                                        case .Error(let msg), .Fail(let msg), .Timeout(let msg), .NONE(let msg):
                                            SPIndicator.present(title: msg, preset: .error)
                                    }
                                }
                            }
                        }
                    }
                } else {
                    row.enabled = false
                    if user.uid == SessionManager.instance.dorm?.owner.uid {
                        row.cell.asHost.isEnabled = false
                        row.cell.asHost.setTitle("Owner", for: .disabled)
                    } else {
                        row.cell.asHost.isHidden = true
                    }
                }
            }.onSelected {
                $0.former?.deselect(animated: true)
            })
        }

        former.append(sectionFormer: SectionFormer(rowFormer: roomName))
        former.append(sectionFormer: SectionFormer(rowFormer: roomID, cid, owner))
        former.append(sectionFormer: SectionFormer(rowFormer: inviteCode), memberSection)

        let quit = CustomRowFormer<ButtonCell>(instantiateType: .Nib(nibName: "ButtonCell")) {
            $0.button.setTitle("Quit The Room", for: .normal)
        }.configure { row in
            row.cell.buttonHandler = { btn in
                self.alertWithConfirm(title: "Quit", msg: "Are you sure to quit this room? (If you are the room host, the room will be deleted.)") { res in
                    APIAction.quitDorm { res in
                        btn.startLoading()
                        switch res {
                        case .Success(_):
                            SPIndicator.present(title: "Success Quit the Room", preset: .done)
                            SessionManager.instance.clearRoom()
                            self.performSegue(withIdentifier: "quit", sender: nil)
                        case .Fail(let msg), .Timeout(let msg), .Error(let msg), .NONE(let msg):
                            SPIndicator.present(title: msg, preset: .error)
                            btn.stopLoading()
                        }
                    }
                }
            }
        }
        former.append(sectionFormer: SectionFormer(rowFormer: quit))
    }
}
