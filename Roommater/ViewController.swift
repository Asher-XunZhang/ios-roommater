//
//  ViewController.swift
//  Roommater
//
//  Created by KAMIKU on 10/5/21.
//

import UIKit

class LoginViewController: UIViewController {
    @IBOutlet var Username: NoNullTextField!
    @IBOutlet var Password: NoNullTextField!
    @IBOutlet var Login: UIButton!

    @IBAction func login(_ sender: UIButton){

        Roommater.login(
            username: Username.text!,
            pass: Password.text!
        )
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
    }
    
}



class SignupViewController: UIViewController{
    @IBOutlet var Username: NoNullTextField!
    @IBOutlet var Password: NoNullTextField!
    @IBOutlet var RePassword: NoNullTextField!
    @IBOutlet var Email: NoNullTextField!
    
    @IBOutlet var Signup: UIButton!
    
    @IBAction func signup(_ sender: UIButton){
        Roommater.signup(
            username: Username.text!,
            pass: Password.text!,
            email: Email.text!)
    }
    @IBAction func back(_ sender: UIButton){
        self.dismiss(animated: true, completion: nil)
    }
    
    
}


