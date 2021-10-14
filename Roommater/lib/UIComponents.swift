//
//  UIComponents.swift
//  Roommater
//
//  Created by Asher Xun Zhang on 10/14/21.
//

import Foundation
import UIKit


class NoNullTextField: UITextField{
//    override var text: String?{
//        willSet{
//            print("4qwereqwr")
//            if let text = newValue, text == "" {
//                self.textColor = .red
//                self.placeholder = "Please enter!"
//
//            }
//        }
//    }
}

class PrototypeViewController: UIViewController{
    
}

extension PrototypeViewController: UITextFieldDelegate{
    
    @objc func textFieldDone(){
        
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
      let nextTag = textField.tag+1
      if let nextResponder = textField.superview?.viewWithTag(nextTag) {
         nextResponder.becomeFirstResponder()
      } else {
          textFieldDone()
      }
      return true
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}
