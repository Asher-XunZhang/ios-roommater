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

class RoomNavVC : UINavigationController{
    override func viewDidLoad() {
        super.viewDidLoad()
        if SessionManager.instance.dorm != nil {
            performSegue(withIdentifier: "detail", sender: nil)
        }else{
            performSegue(withIdentifier: "bind", sender: nil)
        }
    }
}

class RoomBindVC : PrototypeViewController {
    @IBOutlet var codeFld : UITextField!
    
    @IBAction func join(){
        if let code = codeFld.text, code != ""{
            APIAction.joinDrom(code: code){ res in
                switch res {
                    case .Success(_):
                        self.performSegue(withIdentifier: "join", sender: nil)
                    case .Error(let msg), .NONE(let msg), .Fail(let msg), .Timeout(let msg):
                        SPIndicator.present(title: msg, preset: .error)
                }
            }
        }
    }
}

class RoomController :UIViewController {
    @IBOutlet var inviteCode : UITextField!
    
    @IBAction func onJoin(){
        if let code = self.inviteCode.text, code != "" {
            APIAction.joinDrom(code: code){ res in
                
            }
        }else{
            SPIndicator.present(title: "Empty Code", preset: .error)
        }
    }
}

class RoomHostController : PrototypeViewController {
    @IBOutlet var tableView : UITableView!
    private lazy var former: Former = Former(tableView: tableView)
    
    @IBAction func cancel(){
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        var max : Int = 0
        
        let roomName = TextFieldRowFormer<FormTextFieldCell>(){
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
            if let value = $0.value as? Int{
                max = value
            }else{
                max = 0
            }
        }
        former.append(sectionFormer: SectionFormer(rowFormer: roomName, maxMember).set(headerViewFormer: FormLabelHeaderView.createHeader("Baisc Info")))
        
        lazy var submitSection : SectionFormer = {
            let updateBtn = CustomRowFormer<ButtonCell>(instantiateType: .Nib(nibName: "ButtonCell")){
                $0.button.setTitle("Create Room", for: .normal)
            }
            .configure{ row in
                row.rowHeight = 54
                row.cell.buttonHandler = { btn in
                    if let room = roomName.cell.textField.text, room != "", max > 0{
                        btn.isEnabled = false
                        row.enabled = false
                        btn.setAnimation(LoadyAnimationType.indicator(with: .init(indicatorViewStyle: .random())))
                        btn.startLoading()
                        maxMember.enabled = false
                        roomName.enabled = false
                        APIAction.hostDorm(roomName: room, max: max){res in
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
                    }else{
                        SPIndicator.present(title: "Invalid", message: "Please check form!", preset: .error)
                    }
                }
            }
            return SectionFormer(rowFormer: updateBtn)
        }()
        former.append(sectionFormer: submitSection)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "host_room" {
            
        }
    }
}

class AffairFormViewController: UIViewController {
    @IBOutlet var tableView : UITableView!
    var affairInfo: Affair?

    private lazy var former: Former = Former(tableView: tableView)

    // MARK: Public

    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }

    @IBAction func buttonAction(_ sender: UIBarButtonItem){
        switch(sender.tag){
        case 2: // the save button
            //TODO: ADD THIS AFFAIR FROM LOCAL AND SERVER
            break
        case 1: // the cancle button
            self.dismiss(animated: true, completion: nil)
            break
        case 3: // the trash button
            //TODO: REMOVE THIS AFFAIR FROM LOCAL AND SERVER
            break
        default:
            break
        }
    }


    // MARK: Private

    private lazy var subRowFormers: [RowFormer] = {
        return (RoomInfo.users.values).map { user -> RowFormer in
            return CheckRowFormer<FormCheckCell>() {
                $0.titleLabel.text = (user.nickname)!
                $0.titleLabel.textColor = .black
                $0.titleLabel.font = .boldSystemFont(ofSize: 16)
                $0.tintColor = .black
                if self.affairInfo != nil, self.affairInfo!.participant.contains(where: {$0.uid == user.uid}){
                    $0.isSelected = true
                }
            }.onCheckChanged{
                print($0) //TODO: CHANGE THIS TO ADD($0==TRUE) TO/REMOVE FROM THIS OBJECT TO THE MEMBER LIST
            }
        }
        }()

