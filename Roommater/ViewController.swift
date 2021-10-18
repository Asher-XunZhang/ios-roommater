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
    @IBOutlet var Login: PrototypeButton!
    @IBOutlet var loadingBar: UIActivityIndicatorView!

    @IBAction func login(_ sender: PrototypeButton){
//        Login.notAvailableAction()
        loading()
        SocketInstance.connect()
        SocketInstance.GET(path: "socket", data: ["platform": "iOS"]){ res in print(res)}
        SocketInstance.test()
//        SocketInstance.POST(path: "testuser/socket", data: ["platform": "iOS"]){ res in print(res)}
//        exec()
    }
    
    func exec(){
        Roommater.login(username: Username.text!, pass: Password.text!, callback: { [self] res, err in
            if let e = err {
                //TODO: Error Handel
                print(e)
            }
            switch res{
            case .Success(let data):
                print(data ?? "None")
            case .Fail(let msg), .Timeout(let msg), .Error(let msg):
                print("Other: \(msg)")
                self.Login.isEnabled = true
            case .NONE:
                print("None")
            }
        })
    }
    
    func loading(){
        Login.setTitleColor(.clear, for: .normal)
        loadingBar.startAnimating()
    }
    
    override func viewLoadAction() {
        textFieldAction()
    }
    
    override func textFieldAction() {
        if !(Username.text!.isEmpty) && !(Password.text!.isEmpty){
            Login.availableAction()
        }else{
            Login.notAvailableAction()
        }
    }
    
    override func textFieldDone() {
        exec()
    }
}

class SignupViewController: PrototypeViewController{
    @IBOutlet var Username: NoNullTextField!
    @IBOutlet var Password: NoNullTextField!
    @IBOutlet var RePassword: NoNullTextField!
    @IBOutlet var Email: NoNullTextField!
    @IBOutlet var Signup: UIButton!
    
    @IBAction func signup(_ sender: UIButton){
        sender.isEnabled = false
        exec()
    }
    
    @IBAction func back(_ sender: UIButton){
        self.dismiss(animated: true, completion: nil)
    }
    
    override func textFieldAction() {
        Signup.isEnabled = !(Username.text!.isEmpty) && !(Password.text!.isEmpty) && !(RePassword.text!.isEmpty) && !(Email.text!.isEmpty)
    }
    
    override func textFieldDone() {
        exec()
    }
    
    func exec(){
        Roommater.signup(username: Username.text!, pass: Password.text!,email: Email.text!, callback: { res, err in
            if let e = err {
                //TODO: Error Handel
                print(e)
            }
            switch res{
            case .Success(let data):
                print(data?.status ?? 600)
            case .Fail(let msg), .Timeout(let msg), .Error(let msg):
                print(msg)
            case .NONE:
                print("None")
            }
        })
    }
}


