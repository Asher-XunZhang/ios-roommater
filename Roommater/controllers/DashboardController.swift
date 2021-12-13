//
//  DashboardController.swift
//  Roommater
//
//  Created by KAMIKU on 10/23/21.
//

import UIKit
import Foundation
import FoldingCell
import Former
import TaggerKit
import SPIndicator
import SwiftEventBus
import EventKit

final class DashboardNavVC: UINavigationController {
    override func viewDidLoad() {
        super.viewDidLoad()
        if SessionManager.instance.dorm != nil {
            performSegue(withIdentifier: "goToAffairs", sender: nil)
        } else {
            performSegue(withIdentifier: "noRoom", sender: self)
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "noRoom" {
            (segue.destination as! RoomNavVC).rootController = sender as! DashboardNavVC
        }
    }
}

class SegmentViewController: UIViewController {
    @IBAction func AddNewAffair(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "addAffair", sender: Affair())
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "addAffair", let vc = segue.destination as? AffairFormViewController, let v = sender as? Affair {
            vc.affairInfo = v
        }
    }
}

class TableViewController: UITableViewController {
    enum Const {
        static let closeCellHeight: CGFloat = 180
        static let openCellHeight: CGFloat = 350
    }

    var cellHeights: [CGFloat] = []

    // MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        SwiftEventBus.onMainThread(self, name: "updateRoom", sender: nil){ _ in
            self.tableView.reloadData()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setup()
    }

    // MARK: Helpers
    private func setup() {
        cellHeights = Array(repeating: Const.closeCellHeight, count: SessionManager.instance.dorm?.affairs.count ?? 0)
        tableView.estimatedRowHeight = Const.closeCellHeight
        tableView.rowHeight = UITableView.automaticDimension
        tableView.backgroundColor = .cyan
        if #available(iOS 10.0, *) {
            tableView.refreshControl = UIRefreshControl()
            tableView.refreshControl?.addTarget(self, action: #selector(refreshHandler), for: .valueChanged)
        }
    }

    // MARK: Actions
    @objc func refreshHandler() {
        cellHeights = Array(repeating: Const.closeCellHeight, count: SessionManager.instance.dorm?.affairs.count ?? 0)
        let deadlineTime = DispatchTime.now() + .seconds(1)
        DispatchQueue.main.asyncAfter(deadline: deadlineTime, execute: { [weak self] in
            if #available(iOS 10.0, *) {
                self?.tableView.refreshControl?.endRefreshing()
            }
            self?.tableView.reloadData()
        })
    }
}

