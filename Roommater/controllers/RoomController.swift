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

final class AddEventViewController: FormViewController {
    
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
    
    private enum Alert {
        case None, AtTime, Five, Thirty, Hour, Day, Week
        func title() -> String {
            switch self {
                case .None: return "None"
                case .AtTime: return "At time of event"
                case .Five: return "5 minutes before"
                case .Thirty: return "30 minutes before"
                case .Hour: return "1 hour before"
                case .Day: return "1 day before"
                case .Week: return "1 week before"
            }
        }
        static func values() -> [Alert] {
            return [AtTime, Five, Thirty, Hour, Day, Week]
        }
    }
    
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
            $0.placeholder = "Event title"
        }
        let locationRow = TextFieldRowFormer<FormTextFieldCell>() {
            $0.textField.textColor = .black
            $0.textField.font = .systemFont(ofSize: 15)
        }.configure {
            $0.placeholder = "Location"
        }
        let startRow = InlineDatePickerRowFormer<FormInlineDatePickerCell>() {
            $0.titleLabel.text = "Start"
            $0.titleLabel.textColor = .black
            $0.titleLabel.font = .boldSystemFont(ofSize: 15)
            $0.displayLabel.textColor = .gray
            $0.displayLabel.font = .systemFont(ofSize: 15)
        }.inlineCellSetup {
            $0.datePicker.datePickerMode = .dateAndTime
        }.displayTextFromDate(String.mediumDateShortTime)
        let endRow = InlineDatePickerRowFormer<FormInlineDatePickerCell>() {
            $0.titleLabel.text = "End"
            $0.titleLabel.textColor = .black
            $0.titleLabel.font = .boldSystemFont(ofSize: 15)
            $0.displayLabel.textColor = .gray
            $0.displayLabel.font = .systemFont(ofSize: 15)
        }.inlineCellSetup {
            $0.datePicker.datePickerMode = .dateAndTime
        }.displayTextFromDate(String.mediumDateShortTime)
        let allDayRow = SwitchRowFormer<FormSwitchCell>() {
            $0.titleLabel.text = "All-day"
            $0.titleLabel.textColor = .black
            $0.titleLabel.font = .boldSystemFont(ofSize: 15)
            $0.switchButton.onTintColor = .gray
        }.onSwitchChanged { on in
            startRow.update {
                $0.displayTextFromDate(
                    on ? String.mediumDateNoTime : String.mediumDateShortTime
                )
            }
            startRow.inlineCellUpdate {
                $0.datePicker.datePickerMode = on ? .date : .dateAndTime
            }
            endRow.update {
                $0.displayTextFromDate(
                    on ? String.mediumDateNoTime : String.mediumDateShortTime
                )
            }
            endRow.inlineCellUpdate {
                $0.datePicker.datePickerMode = on ? .date : .dateAndTime
            }
        }
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
        let alertRow = InlinePickerRowFormer<FormInlinePickerCell, Alert>() {
            $0.titleLabel.text = "Alert"
            $0.titleLabel.textColor = .black
            $0.titleLabel.font = .boldSystemFont(ofSize: 15)
            $0.displayLabel.textColor = .gray
            $0.displayLabel.font = .systemFont(ofSize: 15)
        }.configure {
            let none = Alert.None
            $0.pickerItems.append(
                InlinePickerItem(title: none.title(),
                                 displayTitle: NSAttributedString(string: none.title(), attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray]),
                                 value: none)
            )
            $0.pickerItems += Alert.values().map {
                InlinePickerItem(title: $0.title(), value: $0)
            }
        }
        let urlRow = TextFieldRowFormer<FormTextFieldCell>() {
            $0.textField.textColor = .gray
            $0.textField.font = .systemFont(ofSize: 15)
            $0.textField.keyboardType = .alphabet
        }.configure {
            $0.placeholder = "URL"
        }
        let noteRow = TextViewRowFormer<FormTextViewCell>() {
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
        
        let titleSection = SectionFormer(rowFormer: titleRow, locationRow)
            .set(headerViewFormer: createHeader())
        let dateSection = SectionFormer(rowFormer: allDayRow, startRow, endRow)
            .set(headerViewFormer: createHeader())
        let repeatSection = SectionFormer(rowFormer: repeatRow, alertRow)
            .set(headerViewFormer: createHeader())
        let noteSection = SectionFormer(rowFormer: urlRow, noteRow)
            .set(headerViewFormer: createHeader())
        
        former.append(sectionFormer: titleSection, dateSection, repeatSection, noteSection)
    }
}
