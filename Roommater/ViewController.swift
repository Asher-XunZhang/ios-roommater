//
//  ViewController.swift
//  Roommater
//
//  Created by KAMIKU on 10/5/21.
//

import UIKit

class LoginViewController: PrototypeViewController {
    @IBOutlet var Username: NoNullTextField!
    @IBOutlet var Password: NoNullTextField!
    @IBOutlet var Login: UIButton!

    @IBAction func login(_ sender: UIButton){
        sender.isEnabled = false
        Roommater.login(
            username: Username.text!,
            pass: Password.text!
        )
    }
    
    override func textFieldAction() {
        Login.isEnabled = !(Username.text!.isEmpty) && !(Password.text!.isEmpty)
    }
    
    override func textFieldDone() {
        Roommater.login(
            username: Username.text!,
            pass: Password.text!
        )
    }
}



class SignupViewController: PrototypeViewController{
    @IBOutlet var Username: NoNullTextField!
    @IBOutlet var Password: NoNullTextField!
    @IBOutlet var RePassword: NoNullTextField!
    @IBOutlet var Email: NoNullTextField!
    
    @IBOutlet var Signup: UIButton!
    
    @IBAction func signup(_ sender: UIButton){
        Roommater.signup(
            username: Username.text!,
            pass: Password.text!,
            email: Email.text!
        )
    }
    @IBAction func back(_ sender: UIButton){
        self.dismiss(animated: true, completion: nil)
    }
    
    override func textFieldAction() {
        Signup.isEnabled = !(Username.text!.isEmpty) && !(Password.text!.isEmpty) && !(RePassword.text!.isEmpty) && !(Email.text!.isEmpty)
    }
    
    override func textFieldDone() {
        Roommater.signup(
            username: Username.text!,
            pass: Password.text!,
            email: Email.text!
        )
    }
    
}