    private func configure() {
        var type = ""
        if affairInfo == nil {
            type = "Add"
        }else{
            type = "Edit"
        }

        self.title = type + " Affair"
        self.tableView.contentInset.top = 10
        self.tableView.contentInset.bottom = 30
        self.tableView.contentOffset.y = -10

        // Create RowFomers

        let titleRow = TextFieldRowFormer<FormTextFieldCell>() {
            $0.textField.textColor = .black
            $0.textField.font = .systemFont(ofSize: 15)
        }.configure {
            $0.placeholder = "Affair's Title"
            if type == "Edit"{
                $0.cell.textField.text = self.affairInfo?.title
            }

        }.onTextChanged{
            self.affairInfo?.title = $0
        }

        let dateRow = InlineDatePickerRowFormer<FormInlineDatePickerCell>() {
            $0.titleLabel.text = "Date"
            $0.titleLabel.textColor = .black
            $0.titleLabel.font = .boldSystemFont(ofSize: 15)
            $0.displayLabel.textColor = .gray
            $0.displayLabel.font = .systemFont(ofSize: 15)
        }.inlineCellSetup {
            $0.datePicker.datePickerMode = .date
            if type == "Edit"{
                if let date = self.affairInfo?.date{
                    $0.datePicker.date = date

                }
            }
        }.onDateChanged{
            self.affairInfo?.date = $0
        }.displayTextFromDate(String.mediumDateShortTime)

        let memeberRow = subRowFormers

        let detailRow = TextViewRowFormer<FormTextViewCell>() {
            $0.textView.textColor = .gray
            $0.textView.font = .systemFont(ofSize: 15)
        }.configure {
            $0.placeholder = "Note"
            $0.rowHeight = 150
            if type == "Edit"{
                if let detail = affairInfo?.des {
                    $0.cell.textView.text = detail
                }
            }
        }.onTextChanged{
            self.affairInfo?.des = $0
        }



        // Create Headers

        let createHeader: (() -> ViewFormer) = {
            return CustomViewFormer<FormHeaderFooterView>()
                .configure {
                    $0.viewHeight = 20
                }
        }

        // Create SectionFormers

        let titleSection = SectionFormer(rowFormer: titleRow)
            .set(headerViewFormer: createHeader())
        let timeSection = SectionFormer(rowFormer: dateRow)
            .set(headerViewFormer: createHeader())
        let memberSection = SectionFormer(rowFormers: memeberRow)
            .set(headerViewFormer: createHeader())
        let noteSection = SectionFormer(rowFormer: detailRow)
            .set(headerViewFormer: createHeader())

        former.append(sectionFormer: titleSection, timeSection, memberSection, noteSection)
    }
}

class RoomManageController : FormViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        initFormer()
    }
    
    private func initFormer(){
        let roomID = LabelRowFormer<FormLabelCell>(){
            $0.subTextLabel.adjustsFontSizeToFitWidth = true
        }
        .configure { row in
            row.text = "Room id"
            row.subText = SessionManager.instance.dorm?.roomID
            row.enabled = false
            row.textDisabledColor = .black
            row.subTextDisabledColor = .gray
        }

        let cid = LabelRowFormer<FormLabelCell>(){
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

        let inviteCode = LabelRowFormer<FormLabelCell>(){
            $0.subTextLabel.font = .preferredFont(forTextStyle: .title2)
            $0.subTextLabel.textColor = .green
        }
        .configure { row in
            row.text = "Incite Code"
            row.subText = SessionManager.instance.dorm?.inviteCode
            row.textDisabledColor = .black
            row.subTextDisabledColor = .gray
        }.onSelected{
            self.former.deselect(animated: true)
            UIPasteboard.general.string = $0.subText
            SPIndicator.present(title: "Copied the invite code!", preset: .done)
        }


        former.append(sectionFormer: SectionFormer(rowFormer: roomID, cid, owner))
        former.append(sectionFormer: SectionFormer(rowFormer: inviteCode))
    }
}
