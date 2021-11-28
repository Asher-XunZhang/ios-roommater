//
//  DashboardController.swift
//  Roommater
//
//  Created by KAMIKU on 10/23/21.
//
import UIKit
import Foundation

import FoldingCell
//import TaggerKit


class TableViewController: UITableViewController {

    enum Const {
        static let closeCellHeight: CGFloat = 180
        static let openCellHeight: CGFloat = 380
        static let rowsCount = 2 //TODO: change to the certain num of the tab bar type
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
        return 2  //TODO: change to the certain num of the tab bar type
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
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FoldingCell", for: indexPath) as! FoldingCell
        let durations: [TimeInterval] = [0.26, 0.2, 0.2]
        cell.durationsForExpandedState = durations
        cell.durationsForCollapsedState = durations
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

    @IBOutlet var closeNumberLabel: UILabel!
    @IBOutlet var openNumberLabel: UILabel!

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

// MARK: - Actions ⚡️

extension EachCell{

    @IBAction func buttonHandler(_: AnyObject) {
        print("tap")
    }
}

//class TagViewController: UIViewController {
//
//    // MARK: - Outlets
//    @IBOutlet var addTagsTextField    : TKTextField!
//    @IBOutlet var searchContainer    : UIView!
//    @IBOutlet var testContainer        : UIView!
//
//    // We want the whole experience, let's create two TKCollectionViews
//    var productTags: TKCollectionView!
//    var allTags: TKCollectionView!
//
//    // MARK: - Lifecycle Methods
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        // Customisation example
//        //        testCollection.customFont = UIFont.boldSystemFont(ofSize: 14)        // Custom font
//        //        testCollection.customCornerRadius = 14.0                            // Corner radius of tags
//        //        testCollection.customSpacing = 20.0                                    // Spacing between cells
//        //        testCollection.customBackgroundColor = UIColor.red                    // Background of cells
//
//        productTags = TKCollectionView(tags: [
//                                        "Tech", "Design", "Writing", "Social Media"
//                                       ],
//                                       action: .removeTag,
//                                       receiver: nil)
//
//        allTags = TKCollectionView(tags: [
//                                    "Cars", "Skateboard", "Freetime", "Humor", "Travel", "Music", "Places", "Journalism", "Sports"
//                                   ],
//                                   action: .addTag,
//                                   receiver: productTags)
//
//        // Set the current controller as the delegate of both collections
//        productTags.delegate = self
//        allTags.delegate = self
//
//        // Set the sender and receiver of the TextField
//        addTagsTextField.sender     = allTags
//        addTagsTextField.receiver     = productTags
//
//        add(productTags, toView: testContainer)
//        add(allTags, toView: searchContainer)
//    }
//}
//
//// MARK: - Extension to TKCollectionViewDelegate
//extension TagViewController: TKCollectionViewDelegate {
//
//    func tagIsBeingAdded(name: String?) {
//        // Example: save testCollection.tags to UserDefault
//        print("added \(name!)")
//    }
//
//    func tagIsBeingRemoved(name: String?) {
//        print("removed \(name!)")
//    }
//}