extension TableViewController {
    override func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return SessionManager.instance.dorm?.affairs.count ?? 0
    }

    override func tableView(_: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard case let cell as AffairCell = cell else {return}
        cell.backgroundColor = .clear
        if cellHeights[indexPath.row] == Const.closeCellHeight {cell.unfold(false, animated: false, completion: nil)}
        else {cell.unfold(true, animated: false, completion: nil)}
        cell.doneHandle = {
            self.alertWithConfirm(title: "Finish", msg: "Are you sure to finish this affair?(This affair will be deleted)"){ _ in
                if let a = SessionManager.instance.dorm?.affairs[indexPath.row] {
                    APIAction.deleteAffiar(aid: a.aid){
                        switch $0{
                            case .Success(_):
                                SPIndicator.present(title: "Remove the affair!", preset: .done)
                                SessionManager.instance.dorm?.affairs.remove(at: indexPath.row)
                                self.cellHeights = Array(repeating: Const.closeCellHeight, count: SessionManager.instance.dorm?.affairs.count ?? 0)
                                self.tableView.reloadData()
                            case .Fail(let msg), .Timeout(let msg), .Error(let msg), .NONE(let msg):
                                SPIndicator.present(title: msg, preset: .error)
                        }
                    }
                    
                }
            }
        }
        cell.editHandle = {self.performSegue(withIdentifier: "edit", sender: SessionManager.instance.dorm?.affairs[indexPath.row])}
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "edit", let data = sender as? Affair, let vc = segue.destination as? AffairFormViewController {
            vc.affairInfo = data
        }else{
            print("Error init the edit data")
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FoldingCell", for: indexPath) as! AffairCell
        let durations: [TimeInterval] = [0.26, 0.2, 0.2]
        cell.durationsForExpandedState = durations
        cell.durationsForCollapsedState = durations
        if let info = SessionManager.instance.dorm?.affairs[indexPath.row] {
            cell.closeTitleLabel.text = info.title
            let dateFormatter = DateFormatter()
            dateFormatter.locale = .autoupdatingCurrent
            dateFormatter.formattingContext = .beginningOfSentence
            dateFormatter.dateFormat = "[E]MMM d, yyyy, HH:mm"
            cell.closeDate.text = dateFormatter.string(from: info.date)
            cell.title.text = info.title
            cell.date.text = cell.closeDate.text
            cell.members.text = info.participant.reduce("", { $0 + " " + $1.nickname.components(separatedBy: " ").reduce("", { $0 + String($1.first!) }) })
            cell.detail.text = info.des
        }
        return cell
    }

    override func tableView(_: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return cellHeights[indexPath.row]
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! FoldingCell
        if cell.isAnimating() {
            return
        }
        var duration = 0.0
        let cellIsCollapsed = cellHeights[indexPath.row] == Const.closeCellHeight
        if cellIsCollapsed {
            cellHeights[indexPath.row] = Const.openCellHeight
            cell.unfold(true, animated: true, completion: nil)
            duration = 0.5
        } else {
            cellHeights[indexPath.row] = Const.closeCellHeight
            cell.unfold(false, animated: true, completion: nil)
            duration = 0.8
        }
        UIView.animate(withDuration: duration, delay: 0, options: .curveEaseOut, animations: { () -> Void in
            tableView.beginUpdates()
            tableView.endUpdates()
            if cell.frame.maxY > tableView.frame.maxY {
                tableView.scrollToRow(at: indexPath, at: UITableView.ScrollPosition.bottom, animated: true)
            }
        }, completion: nil)
    }
}

class AffairFormViewController: UIViewController {
    @IBOutlet var tableView: UITableView!
    var affairInfo: Affair!
    
    private lazy var former: Former = Former(tableView: tableView)
    
