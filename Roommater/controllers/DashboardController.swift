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

final class DashboardNavVC : UINavigationController {
    override func viewDidLoad() {
        super.viewDidLoad()
        if SessionManager.instance.dorm != nil {
            performSegue(withIdentifier: "goToAffairs", sender:nil)
            print("Go to affair")
        }else{
            performSegue(withIdentifier: "noRoom", sender: nil)
            print("No room found")
        }
    }
}


class SegmentViewController: UIViewController{
    
    @IBAction func ChangeMode(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex{
            case 0:
//                performSegue(withIdentifier: "goToAffairs", sender:nil)
            break
            case 1:
                break
//                performSegue(withIdentifier: "go_to_billings", sender: nil)
            default:
                break
        }
    }
    @IBAction func AddNewAffair(_ sender: UIBarButtonItem){
        performSegue(withIdentifier: "addAffair", sender: nil)
    }
    
}


class TableViewController: UITableViewController {

    enum Const {
        static let closeCellHeight: CGFloat = 180
        static let openCellHeight: CGFloat = 380
        static let rowsCount = SessionManager.instance.dorm!.affairs.count //TODO: change to the certain num of the tab bar type
    }
    
    var cellHeights: [CGFloat] = []

    // MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }

    // MARK: Helpers
    private func setup() {
        cellHeights = Array(repeating: Const.closeCellHeight, count: Const.rowsCount)
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
        let deadlineTime = DispatchTime.now() + .seconds(1)
        DispatchQueue.main.asyncAfter(deadline: deadlineTime, execute: { [weak self] in
            if #available(iOS 10.0, *) {
                self?.tableView.refreshControl?.endRefreshing()
            }
            self?.tableView.reloadData()
        })
    }
}

// MARK: - TableView

extension TableViewController {

    override func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return SessionManager.instance.dorm!.affairs.count  //TODO: change to the certain num of the tab bar type
    }

    override func tableView(_: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard case let cell as EachCell = cell else {
            return
        }

        cell.backgroundColor = .clear

        if cellHeights[indexPath.row] == Const.closeCellHeight {
            cell.unfold(false, animated: false, completion: nil)
        } else {
            cell.unfold(true, animated: false, completion: nil)
        }

        cell.number = indexPath.row
        cell.doneHandle = {
            SessionManager.instance.dorm?.affairs.remove(at: indexPath.row)
        }
        cell.editHandle = {
            self.performSegue(withIdentifier: "edit", sender: SessionManager.instance.dorm?.affairs[indexPath.row])
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "edit", let data = sender as? Affair, let vc = segue.destination as? AffairFormViewController{
            vc.affairInfo = data
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FoldingCell", for: indexPath) as! EachCell
        let durations: [TimeInterval] = [0.26, 0.2, 0.2]
        cell.durationsForExpandedState = durations
        cell.durationsForCollapsedState = durations
        
        
        if let info = SessionManager.instance.dorm?.affairs[indexPath.row]{
            cell.closeTitle.text = info.title
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "y, M d"
            cell.closeDate.text = dateFormatter.string(from: info.date)
            
            cell.title.text = cell.closeTitle.text
            cell.date.text = cell.closeDate.text
            
            cell.members.text = info.participant.reduce("", {
                $0 + $1.nickname
            })
            
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
            
            // fix https://github.com/Ramotion/folding-cell/issues/169
            if cell.frame.maxY > tableView.frame.maxY {
                tableView.scrollToRow(at: indexPath, at: UITableView.ScrollPosition.bottom, animated: true)
            }
        }, completion: nil)
    }
}


class EachCell: FoldingCell {
    var doneHandle : (()->Void)?
    var editHandle : (()->Void)?
    @IBOutlet var closeNumberLabel: UILabel!
    @IBOutlet var openNumberLabel: UILabel!
    
    @IBOutlet var closeTitle: UILabel!
    @IBOutlet var closeDate: UILabel!
    
    @IBOutlet var title: UILabel!
    @IBOutlet var date: UILabel!
    @IBOutlet var members: UILabel!
    @IBOutlet var detail: UITextView!
    
    @IBAction func buttonHandler(_ sender: UIButton) {
        if sender.titleLabel?.text == "Done"{
            doneHandle?()
        }else if sender.titleLabel?.text == "Edit"{
            editHandle?()
        }
    }
    
    var number: Int = 0 {
        didSet {
            closeNumberLabel.text = String(number)
            openNumberLabel.text = String(number)
        }
    }

    override func awakeFromNib() {
        foregroundView.layer.cornerRadius = 10
        foregroundView.layer.masksToBounds = true
        super.awakeFromNib()
    }

    override func animationDuration(_ itemIndex: NSInteger, type _: FoldingCell.AnimationType) -> TimeInterval {
        let durations = [0.26, 0.2, 0.2]
        return durations[itemIndex]
    }
}
