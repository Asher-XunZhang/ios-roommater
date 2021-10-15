//
//  UIComponents.swift
//  Roommater
//
//  Created by Asher Xun Zhang on 10/14/21.
//

import Foundation
import UIKit


class NoNullTextField: UITextField{

}

class PrototypeViewController: UIViewController{
    override func viewDidLoad() {
        super.viewDidLoad()
        textFieldAction()
        // Do any additional setup after loading the view.
        
    }
}

extension PrototypeViewController:UITextFieldDelegate{
    @objc func textFieldDone(){}
    
    @objc func textFieldAction(){}
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
      let nextTag = textField.tag+1
      if let nextResponder = textField.superview?.viewWithTag(nextTag) {
         nextResponder.becomeFirstResponder()
      } else {
          textFieldDone()
      }
      return true
    }
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        textFieldAction()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    
}
