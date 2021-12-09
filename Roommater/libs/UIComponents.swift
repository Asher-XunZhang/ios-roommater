//
//  UIComponents.swift
//  Roommater
//
//  Created by Asher Xun Zhang on 10/14/21.
//

import Foundation
import UIKit

// classes
class PrototypeViewController: UIViewController, UITextViewDelegate{
    var keyboardMarginY:CGFloat = 0
    var keyboardAnimitionDuration: TimeInterval = 0
    var viewDistanceFromTopScreen: CGFloat = 0
    var offsetDistance: CGFloat = 0
    
    func viewLoadAction(){}
    override func viewDidLoad() {
        super.viewDidLoad()
        viewLoadAction()
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillChangeFrame(node:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardAppearAction(node:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardDisappearAction(node:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    deinit{
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func textFieldDone(_ textField: UITextField){}
    
    @objc func textFieldAction(_ textField: UITextField){}
    
    @objc func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let nextTag = textField.tag+1
        if let nextResponder = textField.superview?.viewWithTag(nextTag) {
            nextResponder.becomeFirstResponder()
        } else {
            self.view.endEditing(true)
//            disableAllTextField()
            textFieldDone(textField)
        }
        return true
    }
    
    func disableAllTextField(){
        self.view.subviews.filter {$0 is UITextField}.forEach {
            item in item.isUserInteractionEnabled = false
        }
    }
    
    func enableAllTextField(){
        self.view.subviews.filter {$0 is UITextField}.forEach {
            item in item.isUserInteractionEnabled = true
        }
    }
    
    @objc func keyboardWillChangeFrame(node:Notification){
        keyboardAnimitionDuration = node.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as! TimeInterval
        let endFrame = (node.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        keyboardMarginY = endFrame.origin.y
    }
    
    @objc func keyboardAppearAction(node:Notification){
        self.view.subviews.filter{$0 is UITextField && $0.isFirstResponder}.forEach{ focusTextField in
            viewDistanceFromTopScreen = HEIGHT-self.view.frame.height
            let textFieldFromTopScreen = focusTextField.frame.maxY + viewDistanceFromTopScreen - offsetDistance
            let textFieldLowestBoundLimit = keyboardMarginY - focusTextField.frame.height
            if textFieldFromTopScreen > textFieldLowestBoundLimit {
                offsetDistance += (textFieldFromTopScreen - textFieldLowestBoundLimit)
                self.view.frame.origin.y = 0-offsetDistance
                if keyboardAnimitionDuration <= 0 {keyboardAnimitionDuration = 0.3}
                UIView.animate(withDuration: keyboardAnimitionDuration) {
                    self.view.layoutIfNeeded()
                }
            }
        }
    }
    
    @objc func keyboardDisappearAction(node:Notification){
        self.view.frame.origin.y = 0
        offsetDistance = 0
        UIView.animate(withDuration: keyboardAnimitionDuration) {
            self.view.layoutIfNeeded()
        }
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
        UIView.animate(withDuration: 0.3, animations: {
        self.view.frame.origin.y = 0
        })
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
    }
}
    
class PrototypeButton:UIButton{
    func notAvailableAction(){
        notAvailableUI()
    }
    @objc func notAvailableUI(){
        self.isEnabled = false
        self.backgroundColor = .systemGray5
        self.setTitleColor(.systemGray3, for: .normal)
    }
    
    func availableAction(){
        availableUI()
    }
    @objc func availableUI(){
        self.isEnabled = true
        self.backgroundColor = .systemBlue
        self.setTitleColor(.white, for: .normal)
    }
}

struct MyRegex {
    let regex: NSRegularExpression?
     
    init(_ pattern: String) {
        regex = try? NSRegularExpression(pattern: pattern)
    }
     
    func match(input: String) -> Bool {
        if let matches = regex?.matches(in: input,
            options: [],
            range: NSMakeRange(0, (input as NSString).length)) {
                return matches.count > 0
        } else {
            return false
        }
    }
}
