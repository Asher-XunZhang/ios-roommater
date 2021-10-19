//
//  UIComponents.swift
//  Roommater
//
//  Created by Asher Xun Zhang on 10/14/21.
//

import Foundation
import UIKit

let WIDTH:CGFloat = UIScreen.main.bounds.width
let HEIGHT:CGFloat = UIScreen.main.bounds.height

class NoNullTextField: UITextField, UITextFieldDelegate{
}

class RePasswordTextField: NoNullTextField{
}
class PrototypeViewController: UIViewController{
//    var centerY: CGFloat = 0.0
//    var keyboardHeight:CGFloat = 0.0
//    var maxTag: Int = 0
//    var currentTag: Int = 0
//    var openMoveKeyBoard = true
//    var isCover = false
//    var mutex = false
    
    func viewLoadAction(){}
    override func viewDidLoad() {
        super.viewDidLoad()
        viewLoadAction()
    }
}

extension PrototypeViewController: UITextFieldDelegate{
    
    @objc func textFieldDone(_ textField: UITextField){}
    
    @objc func textFieldAction(){}
    
    @objc func textFieldAvailableCheck()->Bool {return true}

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        var checkNextAvailable = true
        checkNextAvailable = textFieldAvailableCheck()
        if checkNextAvailable{
            let nextTag = textField.tag+1
            if let nextResponder = textField.superview?.viewWithTag(nextTag) {
                nextResponder.becomeFirstResponder()
            } else {
                textFieldDone(textField)
                keyboardDisappearAction(textField)
                var currentTag = textField.tag
                repeat{
                    if let currentTextField = textField.superview?.viewWithTag(currentTag){
                        currentTextField.isUserInteractionEnabled = false
                    }
                    currentTag -= 1
                }while(currentTag >= 0)
            }
        }
        return true
    }
    
    
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        keyboardDisappearAction(textField)
    }
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        textFieldAction()
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textFieldAvailableCheck()
    }
    
    
    
    func keyboardAppearAction(_ textField: UITextField){
        if (textField.frame.midY > (HEIGHT/2)){
            UIView.animate(withDuration: 0.4, animations: {
            self.view.frame.origin.y = 0
            })
        }
    }
    func keyboardDisappearAction(_ textField: UITextField){
        if (textField.frame.midY > (HEIGHT/2)){
            UIView.animate(withDuration: 0.4, animations: {
            self.view.frame.origin.y = -150
            })
        }
    }
    
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
        UIView.animate(withDuration: 0.4, animations: {
        self.view.frame.origin.y = 0
        })
    }
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
//        self.view.endEditing(true)
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

