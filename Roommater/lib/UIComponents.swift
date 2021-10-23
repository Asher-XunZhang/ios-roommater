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
class UsernameTextField: NoNullTextField{
}
class PasswordTextField: NoNullTextField{
}
class RePasswordTextField: NoNullTextField{
}
class EmailTextField: NoNullTextField{
}
class PrototypeViewController: UIViewController{
    
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
    
    @objc func UsernameTextFieldCheckAction() -> Bool{return true}
    @objc func PasswordTextFieldCheckAction() -> Bool{return true}
    @objc func RePasswordTextFieldCheckAction() -> Bool{return true}
    @objc func EmailTextFieldCheckAction() -> Bool{return true}

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
        if(textField.isKind(of: UsernameTextField.self)){
            UsernameTextFieldCheckAction()
        }else if(textField.isKind(of: PasswordTextField.self)){
            PasswordTextFieldCheckAction()
        }else if(textField.isKind(of: RePasswordTextField.self)){
            RePasswordTextFieldCheckAction()
        }else if(textField.isKind(of: EmailTextField.self)){
            EmailTextFieldCheckAction()
        }
    }
    
    
    
    func keyboardAppearAction(_ textField: UITextField){
        if (textField.frame.midY > (HEIGHT/2)){
            UIView.animate(withDuration: 0.3, animations: {
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
        UIView.animate(withDuration: 0.3, animations: {
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