    // MARK: Public
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }
    
    @IBAction func buttonAction(_ sender: UIBarButtonItem) {
        switch (sender.tag) {
            case 2: // the save button
                if affairInfo.aid == "" {
                    APIAction.postAffiar(data: [
                        "what": affairInfo.title ?? "New Affair",
                        "when": affairInfo.date.timeIntervalSince1970,
                        "who":  affairInfo.participant.map({ $0.uid }),
                        "description": affairInfo!.des ?? ""
                    ]) { res in
                        switch res {
                            case .Success(let data):
                                SessionManager.instance.dorm?.affairs.append(Affair.init(data: data as! [String : Any]))
                                eventStore.requestAccess(to: .event){ isAllow, error in
                                    if isAllow {
                                        let newEvent = EKEvent.init(eventStore: eventStore)
                                        newEvent.title = "[Roommater Affair]\(self.affairInfo.title!)"
                                        newEvent.notes = self.affairInfo.des
                                        newEvent.calendar = eventStore.defaultCalendarForNewEvents
                                        newEvent.calendar.title =  newEvent.title
                                        newEvent.startDate = self.affairInfo.date
                                        newEvent.endDate = self.affairInfo.date.addingTimeInterval(30*60)
                                        newEvent.addAlarm(EKAlarm(relativeOffset: -60 * 5))
                                        newEvent.eventIdentifier
                                        do {
                                            try eventStore.save(newEvent, span: .thisEvent, commit: true)
                                            DispatchQueue.main.async {
                                                SPIndicator.present(title: "Success", preset: .done)
                                                self.dismiss(animated: true)
                                            }
                                        }catch {
                                            DispatchQueue.main.async {
                                                SPIndicator.present(title: "Failed to add to the calendar!", preset: .error)
                                                self.dismiss(animated: true)
                                            }
                                        }
                                       
                                    }
                                }
                            case .Fail(let msg), .Timeout(let msg), .Error(let msg), .NONE(let msg):
                                SPIndicator.present(title: msg, preset: .error)
                        }
                    }
                }
            case 1: // the cancle button
                self.navigationController?.popViewController(animated: true)
                self.dismiss(animated: true, completion: nil)
            case 3: // the trash button
                alertWithConfirm(title: "Delete", msg: "Do you want to remove this affair") { _ in
                    APIAction.deleteAffiar(aid: self.affairInfo.aid){
                        switch $0 {
                            case .Success(_):
                                SessionManager.instance.dorm?.affairs.remove(at: (SessionManager.instance.dorm?.affairs.firstIndex(of: self.affairInfo))!)
                                SPIndicator.present(title: "Success remove the affair", preset: .done)
                            case .Fail(let msg), .Timeout(let msg), .Error(let msg), .NONE(let msg):
                                SPIndicator.present(title: msg, preset: .error)
                        }
                    }
                }
            default:break
        }
    }
    
    // MARK: Private
    
    private lazy var subRowFormers: [RowFormer] = {
        var isNew: Bool { return affairInfo.aid == ""}
        return (RoomInfo.users.values).map { user -> RowFormer in
            return CheckRowFormer<FormCheckCell>() {
                $0.titleLabel.text = (user.nickname)!
                $0.titleLabel.textColor = .black
                $0.titleLabel.font = .boldSystemFont(ofSize: 16)
                $0.tintColor = .black
            }.configure{
                if user.uid == SessionManager.instance.user?.uid {
                    $0.checked = true
                    $0.enabled = false
                    self.affairInfo.participant.append(user)
                }
                if !isNew {
                    if affairInfo.participant.contains(user) {
                        $0.checked = true
                    }
                }
            }.onCheckChanged {
                if $0 {
                    if !self.affairInfo.participant.contains(user) {
                        self.affairInfo.participant.append(user)
                    }
                } else {
                    if let index = self.affairInfo.participant.firstIndex(of: user) {
                        self.affairInfo.participant.remove(at: index)
                    }
                }
            }
        }
    }()
    
    private func configure() {
        var isNew: Bool { return affairInfo.aid == ""}
        // Create RowFomers
        let titleRow = TextFieldRowFormer<FormTextFieldCell>() {
            $0.textField.textColor = .black
            $0.textField.font = .systemFont(ofSize: 15)
        }.configure {
            $0.placeholder = "Title"
            if !isNew {
                $0.text = affairInfo.title
            }
        }.onTextChanged {[self] in
            affairInfo.title = $0
        }
        
        let dateRow = InlineDatePickerRowFormer<FormInlineDatePickerCell>() {
            $0.titleLabel.text = "Date"
            $0.titleLabel.textColor = .black
            $0.titleLabel.font = .boldSystemFont(ofSize: 15)
            $0.displayLabel.textColor = .gray
            $0.displayLabel.font = .systemFont(ofSize: 15)
        }.inlineCellSetup { [self] in
            $0.datePicker.datePickerMode = .dateAndTime
            if !isNew {$0.datePicker.setDate(affairInfo.date, animated: true)}
        }.onDateChanged { [self] in
            affairInfo.date = $0
        }.displayTextFromDate(String.mediumDateShortTime)
        
        let memeberRow = subRowFormers
        
        let detailRow = TextViewRowFormer<FormTextViewCell>() {
            $0.textView.textColor = .gray
            $0.textView.font = .systemFont(ofSize: 15)
        }.configure {
            $0.placeholder = "Note"
            $0.rowHeight = 150
            if !isNew {
                $0.text = affairInfo.des
            }
        }.onTextChanged { [self] in
            affairInfo.des = $0
        }
        
        // Create SectionFormers
        let titleSection = SectionFormer(rowFormer: titleRow)
        let timeSection = SectionFormer(rowFormer: dateRow)
        let memberSection = SectionFormer(rowFormers: memeberRow).set(headerViewFormer: FormLabelHeaderView.createHeader("Room Member:"))
        let noteSection = SectionFormer(rowFormer: detailRow)
        former.append(sectionFormer: titleSection, timeSection, memberSection, noteSection)
    }
}
