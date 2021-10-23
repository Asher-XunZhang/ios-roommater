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
        loginAction()
    }

    func loginAction(){
        Login.notAvailableAction()
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
    
    override func textFieldDone(_ textField: UITextField) {
        textField.resignFirstResponder()
        loginAction()
    }
}

class SignupViewController: PrototypeViewController{
    @IBOutlet var Username: UsernameTextField!
    @IBOutlet var Password: PasswordTextField!
    @IBOutlet var RePassword: RePasswordTextField!
    @IBOutlet var Email: EmailTextField!


    @IBOutlet var noticeU: UILabel!
    @IBOutlet var noticeP: UILabel!
    @IBOutlet var noticeRP: UILabel!
    @IBOutlet var noticeE: UILabel!


    @IBOutlet var Signup: PrototypeButton!
    @IBOutlet var loadingBar: UIActivityIndicatorView!

    
    @IBAction func signup(_ sender: UIButton){
        signupAction()
    }

    @IBAction func back(_ sender: UIButton){
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func passwordChangedAction(_ sender: UITextField){
        self.RePassword.text = ""
        self.noticeRP.isHidden = true
    }
    override func textFieldAction() {
        if !(Username.text!.isEmpty), !(Password.text!.isEmpty), !(RePassword.text!.isEmpty), !(Email.text!.isEmpty), checkRePassword(){
            Signup.availableAction()
        }else{
            Signup.notAvailableAction()
        }
    }
    
    func signupAction(){
        Signup.notAvailableAction()
        loading()
        exec()
    }
    private func checkUsername()->Bool{
        return false
    }
    private func checkPassword()->Bool{
        return false
    }
    private func checkRePassword()->Bool{
        return RePassword.text! == Password.text!
    }
    private func checkEmail()->Bool{
        return false
    }


    override func textFieldAvailableCheck()->Bool{
        return UsernameTextFieldCheckAction() && PasswordTextFieldCheckAction() && RePasswordTextFieldCheckAction() && EmailTextFieldCheckAction()
    }

    override func UsernameTextFieldCheckAction() -> Bool {
        noticeU.isHidden = checkUsername()
        return noticeRP.isHidden
    }
    override func PasswordTextFieldCheckAction() -> Bool {
        noticeP.isHidden = checkPassword()
        return noticeP.isHidden
    }
    override func RePasswordTextFieldCheckAction() -> Bool {
        noticeRP.isHidden = checkRePassword()
        return noticeE.isHidden
    }
    override func EmailTextFieldCheckAction() -> Bool {
        noticeE.isHidden = checkEmail()
        return noticeE.isHidden
    }

    func loading(){
        Signup.setTitleColor(.clear, for: .normal)
        loadingBar.isHidden = false
        loadingBar.startAnimating()
    }

    override func viewLoadAction() {
        textFieldAction()
        noticeRP.isHidden = true
        loadingBar.isHidden = true
    }

    override func textFieldDone(_ textField: UITextField) {
        textField.resignFirstResponder()
        signupAction()
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


