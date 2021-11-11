//
//  DashboardController.swift
//  Roommater
//
//  Created by KAMIKU on 10/23/21.
//
import UIKit
import Foundation
import Cards

class DashboardController: PrototypeViewController {
    var bottomHeight: CGFloat = 0
    
    @IBOutlet weak var cardView:CardHighlight!
    @IBOutlet var todoTableView: UITableView!
    @IBOutlet var receiptTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bottomHeight = navigationController?.navigationBar.frame.size.height ?? 0
        cardView.frame.size = CGSize(width: WIDTH*0.9, height: 100)
        cardView.frame.origin.x = WIDTH/2 - cardView.frame.width/2
        cardView.frame.origin.y = (HEIGHT-bottomHeight)/10
        cardView.shadowBlur =  CGFloat(2)
        let detailVC = storyboard?.instantiateViewController(withIdentifier: "detailVC")
        cardView.shouldPresent(detailVC, from: self)
        cardView.textColor = UIColor.black
        cardView.title = "Hollow!"
        cardView.backgroundColor = UIColor(red: 0, green: 191/255, blue: 255/255, alpha: 1)
        
        todoTableView.frame.size = CGSize(width: WIDTH*0.9, height: 200)
        todoTableView.frame.origin.x = WIDTH/2 - todoTableView.frame.width/2
        todoTableView.frame.origin.y = (HEIGHT-bottomHeight)*0.25
        todoTableView.backgroundColor = UIColor(red: 0, green: 191/255, blue: 255/255, alpha: 1)
        
        receiptTableView.frame.size = CGSize(width: WIDTH*0.9, height: 200)
        receiptTableView.frame.origin.x = WIDTH/2 - receiptTableView.frame.width/2
        receiptTableView.frame.origin.y = (HEIGHT-bottomHeight)*0.6
        receiptTableView.backgroundColor = UIColor(red: 0, green: 191/255, blue: 255/255, alpha: 1)
        
        
    }
}
extension DashboardController : CardDelegate {
    
    func cardDidTapInside(card: Card) {
    }
    
    func cardHighlightDidTapButton(card: CardHighlight, button: UIButton) {
        card.buttonText = "OPEN!"
        card.open()
    }
    
}
