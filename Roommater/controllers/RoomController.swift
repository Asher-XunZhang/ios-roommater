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
            performSegue(withIdentifier: "room_detail", sender: nil)
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

class AffairFormViewController: FormViewController {

    // MARK: Public

    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }

    // MARK: Private

    private enum Repeat {
        case Never, Daily, Weekly, Monthly, Yearly
        func title() -> String {
            switch self {
                case .Never: return "Never"
                case .Daily: return "Daily"
                case .Weekly: return "Weekly"
                case .Monthly: return "Monthly"
                case .Yearly: return "Yearly"
            }
        }
        static func values() -> [Repeat] {
            return [Daily, Weekly, Monthly, Yearly]
        }
    }
    
    private lazy var subRowFormers: [RowFormer] = {
        return (["A", "B" , "C"]).map { index -> RowFormer in
            return CheckRowFormer<FormCheckCell>() {
                $0.titleLabel.text = "Check\(index)"
                $0.titleLabel.textColor = .black
                $0.titleLabel.font = .boldSystemFont(ofSize: 16)
                $0.tintColor = .black
            }.onSelected{ row in
                print(index)
            }
        }
        }()

    private func configure() {
        title = "Add Event"
        tableView.contentInset.top = 10
        tableView.contentInset.bottom = 30
        tableView.contentOffset.y = -10
        
        // Create RowFomers
        
        let titleRow = TextFieldRowFormer<FormTextFieldCell>() {
            $0.textField.textColor = .black
            $0.textField.font = .systemFont(ofSize: 15)
        }.configure {
            $0.placeholder = "Affairs title"
        }
        
        let dateRow = InlineDatePickerRowFormer<FormInlineDatePickerCell>() {
            $0.titleLabel.text = "Start"
            $0.titleLabel.textColor = .black
            $0.titleLabel.font = .boldSystemFont(ofSize: 15)
            $0.displayLabel.textColor = .gray
            $0.displayLabel.font = .systemFont(ofSize: 15)
        }.inlineCellSetup {
            $0.datePicker.datePickerMode = .date
        }.displayTextFromDate(String.mediumDateShortTime)
        
        let repeatRow = InlinePickerRowFormer<FormInlinePickerCell, Repeat>() {
            $0.titleLabel.text = "Repeat"
            $0.titleLabel.textColor = .black
            $0.titleLabel.font = .boldSystemFont(ofSize: 15)
            $0.displayLabel.textColor = .gray
            $0.displayLabel.font = .systemFont(ofSize: 15)
        }.configure {
            let never = Repeat.Never
            $0.pickerItems.append(
                InlinePickerItem(title: never.title(),
                                    displayTitle: NSAttributedString(string: never.title(), attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray]),
                                    value: never)
            )
            $0.pickerItems += Repeat.values().map {
                InlinePickerItem(title: $0.title(), value: $0)
            }
        }
        
        
        
        let detailRow = TextViewRowFormer<FormTextViewCell>() {
            $0.textView.textColor = .gray
            $0.textView.font = .systemFont(ofSize: 15)
        }.configure {
            $0.placeholder = "Note"
            $0.rowHeight = 150
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
        let timeSection = SectionFormer(rowFormer: dateRow, repeatRow)
            .set(headerViewFormer: createHeader())
        let memberSection = SectionFormer(rowFormers: subRowFormers)
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
        
    }
}
